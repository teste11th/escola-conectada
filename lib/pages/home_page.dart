import 'package:flutter/material.dart';

const azul = Color(0xFF1565C0);
const verde = Color(0xFF2E7D32);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int pagina = 0;

  @override
  Widget build(BuildContext context) {
    final telas = [
      InicioPage(onMapa: () => setState(() => pagina = 1)),
      const MapaPage(),
      const AvisosPage(),
      const PerfilPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: pagina, children: telas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: pagina,
        onDestinationSelected: (i) => setState(() => pagina = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.notifications_outlined), selectedIcon: Icon(Icons.notifications), label: 'Avisos'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class InicioPage extends StatelessWidget {
  final VoidCallback onMapa;
  const InicioPage({super.key, required this.onMapa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Escola Conectada', style: TextStyle(fontWeight: FontWeight.w800)),
            Text('Portal de Pais e Alunos', style: TextStyle(fontSize: 12, color: Color(0xFF667085))),
          ],
        ),
        actions: [IconButton(onPressed: () {}, icon: const Badge(child: Icon(Icons.notifications_outlined)))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Bom dia, responsável 👋', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Acompanhe o transporte escolar com mais segurança e tranquilidade.',
              style: TextStyle(color: Color(0xFF667085), height: 1.4)),
          const SizedBox(height: 22),
          const _AlunoCard(),
          const SizedBox(height: 14),
          const _StatusCard(),
          const SizedBox(height: 14),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: onMapa,
              icon: const Icon(Icons.location_on_rounded),
              label: const Text('Acompanhar ônibus', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Últimos avisos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          const _AvisoCard(
            icon: Icons.check_circle_outline,
            title: 'Rota funcionando normalmente',
            subtitle: 'O ônibus iniciou o trajeto dentro do horário previsto.',
            color: verde,
          ),
          const SizedBox(height: 10),
          const _AvisoCard(
            icon: Icons.info_outline,
            title: 'Previsão de chegada',
            subtitle: 'Chegada estimada ao ponto em aproximadamente 8 minutos.',
            color: azul,
          ),
        ],
      ),
    );
  }
}

class _AlunoCard extends StatelessWidget {
  const _AlunoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: const [
            Row(
              children: [
                CircleAvatar(radius: 29, child: Icon(Icons.school_rounded, size: 31)),
                SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Pedro Henrique', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  Text('Aluno vinculado', style: TextStyle(color: Color(0xFF667085))),
                ])),
                Icon(Icons.chevron_right_rounded),
              ],
            ),
            Divider(height: 30),
            _Info(icon: Icons.apartment_rounded, label: 'Escola', value: 'EM João XXIII'),
            SizedBox(height: 14),
            _Info(icon: Icons.route_rounded, label: 'Linha', value: 'Linha 05'),
            SizedBox(height: 14),
            _Info(icon: Icons.directions_bus_rounded, label: 'Veículo', value: 'Ônibus 12'),
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Info({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: azul),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Color(0xFF667085), fontSize: 12)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      ]),
    ]);
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(children: const [
          Row(children: [
            CircleAvatar(backgroundColor: Color(0xFFE7F5E9), child: Icon(Icons.directions_bus_filled_rounded, color: verde)),
            SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Ônibus em rota', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text('Atualizado há poucos segundos', style: TextStyle(color: Color(0xFF667085), fontSize: 12)),
            ])),
            Icon(Icons.circle, color: verde, size: 12),
          ]),
          Divider(height: 28),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _Status(icon: Icons.schedule, value: '8 min', label: 'Chegada'),
            _Status(icon: Icons.near_me, value: '1,2 km', label: 'Distância'),
            _Status(icon: Icons.speed, value: '38 km/h', label: 'Velocidade'),
          ]),
        ]),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Status({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(children: [
    Icon(icon, color: azul, size: 20),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
    Text(label, style: const TextStyle(color: Color(0xFF667085), fontSize: 11)),
  ]);
}

class _AvisoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  const _AvisoCard({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: .1), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class MapaPage extends StatelessWidget {
  const MapaPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Localização do ônibus', style: TextStyle(fontWeight: FontWeight.w800))),
      body: Stack(children: [
        const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.map_rounded, size: 84, color: Color(0xFF9EABC0)),
          SizedBox(height: 10),
          Text('Mapa em tempo real', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          Text('A integração com o mapa será adicionada na próxima etapa.', textAlign: TextAlign.center),
        ])),
        Positioned(left: 16, right: 16, bottom: 18, child: Card(child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(children: const [
            CircleAvatar(child: Icon(Icons.directions_bus_rounded)),
            SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Ônibus 12', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
              Text('Linha 05 • Em rota'),
            ])),
            Text('8 min', style: TextStyle(color: azul, fontWeight: FontWeight.w800, fontSize: 17)),
          ]),
        ))),
      ]),
    );
  }
}

class AvisosPage extends StatelessWidget {
  const AvisosPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Avisos', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.all(18), children: const [
        _AvisoCard(icon: Icons.directions_bus, title: 'Ônibus em rota', subtitle: 'A rota iniciou normalmente hoje.', color: verde),
        SizedBox(height: 10),
        _AvisoCard(icon: Icons.warning_amber, title: 'Possível atraso', subtitle: 'Trânsito intenso na região central.', color: Colors.orange),
        SizedBox(height: 10),
        _AvisoCard(icon: Icons.campaign_outlined, title: 'Veículo reserva', subtitle: 'A rota foi atendida por veículo reserva.', color: azul),
      ]),
    );
  }
}

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil', style: TextStyle(fontWeight: FontWeight.w800))),
      body: ListView(padding: const EdgeInsets.all(18), children: [
        const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 52)),
        const SizedBox(height: 14),
        const Center(child: Text('Responsável do aluno', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
        const SizedBox(height: 24),
        const Card(child: Column(children: [
          ListTile(leading: Icon(Icons.badge_outlined), title: Text('CPF'), subtitle: Text('000.000.000-00')),
          Divider(height: 1),
          ListTile(leading: Icon(Icons.phone_outlined), title: Text('Telefone'), subtitle: Text('(67) 99999-9999')),
          Divider(height: 1),
          ListTile(leading: Icon(Icons.school_outlined), title: Text('Aluno vinculado'), subtitle: Text('Pedro Henrique')),
        ])),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          icon: const Icon(Icons.logout),
          label: const Text('Sair'),
        ),
      ]),
    );
  }
}
