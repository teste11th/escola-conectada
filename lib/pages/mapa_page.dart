import 'package:flutter/material.dart';

import '../models/posicao_veiculo.dart';
import '../services/rastreamento_service.dart';

const _azul = Color(0xFF1565C0);
const _verde = Color(0xFF2E7D32);

class MapaPage extends StatefulWidget {
  const MapaPage({
    super.key,
    this.rastreamentoService = const RastreamentoDemoService(),
  });

  final RastreamentoService rastreamentoService;

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  late Future<PosicaoVeiculo> _posicao;

  @override
  void initState() {
    super.initState();
    _atualizarPosicao();
  }

  void _atualizarPosicao() {
    _posicao = widget.rastreamentoService.buscarPosicao('onibus-12');
  }

  void _recarregar() {
    setState(_atualizarPosicao);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Localização do ônibus',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Centralizar ônibus',
            onPressed: _recarregar,
            icon: const Icon(Icons.my_location_rounded),
          ),
        ],
      ),
      body: FutureBuilder<PosicaoVeiculo>(
        future: _posicao,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErroLocalizacao(onTentarNovamente: _recarregar);
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posicao = snapshot.requireData;
          return LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Semantics(
                      label: 'Mapa demonstrativo da rota escolar',
                      child: CustomPaint(painter: _MapaPainter()),
                    ),
                  ),
                  const Positioned(
                    left: 22,
                    top: 32,
                    child: _Marcador(
                      icon: Icons.home_rounded,
                      label: 'Ponto do aluno',
                      color: Color(0xFF7B61FF),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * .45,
                    top: constraints.maxHeight * .30,
                    child: _Marcador(
                      icon: Icons.directions_bus_rounded,
                      label: posicao.veiculo,
                      color: _azul,
                      destaque: true,
                    ),
                  ),
                  const Positioned(
                    right: 22,
                    top: 78,
                    child: _Marcador(
                      icon: Icons.school_rounded,
                      label: 'EM João XXIII',
                      color: _verde,
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 18,
                    child: _ResumoRota(posicao: posicao),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _Marcador extends StatelessWidget {
  const _Marcador({
    required this.icon,
    required this.label,
    required this.color,
    this.destaque = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: destaque ? 58 : 48,
          height: destaque ? 58 : 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: destaque ? 30 : 25),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Color(0x1A000000), blurRadius: 6),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _ResumoRota extends StatelessWidget {
  const _ResumoRota({required this.posicao});

  final PosicaoVeiculo posicao;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.directions_bus_rounded, color: _azul),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        posicao.veiculo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        '${posicao.linha} • ${posicao.emRota ? 'Em rota' : 'Parado'}',
                        style: const TextStyle(color: Color(0xFF667085)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${posicao.minutosParaChegada} min',
                      style: const TextStyle(
                        color: _azul,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      'previsão',
                      style: TextStyle(color: Color(0xFF667085), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Metrica(
                  icon: Icons.near_me_rounded,
                  value:
                      '${posicao.distanciaKm.toStringAsFixed(1).replaceAll('.', ',')} km',
                  label: 'Distância',
                ),
                _Metrica(
                  icon: Icons.speed_rounded,
                  value: '${posicao.velocidadeKmH.toStringAsFixed(0)} km/h',
                  label: 'Velocidade',
                ),
                _Metrica(
                  icon: Icons.access_time_rounded,
                  value: posicao.horarioChegada,
                  label: 'Chegada',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Posição atualizada agora',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF667085)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErroLocalizacao extends StatelessWidget {
  const _ErroLocalizacao({required this.onTentarNovamente});

  final VoidCallback onTentarNovamente;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 58,
              color: Color(0xFF667085),
            ),
            const SizedBox(height: 12),
            const Text(
              'Não foi possível atualizar a localização.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onTentarNovamente,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: _azul, size: 20),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF667085), fontSize: 11),
        ),
      ],
    );
  }
}

class _MapaPainter extends CustomPainter {
  const _MapaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEAF0E8),
    );

    final quarteirao = Paint()..color = Colors.white;
    for (var linha = 0; linha < 5; linha++) {
      for (var coluna = 0; coluna < 4; coluna++) {
        final esquerda = 18.0 + coluna * (size.width / 4);
        final topo = 20.0 + linha * 105;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(esquerda, topo, size.width / 5.2, 62),
            const Radius.circular(10),
          ),
          quarteirao,
        );
      }
    }

    final caminho = Path()
      ..moveTo(45, 92)
      ..cubicTo(
        size.width * .18,
        185,
        size.width * .34,
        112,
        size.width * .48,
        238,
      )
      ..cubicTo(
        size.width * .62,
        355,
        size.width * .73,
        170,
        size.width - 62,
        132,
      );

    canvas.drawPath(
      caminho,
      Paint()
        ..color = const Color(0xFFD3DBE4)
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawPath(
      caminho,
      Paint()
        ..color = _azul
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
