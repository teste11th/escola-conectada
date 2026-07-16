import crypto from 'node:crypto';

const sessionDurationSeconds = 60 * 60 * 8;

export function normalizeCpf(value) {
  const cpf = String(value ?? '').replace(/\D/g, '');
  return /^\d{11}$/.test(cpf) ? cpf : null;
}

export function hashPassword(password, secret) {
  return crypto.createHmac('sha256', secret).update(String(password), 'utf8').digest('hex');
}

export function safeEqual(left, right) {
  const leftBuffer = Buffer.from(String(left));
  const rightBuffer = Buffer.from(String(right));
  return leftBuffer.length === rightBuffer.length && crypto.timingSafeEqual(leftBuffer, rightBuffer);
}

export function createSession({
  cpf,
  vehiclePlate,
  studentPoint,
  routeAverageSpeedKmh,
  secret,
  now = Date.now(),
}) {
  const payload = {
    sub: cpf,
    vehiclePlate,
    ...(studentPoint ? {studentPoint} : {}),
    ...(routeAverageSpeedKmh ? {routeAverageSpeedKmh} : {}),
    exp: Math.floor(now / 1000) + sessionDurationSeconds,
  };
  const encoded = Buffer.from(JSON.stringify(payload)).toString('base64url');
  const signature = crypto.createHmac('sha256', secret).update(encoded).digest('base64url');
  return `${encoded}.${signature}`;
}

export function verifySession(token, secret, now = Date.now()) {
  const [encoded, receivedSignature] = String(token ?? '').split('.');
  if (!encoded || !receivedSignature || !secret) return null;
  const expectedSignature = crypto.createHmac('sha256', secret).update(encoded).digest('base64url');
  if (!safeEqual(receivedSignature, expectedSignature)) return null;
  try {
    const payload = JSON.parse(Buffer.from(encoded, 'base64url').toString('utf8'));
    if (!payload.sub || !payload.vehiclePlate || payload.exp <= Math.floor(now / 1000)) return null;
    return payload;
  } catch {
    return null;
  }
}

export function readBearerToken(request) {
  return String(request.headers.authorization ?? '').match(/^Bearer\s+(.+)$/i)?.[1] ?? null;
}
