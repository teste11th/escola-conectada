const requiredEnvironmentVariables = [
  'RAPP_BASE_URL',
  'RAPP_USERNAME',
  'RAPP_PASSWORD',
  'ESCOLA_BACKEND_KEY',
  'ESCOLA_APP_ORIGIN',
];

export function assertEnvironment() {
  const missing = requiredEnvironmentVariables.filter(
    (name) => !process.env[name]?.trim(),
  );

  if (missing.length > 0) {
    const error = new Error('Backend ainda não configurado.');
    error.statusCode = 503;
    throw error;
  }
}

export function assertAppAccess(request) {
  const receivedKey = request.headers['x-escola-backend-key'];
  if (receivedKey !== process.env.ESCOLA_BACKEND_KEY) {
    const error = new Error('Acesso não autorizado.');
    error.statusCode = 401;
    throw error;
  }
}

export async function authenticateRapp() {
  const response = await fetch(`${process.env.RAPP_BASE_URL}/api/auth`, {
    method: 'POST',
    headers: {'content-type': 'application/json'},
    body: JSON.stringify({
      username: process.env.RAPP_USERNAME,
      password: process.env.RAPP_PASSWORD,
    }),
  });

  const payload = await readJson(response);
  const token = payload?.data?.token;

  if (!response.ok || !token) {
    const error = new Error('Falha ao autenticar na plataforma de rastreamento.');
    error.statusCode = 502;
    throw error;
  }

  return token;
}

export async function rappGet(path, token) {
  const response = await fetch(`${process.env.RAPP_BASE_URL}${path}`, {
    headers: {
      accept: 'application/json',
      authorization: `Bearer ${token}`,
    },
  });

  const payload = await readJson(response);
  if (!response.ok) {
    const error = new Error(payload?.message || 'Falha ao consultar a plataforma.');
    error.statusCode = response.status === 404 ? 404 : 502;
    throw error;
  }

  return payload;
}

async function readJson(response) {
  try {
    return await response.json();
  } catch {
    return null;
  }
}
