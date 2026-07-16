import assert from 'node:assert/strict';
import test from 'node:test';
import {createSession, hashPassword, normalizeCpf, verifySession} from './_session.js';

test('normaliza CPF', () => {
  assert.equal(normalizeCpf('123.456.789-01'), '12345678901');
  assert.equal(normalizeCpf('123'), null);
});

test('gera hash determinístico sem guardar senha', () => {
  assert.equal(hashPassword('senha', 'segredo'), hashPassword('senha', 'segredo'));
  assert.notEqual(hashPassword('senha', 'segredo'), hashPassword('outra', 'segredo'));
});

test('cria e valida sessão assinada', () => {
  const now = Date.UTC(2026, 6, 12);
  const token = createSession({
    cpf: '12345678901',
    vehiclePlate: 'ABC1D23',
    studentPoint: {latitude: -20.46, longitude: -54.62},
    routeAverageSpeedKmh: 25,
    secret: 'segredo',
    now,
  });
  const session = verifySession(token, 'segredo', now + 1000);
  assert.equal(session.sub, '12345678901');
  assert.deepEqual(session.studentPoint, {
    latitude: -20.46,
    longitude: -54.62,
  });
  assert.equal(verifySession(token, 'errado', now), null);
  assert.equal(verifySession(token, 'segredo', now + 9 * 60 * 60 * 1000), null);
});
