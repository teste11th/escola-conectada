import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/posicao_veiculo.dart';
import 'auth_service.dart';

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
      pontoAlunoLatitude: -20.4667,
      pontoAlunoLongitude: -54.6175,
      estimativaAproximada: true,
      atualizadoEm: DateTime.now(),
      emRota: true,
    );
  }
}

class RastreamentoApiService implements RastreamentoService {
  const RastreamentoApiService(this.token);

  final String token;

  @override
  Future<PosicaoVeiculo> buscarPosicao(String identificadorVeiculo) async {
    final response = await http.get(
      Uri.parse('$escolaApiBaseUrl/api/minha-posicao'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final json = _decode(response.body);
    if (response.statusCode != 200) {
      throw RastreamentoException(
        json['message']?.toString() ?? 'Não foi possível obter a localização.',
      );
    }

    final velocidade = (json['speedKmH'] as num?)?.toDouble() ?? 0;
    final ignicao = json['ignition']?.toString().toUpperCase() == 'ON';
    final placa = json['plate']?.toString() ?? 'Veículo escolar';
    final pontoAluno = json['studentPoint'] as Map?;
    final chegada = DateTime.tryParse(
      json['estimatedArrivalAt']?.toString() ?? '',
    );

    return PosicaoVeiculo(
      veiculo: 'Ônibus $placa',
      linha: 'Linha 05',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      velocidadeKmH: velocidade,
      distanciaKm: (json['distanceKm'] as num?)?.toDouble(),
      minutosParaChegada: (json['estimatedArrivalMinutes'] as num?)?.toInt(),
      horarioChegada: chegada == null ? null : _formatarHorario(chegada),
      pontoAlunoLatitude: (pontoAluno?['latitude'] as num?)?.toDouble(),
      pontoAlunoLongitude: (pontoAluno?['longitude'] as num?)?.toDouble(),
      estimativaAproximada: json['estimateType'] == 'straight_line_demo',
      atualizadoEm:
          DateTime.tryParse(json['eventAt']?.toString() ?? '') ??
          DateTime.now(),
      emRota: ignicao || velocidade > 0,
    );
  }

  Map<String, dynamic> _decode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } on FormatException {
      return const <String, dynamic>{};
    }
  }
}

String _formatarHorario(DateTime data) {
  String doisDigitos(int value) => value.toString().padLeft(2, '0');
  final local = data.toLocal();
  return '${doisDigitos(local.hour)}:${doisDigitos(local.minute)}';
}

class RastreamentoException implements Exception {
  const RastreamentoException(this.message);

  final String message;

  @override
  String toString() => message;
}
