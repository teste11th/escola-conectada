import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/posicao_veiculo.dart';
import '../services/rastreamento_service.dart';

const _azul = Color(0xFF1565C0);
const _intervaloAtualizacao = Duration(seconds: 15);

class MapaPage extends StatefulWidget {
  const MapaPage({
    super.key,
    this.rastreamentoService = const RastreamentoDemoService(),
    this.exibirTiles = true,
  });

  final RastreamentoService rastreamentoService;
  final bool exibirTiles;

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  final MapController _mapController = MapController();
  Timer? _timer;
  PosicaoVeiculo? _posicao;
  Object? _erro;
  bool _buscando = false;
  bool _mapaPronto = false;

  @override
  void initState() {
    super.initState();
    _atualizarPosicao(centralizar: true);
    _timer = Timer.periodic(_intervaloAtualizacao, (_) => _atualizarPosicao());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _atualizarPosicao({bool centralizar = false}) async {
    if (_buscando) return;
    if (mounted) setState(() => _buscando = true);

    try {
      final novaPosicao = await widget.rastreamentoService.buscarPosicao(
        'onibus-escolar',
      );
      if (!mounted) return;

      setState(() {
        _posicao = novaPosicao;
        _erro = null;
      });

      if (centralizar || !_mapaPronto) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _centralizar();
        });
      }
    } catch (erro) {
      if (mounted) setState(() => _erro = erro);
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  void _centralizar() {
    final posicao = _posicao;
    if (!_mapaPronto || posicao == null) return;
    final pontoOnibus = LatLng(posicao.latitude, posicao.longitude);
    if (posicao.temPontoAluno) {
      _mapController.fitCamera(
        CameraFit.coordinates(
          coordinates: [
            pontoOnibus,
            LatLng(
              posicao.pontoAlunoLatitude!,
              posicao.pontoAlunoLongitude!,
            ),
          ],
          padding: const EdgeInsets.fromLTRB(70, 90, 70, 300),
          maxZoom: 17,
        ),
      );
      return;
    }
    _mapController.move(pontoOnibus, 16);
  }

  @override
  Widget build(BuildContext context) {
    final posicao = _posicao;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Localização do ônibus',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar posição',
            onPressed: _buscando
                ? null
                : () => _atualizarPosicao(centralizar: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Centralizar ônibus',
            onPressed: posicao == null ? null : _centralizar,
            icon: const Icon(Icons.my_location_rounded),
          ),
        ],
      ),
      body: switch ((posicao, _erro)) {
        (null, final Object erro) => _ErroLocalizacao(
          mensagem: erro.toString(),
          onTentarNovamente: () => _atualizarPosicao(centralizar: true),
        ),
        (null, null) => const Center(child: CircularProgressIndicator()),
        (final PosicaoVeiculo atual, _) => _MapaComPosicao(
          posicao: atual,
          mapController: _mapController,
          atualizando: _buscando,
          exibirTiles: widget.exibirTiles,
          avisoAtualizacao: _erro == null
              ? null
              : 'Não foi possível obter uma posição mais recente.',
          onMapReady: () {
            _mapaPronto = true;
            _centralizar();
          },
        ),
      },
    );
  }
}

class _MapaComPosicao extends StatelessWidget {
  const _MapaComPosicao({
    required this.posicao,
    required this.mapController,
    required this.atualizando,
    required this.exibirTiles,
    required this.onMapReady,
    this.avisoAtualizacao,
  });

  final PosicaoVeiculo posicao;
  final MapController mapController;
  final bool atualizando;
  final bool exibirTiles;
  final VoidCallback onMapReady;
  final String? avisoAtualizacao;

