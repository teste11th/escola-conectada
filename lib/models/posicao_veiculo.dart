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
  final DateTime atualizadoEm;
  final bool emRota;

  bool get temPontoAluno =>
      pontoAlunoLatitude != null && pontoAlunoLongitude != null;
}
