import assert from 'node:assert/strict';
import test from 'node:test';

import {findVehicle, normalizePlate, parseSpeed} from './posicao.js';

test('normaliza placas antigas e Mercosul', () => {
  assert.equal(normalizePlate('ABC-1234'), 'ABC1234');
  assert.equal(normalizePlate('ABC1D23'), 'ABC1D23');
  assert.equal(normalizePlate('placa inválida'), null);
});

test('localiza veículo pela placa', () => {
  const vehicle = findVehicle(
    [
      {id: 10, placa: 'AAA-0000'},
      {id: 25, placa: 'ABC1D23', id_rastreador: 8},
    ],
    'ABC1D23',
  );

  assert.equal(vehicle.id, 25);
  assert.equal(vehicle.id_rastreador, 8);
});

test('converte velocidade retornada como texto', () => {
  assert.equal(parseSpeed('38'), 38);
  assert.equal(parseSpeed('38,5'), 38.5);
  assert.equal(parseSpeed('inválida'), 0);
});
