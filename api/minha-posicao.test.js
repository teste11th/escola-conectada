import assert from 'node:assert/strict';
import test from 'node:test';

import {enrichPositionForStudent, haversineDistanceKm} from './minha-posicao.js';

test('calcula distancia aproximada entre dois pontos', () => {
  const distance = haversineDistanceKm(
    {latitude: 0, longitude: 0},
    {latitude: 0, longitude: 1},
  );

  assert.ok(distance > 111 && distance < 112);
});

test('adiciona ponto do aluno e estimativa sem alterar a posicao original', () => {
  const position = {
    plate: 'ABC1D23',
    latitude: -20.4697,
    longitude: -54.6201,
  };
  const enriched = enrichPositionForStudent(
    position,
    {
      studentPoint: {latitude: -20.4707, longitude: -54.6201},
      routeAverageSpeedKmh: 30,
    },
    Date.UTC(2026, 6, 15, 12),
  );

  assert.equal(enriched.plate, 'ABC1D23');
  assert.deepEqual(enriched.studentPoint, {
    latitude: -20.4707,
    longitude: -54.6201,
  });
  assert.ok(enriched.distanceKm > 0);
  assert.equal(enriched.estimatedArrivalMinutes, 1);
  assert.equal(enriched.estimateType, 'straight_line_demo');
  assert.equal(position.studentPoint, undefined);
});

test('mantem resposta compatível quando o ponto não esta configurado', () => {
  const position = {latitude: -20.4697, longitude: -54.6201};
  assert.equal(enrichPositionForStudent(position, {}), position);
});
