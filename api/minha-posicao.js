import {readBearerToken, verifySession} from './_session.js';
import {fetchPositionByPlate, normalizePlate} from './posicao.js';

export default async function handler(request, response) {
  setCorsHeaders(response);
  if (request.method === 'OPTIONS') return response.status(204).end();
  if (request.method !== 'GET') return response.status(405).json({message: 'Método não permitido.'});

  const session = verifySession(readBearerToken(request), process.env.SESSION_SECRET);
  if (!session) return response.status(401).json({message: 'Sessão inválida ou expirada.'});

  try {
    const position = await fetchPositionByPlate(normalizePlate(session.vehiclePlate));
    return response.status(200).json(position);
  } catch (error) {
    const statusCode = Number(error.statusCode) || 500;
    return response.status(statusCode).json({
      message: statusCode === 500 ? 'Erro interno do servidor.' : error.message,
    });
  }
}

function setCorsHeaders(response) {
  response.setHeader('Access-Control-Allow-Origin', process.env.ESCOLA_APP_ORIGIN ?? 'http://localhost');
  response.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  response.setHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type');
}
