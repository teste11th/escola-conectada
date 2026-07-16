import {readBearerToken, verifySession} from './_session.js';
import {fetchPositionByPlate, normalizePlate} from './posicao.js';

export default async function handler(request, response) {
  setCorsHeaders(request, response);
  if (request.method === 'OPTIONS') return response.status(204).end();
  if (request.method !== 'GET') return response.status(405).json({message: 'Método não permitido.'});

  const session = verifySession(readBearerToken(request), process.env.SESSION_SECRET);
  if (!session) return response.status(401).json({message: 'Sessão inválida ou expirada.'});

  try {
    const position = await fetchPositionByPlate(normalizePlate(session.vehiclePlate));
    return response.status(200).json(enrichPositionForStudent(position, session));
  } catch (error) {
    const statusCode = Number(error.statusCode) || 500;
    return response.status(statusCode).json({
      message: statusCode === 500 ? 'Erro interno do servidor.' : error.message,
    });
  }
}

export function enrichPositionForStudent(
  position,
  session,
  now = Date.now(),
  officialRoute = readOfficialRoute(now),
) {
  const studentPoint = normalizePoint(session?.studentPoint);
  if (!studentPoint) return position;

  const routeEstimate = buildOfficialRouteEstimate(
    position,
    studentPoint,
    officialRoute,
    session?.routeAverageSpeedKmh,
    now,
  );
  if (routeEstimate) {
    return {...position, studentPoint, ...routeEstimate};
  }

  const distanceKm = haversineDistanceKm(
    {latitude: Number(position.latitude), longitude: Number(position.longitude)},
    studentPoint,
  );
  if (!Number.isFinite(distanceKm)) return position;

  const averageSpeed = Number(session.routeAverageSpeedKmh);
  const speedKmH = Number.isFinite(averageSpeed) && averageSpeed > 0
    ? averageSpeed
    : 25;
  const estimatedArrivalMinutes = distanceKm === 0
    ? 0
    : Math.max(1, Math.ceil((distanceKm / speedKmH) * 60));

  return {
    ...position,
    studentPoint,
    distanceKm: Number(distanceKm.toFixed(3)),
    estimatedArrivalMinutes,
    estimatedArrivalAt: new Date(
      now + estimatedArrivalMinutes * 60 * 1000,
    ).toISOString(),
    estimateType: 'straight_line_demo',
  };
}

export function parseRoutePoints(value) {
  try {
    const parsed = JSON.parse(String(value ?? ''));
    if (!Array.isArray(parsed)) return [];
    return parsed
      .map((point) => Array.isArray(point)
        ? normalizePoint({latitude: point[0], longitude: point[1]})
        : normalizePoint(point))
      .filter(Boolean);
  } catch {
    return [];
  }
}

export function buildOfficialRouteEstimate(
  position,
  studentPoint,
  routePoints,
  configuredSpeed,
  now = Date.now(),
) {
  if (!Array.isArray(routePoints) || routePoints.length < 2) return null;
  const vehiclePoint = normalizePoint(position);
  const stopPoint = normalizePoint(studentPoint);
  if (!vehiclePoint || !stopPoint) return null;

  const vehicleIndex = nearestPointIndex(vehiclePoint, routePoints);
  const stopIndex = nearestPointIndex(stopPoint, routePoints);
  const officialRoute = routePoints.map(({latitude, longitude}) => [latitude, longitude]);

  if (vehicleIndex > stopIndex) {
    return {
      officialRoute,
      routePath: [],
      distanceKm: null,
      estimatedArrivalMinutes: null,
      estimatedArrivalAt: null,
      stopPassed: true,
      estimateType: 'official_route_demo',
    };
  }

  const remainingPoints = [
    vehiclePoint,
    ...routePoints.slice(vehicleIndex, stopIndex + 1),
    stopPoint,
  ];
  const distanceKm = polylineDistanceKm(remainingPoints);
  const averageSpeed = Number(configuredSpeed);
  const speedKmH = Number.isFinite(averageSpeed) && averageSpeed > 0
    ? averageSpeed
    : 25;
  const estimatedArrivalMinutes = distanceKm === 0
    ? 0
    : Math.max(1, Math.ceil((distanceKm / speedKmH) * 60));

  return {
    officialRoute,
    routePath: remainingPoints.map(({latitude, longitude}) => [latitude, longitude]),
    distanceKm: Number(distanceKm.toFixed(3)),
    estimatedArrivalMinutes,
    estimatedArrivalAt: new Date(
      now + estimatedArrivalMinutes * 60 * 1000,
    ).toISOString(),
    stopPassed: false,
    estimateType: 'official_route_demo',
  };
}

