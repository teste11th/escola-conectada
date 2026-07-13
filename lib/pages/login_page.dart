import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/rastreamento_service.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.authService = const AuthApiService(),
    this.rastreamentoServiceFactory,
  });

  final AuthService authService;
  final RastreamentoService Function(String token)? rastreamentoServiceFactory;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _cpfController = TextEditingController();
  final _senhaController = TextEditingController();
  String? municipio = 'Campo Grande';
  bool ocultarSenha = true;
  bool lembrar = true;
  bool carregando = false;
  String? erro;

  @override
  void dispose() {
    _cpfController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    final cpf = _cpfController.text.trim();
    final senha = _senhaController.text;
    if (cpf.isEmpty || senha.isEmpty) {
      setState(() => erro = 'Informe o CPF e a senha.');
      return;
    }

    setState(() {
      carregando = true;
      erro = null;
    });

    try {
      final sessao = await widget.authService.entrar(cpf: cpf, senha: senha);
      if (!mounted) return;

      final rastreamento =
          widget.rastreamentoServiceFactory?.call(sessao.token) ??
          RastreamentoApiService(sessao.token);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(
          builder: (_) => HomePage(
            rastreamentoService: rastreamento,
            nomeResponsavel: sessao.nomeResponsavel,
            nomeAluno: sessao.nomeAluno,
          ),
        ),
      );
    } on AuthException catch (e) {
      if (mounted) setState(() => erro = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => erro = 'Não foi possível conectar. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1565C0).withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Icon(
                      Icons.directions_bus_rounded,
                      size: 52,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Escola Conectada',
                    style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Transporte Escolar Inteligente',
                    style: TextStyle(color: Color(0xFF667085), fontSize: 16),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: municipio,
                            decoration: const InputDecoration(
                              labelText: 'Município',
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Campo Grande',
                                child: Text('Campo Grande'),
                              ),
                              DropdownMenuItem(
                                value: 'Paraíso das Águas',
                                child: Text('Paraíso das Águas'),
                              ),
                              DropdownMenuItem(
                                value: 'Inocência',
                                child: Text('Inocência'),
                              ),
                            ],
                            onChanged: carregando
                                ? null
                                : (value) => setState(() => municipio = value),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _cpfController,
                            enabled: !carregando,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'CPF do responsável',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _senhaController,
                            enabled: !carregando,
                            obscureText: ocultarSenha,
                            onSubmitted: (_) => _entrar(),
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => ocultarSenha = !ocultarSenha,
                                ),
                                icon: Icon(
                                  ocultarSenha
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                          ),
                          if (erro != null) ...[
                            const SizedBox(height: 12),
                            Semantics(
                              liveRegion: true,
                              child: Text(
                                erro!,
                                style: const TextStyle(
                                  color: Color(0xFFB42318),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 0,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: lembrar,
                                    onChanged: carregando
                                        ? null
                                        : (value) => setState(
                                            () => lembrar = value ?? false,
                                          ),
                                  ),
                                  const Text('Lembrar acesso'),
                                ],
                              ),
                              TextButton(
                                onPressed: carregando ? null : () {},
                                child: const Text('Esqueci a senha'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton.icon(
                              onPressed: carregando ? null : _entrar,
                              icon: carregando
                                  ? const SizedBox.square(
                                      dimension: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.login_rounded),
                              label: Text(
                                carregando ? 'Entrando...' : 'Entrar',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Desenvolvido por MS Line Tecnologia',
                    style: TextStyle(color: Color(0xFF98A2B3), fontSize: 13),
                  ),
                  const Text(
                    'Versão 0.6',
                    style: TextStyle(color: Color(0xFFB0B7C3), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
