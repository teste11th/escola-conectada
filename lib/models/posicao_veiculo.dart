class PosicaoVeiculo {
  const PosicaoVeiculo({
    required this.veiculo,
    required this.linha,
    required this.latitude,
    required this.longitude,
    required this.velocidadeKmH,
    this.distanciaKm,
    this.minutosParaChegada,
    this.horarioChegada,
    this.pontoAlunoLatitude,
    this.pontoAlunoLongitude,
    this.estimativaAproximada = false,
    this.rotaOficial = const [],
    this.trajetoAtePonto = const [],
    this.pontoJaAtendido = false,
    required this.atualizadoEm,
    required this.emRota,
  });

  final String veiculo;
  final String linha;
  final double latitude;
  final double longitude;
  final double velocidadeKmH;
  final double? distanciaKm;
  final int? minutosParaChegada;
  final String? horarioChegada;
  final double? pontoAlunoLatitude;
  final double? pontoAlunoLongitude;
  final bool estimativaAproximada;
  final List<PontoRota> rotaOficial;
  final List<PontoRota> trajetoAtePonto;
  final bool pontoJaAtendido;
  final DateTime atualizadoEm;
  final bool emRota;

  bool get temPontoAluno =>
      pontoAlunoLatitude != null && pontoAlunoLongitude != null;

  bool get temRotaOficial => rotaOficial.length >= 2;
}

class PontoRota {
  const PontoRota({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}
