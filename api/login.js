import {createSession, hashPassword, normalizeCpf, safeEqual} from './_session.js';

export default async function handler(request, response) {
  setCorsHeaders(request, response);
  if (request.method === 'OPTIONS') return response.status(204).end();
  if (request.method !== 'POST') return response.status(405).json({message: 'Método não permitido.'});
  if (!hasEnvironment()) return response.status(503).json({message: 'Login demonstrativo não configurado.'});

  const cpf = normalizeCpf(request.body?.cpf);
  const password = String(request.body?.password ?? '');
  const expectedCpf = normalizeCpf(process.env.DEMO_PARENT_CPF);
  const receivedHash = hashPassword(password, process.env.SESSION_SECRET);
  if (!cpf || !password || cpf !== expectedCpf || !safeEqual(receivedHash, process.env.DEMO_PARENT_PASSWORD_HASH)) {
    return response.status(401).json({message: 'CPF ou senha inválidos.'});
  }

  const token = createSession({cpf, vehiclePlate: process.env.DEMO_VEHICLE_PLATE, secret: process.env.SESSION_SECRET});
  return response.status(200).json({
    token,
    expiresIn: 28800,
    responsible: {name: 'Responsável demonstrativo'},
    student: {name: 'Pedro Henrique'},
  });
}

function hasEnvironment() {
  return ['DEMO_PARENT_CPF', 'DEMO_PARENT_PASSWORD_HASH', 'DEMO_VEHICLE_PLATE', 'SESSION_SECRET']
    .every((name) => process.env[name]?.trim());
}

function setCorsHeaders(request, response) {
  const origin = request.headers.origin;
  const localOrigin = /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin ?? '');
  const allowedOrigin = localOrigin
    ? origin
    : process.env.ESCOLA_APP_ORIGIN ?? 'http://localhost';
  response.setHeader('Access-Control-Allow-Origin', allowedOrigin);
  response.setHeader('Vary', 'Origin');
  response.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  response.setHeader('Access-Control-Allow-Headers', 'Content-Type');
}
