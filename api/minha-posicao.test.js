import assert from 'node:assert/strict';
import test from 'node:test';

import {
  buildOfficialRouteEstimate,
  enrichPositionForStudent,
  haversineDistanceKm,
  parseRoutePoints,
} from './minha-posicao.js';

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

test('interpreta rota privada em formato compacto', () => {
  assert.deepEqual(parseRoutePoints('[[-20.1,-54.1],[-20.2,-54.2]]'), [
    {latitude: -20.1, longitude: -54.1},
    {latitude: -20.2, longitude: -54.2},
  ]);
  assert.deepEqual(parseRoutePoints('invalido'), []);
});

test('calcula distancia seguindo a rota oficial', () => {
  const route = [
    {latitude: 0, longitude: 0},
    {latitude: 0, longitude: 1},
    {latitude: 1, longitude: 1},
  ];
  const estimate = buildOfficialRouteEstimate(
    {latitude: 0, longitude: 0},
    {latitude: 1, longitude: 1},
    route,
    60,
    Date.UTC(2026, 6, 15, 12),
  );

  assert.equal(estimate.estimateType, 'official_route_demo');
  assert.equal(estimate.stopPassed, false);
  assert.ok(estimate.distanceKm > 222 && estimate.distanceKm < 223);
  assert.equal(estimate.routePath.length, 5);
});

test('identifica quando o ônibus já passou pelo ponto', () => {
  const route = [
    {latitude: 0, longitude: 0},
    {latitude: 0, longitude: 1},
    {latitude: 0, longitude: 2},
  ];
  const estimate = buildOfficialRouteEstimate(
    {latitude: 0, longitude: 2},
    {latitude: 0, longitude: 1},
    route,
    25,
  );

  assert.equal(estimate.stopPassed, true);
  assert.deepEqual(estimate.routePath, []);
  assert.equal(estimate.distanceKm, null);
});
