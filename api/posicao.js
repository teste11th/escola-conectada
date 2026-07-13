import {
  assertAppAccess,
  assertEnvironment,
  authenticateRapp,
  rappGet,
} from './_rapp.js';

export default async function handler(request, response) {
  setCorsHeaders(response);

  if (request.method === 'OPTIONS') {
    return response.status(204).end();
  }

  if (request.method !== 'GET') {
    return response.status(405).json({message: 'Método não permitido.'});
  }

  try {
    assertEnvironment();
    assertAppAccess(request);

    const placa = normalizePlate(request.query.placa);
    if (!placa) {
      return response.status(400).json({message: 'Informe uma placa válida.'});
    }

    const token = await authenticateRapp();
    const vehiclesPayload = await rappGet(
      `/api/veiculos?placa=${encodeURIComponent(placa)}`,
      token,
    );
    const vehicle = findVehicle(vehiclesPayload?.data, placa);

    if (!vehicle?.id) {
      return response.status(404).json({message: 'Veículo não encontrado.'});
    }

    const positionPayload = await rappGet(`/api/posicoes/${vehicle.id}`, token);
    const position = positionPayload?.data;

    if (!position) {
      return response.status(404).json({message: 'Posição não encontrada.'});
    }

    return response.status(200).json({
      vehicleId: Number(position.id_veiculo ?? vehicle.id),
      trackerId: Number(vehicle.id_rastreador ?? 0),
      plate: String(position.placa ?? vehicle.placa ?? placa),
      latitude: Number(position.latitude),
      longitude: Number(position.longitude),
      speedKmH: parseSpeed(position.velocidade),
      eventAt: position.datetime_evento ?? null,
      ignition: position.ign ?? null,
      gpsValid: Boolean(position.gps_valido),
      proximity: position.proximidade ?? null,
    });
  } catch (error) {
    const statusCode = Number(error.statusCode) || 500;
    return response.status(statusCode).json({
      message: statusCode === 500 ? 'Erro interno do servidor.' : error.message,
    });
  }
}

export function normalizePlate(value) {
  const plate = String(value ?? '').toUpperCase().replace(/[^A-Z0-9]/g, '');
  return /^[A-Z]{3}[0-9][A-Z0-9][0-9]{2}$/.test(plate) ? plate : null;
}

export function findVehicle(data, plate) {
  const vehicles = Array.isArray(data) ? data : data ? [data] : [];
  return vehicles.find((vehicle) => normalizePlate(vehicle.placa) === plate) ?? null;
}

export function parseSpeed(value) {
  const parsed = Number.parseFloat(String(value ?? '0').replace(',', '.'));
  return Number.isFinite(parsed) && parsed >= 0 ? parsed : 0;
}

function setCorsHeaders(response) {
  response.setHeader(
    'Access-Control-Allow-Origin',
    process.env.ESCOLA_APP_ORIGIN ?? 'http://localhost',
  );
  response.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  response.setHeader(
    'Access-Control-Allow-Headers',
    'Content-Type, X-Escola-Backend-Key',
  );
}
