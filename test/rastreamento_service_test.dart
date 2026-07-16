import 'package:escola_conectada/services/rastreamento_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('serviço demonstrativo retorna uma posição válida', () async {
    const service = RastreamentoDemoService();

    final posicao = await service.buscarPosicao('onibus-12');

    expect(posicao.veiculo, 'Ônibus 12');
    expect(posicao.linha, 'Linha 05');
    expect(posicao.latitude, isNot(0));
    expect(posicao.longitude, isNot(0));
    expect(posicao.velocidadeKmH, greaterThanOrEqualTo(0));
    expect(posicao.emRota, isTrue);
    expect(posicao.temPontoAluno, isTrue);
    expect(posicao.distanciaKm, isNotNull);
    expect(posicao.minutosParaChegada, isNotNull);
  });
}