  @override
  Widget build(BuildContext context) {
    final ponto = LatLng(posicao.latitude, posicao.longitude);
    final pontoAluno = posicao.temPontoAluno
        ? LatLng(posicao.pontoAlunoLatitude!, posicao.pontoAlunoLongitude!)
        : null;

    return Stack(
      children: [
        Positioned.fill(
          child: Semantics(
            label: 'Mapa em tempo real do ônibus escolar',
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: ponto,
                initialZoom: 16,
                minZoom: 4,
                maxZoom: 19,
                onMapReady: onMapReady,
              ),
              children: [
                if (exibirTiles)
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'br.com.msline.escola_conectada',
                    maxNativeZoom: 19,
                  ),
                if (pontoAluno != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [ponto, pontoAluno],
                        color: const Color(0xFF2E7D32),
                        strokeWidth: 4,
                        pattern: StrokePattern.dashed(segments: [10, 8]),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: ponto,
                      width: 68,
                      height: 68,
                      child: Semantics(
                        label: '${posicao.veiculo} no mapa',
                        child: const _MarcadorOnibus(),
                      ),
                    ),
                    if (pontoAluno != null)
                      Marker(
                        point: pontoAluno,
                        width: 64,
                        height: 64,
                        child: Semantics(
                          label: 'Ponto de embarque do aluno',
                          child: const _MarcadorPontoAluno(),
                        ),
                      ),
                  ],
                ),
                if (exibirTiles)
                  const SimpleAttributionWidget(
                    source: Text('OpenStreetMap contributors'),
                    alignment: Alignment.topRight,
                  ),
              ],
            ),
          ),
        ),
        if (atualizando)
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: LinearProgressIndicator(minHeight: 3),
          ),
        if (avisoAtualizacao != null)
          Positioned(
            left: 16,
            right: 16,
            top: 12,
            child: Material(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(child: Text(avisoAtualizacao!)),
                  ],
                ),
              ),
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
  }
}

class _MarcadorPontoAluno extends StatelessWidget {
  const _MarcadorPontoAluno();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_pin_circle_rounded,
        color: Colors.white,
        size: 34,
      ),
    );
  }
}

class _MarcadorOnibus extends StatelessWidget {
  const _MarcadorOnibus();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _azul,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.directions_bus_rounded,
        color: Colors.white,
        size: 34,
      ),
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
                        '${posicao.linha} • ${posicao.emRota ? 'Em movimento' : 'Parado'}',
                        style: const TextStyle(color: Color(0xFF667085)),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${posicao.velocidadeKmH.toStringAsFixed(0)} km/h',
                  style: const TextStyle(
                    color: _azul,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (posicao.temPontoAluno) ...[
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_pin_circle_rounded,
                    color: Color(0xFF2E7D32),
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Ponto de embarque vinculado',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Metrica(
                  icon: Icons.near_me_rounded,
                  value: posicao.distanciaKm == null
                      ? '--'
                      : '${posicao.distanciaKm!.toStringAsFixed(1).replaceAll('.', ',')} km',
                  label: 'Distância',
                ),
                _Metrica(
                  icon: Icons.access_time_rounded,
                  value: posicao.minutosParaChegada == null
                      ? '--'
                      : '~${posicao.minutosParaChegada} min',
                  label: 'Estimativa',
                ),
                _Metrica(
                  icon: Icons.update_rounded,
                  value: _formatarHorario(posicao.atualizadoEm),
                  label: 'Atualização',
                ),
              ],
            ),
            if (posicao.estimativaAproximada) ...[
              const SizedBox(height: 10),
              const Text(
                'Estimativa inicial em linha reta. O trajeto da rota será adicionado em uma próxima etapa.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF667085), fontSize: 11),
              ),
            ],
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

class _ErroLocalizacao extends StatelessWidget {
  const _ErroLocalizacao({
    required this.mensagem,
    required this.onTentarNovamente,
  });

  final String mensagem;
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
            const SizedBox(height: 6),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF667085)),
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

String _formatarHorario(DateTime data) {
  String doisDigitos(int value) => value.toString().padLeft(2, '0');
  final local = data.toLocal();
  return '${doisDigitos(local.hour)}:${doisDigitos(local.minute)}:${doisDigitos(local.second)}';
}
