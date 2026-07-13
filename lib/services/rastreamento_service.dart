import '../models/posicao_veiculo.dart';

abstract interface class RastreamentoService {
  Future<PosicaoVeiculo> buscarPosicao(String identificadorVeiculo);
}

class RastreamentoDemoService implements RastreamentoService {
  const RastreamentoDemoService();

  @override
  Future<PosicaoVeiculo> buscarPosicao(String identificadorVeiculo) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    return PosicaoVeiculo(
      veiculo: 'Ônibus 12',
      linha: 'Linha 05',
      latitude: -20.4697,
      longitude: -54.6201,
      velocidadeKmH: 38,
      distanciaKm: 1.2,
      minutosParaChegada: 8,
      horarioChegada: '07:18',
      atualizadoEm: DateTime.now(),
      emRota: true,
    );
  }
}
