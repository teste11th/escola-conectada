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
  final DateTime atualizadoEm;
  final bool emRota;
}