export function polylineDistanceKm(points) {
  let total = 0;
  for (let index = 1; index < points.length; index += 1) {
    total += haversineDistanceKm(points[index - 1], points[index]);
  }
  return total;
}

function nearestPointIndex(target, points) {
  let nearestIndex = 0;
  let nearestDistance = Number.POSITIVE_INFINITY;
  for (let index = 0; index < points.length; index += 1) {
    const distance = haversineDistanceKm(target, points[index]);
    if (distance < nearestDistance) {
      nearestDistance = distance;
      nearestIndex = index;
    }
  }
  return nearestIndex;
}

function readOfficialRoute(now) {
  const period = routePeriod(now);
  const primary = period === 'morning'
    ? process.env.DEMO_ROUTE_MORNING_JSON
    : process.env.DEMO_ROUTE_AFTERNOON_JSON;
  const fallback = period === 'morning'
    ? process.env.DEMO_ROUTE_AFTERNOON_JSON
    : process.env.DEMO_ROUTE_MORNING_JSON;
  const route = parseRoutePoints(primary);
  return route.length >= 2 ? route : parseRoutePoints(fallback);
}

function routePeriod(now) {
  const timezone = process.env.DEMO_ROUTE_TIMEZONE ?? 'America/Campo_Grande';
  try {
    const hour = Number(new Intl.DateTimeFormat('en-US', {
      timeZone: timezone,
      hour: '2-digit',
      hourCycle: 'h23',
    }).format(new Date(now)));
    return hour < 12 ? 'morning' : 'afternoon';
  } catch {
    return new Date(now).getUTCHours() < 16 ? 'morning' : 'afternoon';
  }
}

export function haversineDistanceKm(origin, destination) {
  const start = normalizePoint(origin);
  const end = normalizePoint(destination);
  if (!start || !end) return Number.NaN;

  const radians = (degrees) => (degrees * Math.PI) / 180;
  const latitudeDelta = radians(end.latitude - start.latitude);
  const longitudeDelta = radians(end.longitude - start.longitude);
  const startLatitude = radians(start.latitude);
  const endLatitude = radians(end.latitude);
  const a =
    Math.sin(latitudeDelta / 2) ** 2 +
    Math.cos(startLatitude) *
      Math.cos(endLatitude) *
      Math.sin(longitudeDelta / 2) ** 2;
  return 6371 * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function normalizePoint(value) {
  const latitude = Number(value?.latitude);
  const longitude = Number(value?.longitude);
  if (
    !Number.isFinite(latitude) ||
    !Number.isFinite(longitude) ||
    latitude < -90 ||
    latitude > 90 ||
    longitude < -180 ||
    longitude > 180
  ) {
    return null;
  }
  return {latitude, longitude};
}

function setCorsHeaders(request, response) {
  const origin = request.headers.origin;
  const localOrigin = /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin ?? '');
  const allowedOrigin = localOrigin
    ? origin
    : process.env.ESCOLA_APP_ORIGIN ?? 'http://localhost';
  response.setHeader('Access-Control-Allow-Origin', allowedOrigin);
  response.setHeader('Vary', 'Origin');
  response.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  response.setHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type');
}
