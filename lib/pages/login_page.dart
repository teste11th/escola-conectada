import 'package:flutter/material.dart';

import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? municipio;
  bool ocultarSenha = true;
  bool lembrar = true;

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
                    child: const Icon(Icons.directions_bus_rounded, size: 52, color: Color(0xFF1565C0)),
                  ),
                  const SizedBox(height: 20),
                  const Text('Escola Conectada', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  const Text('Transporte Escolar Inteligente', style: TextStyle(color: Color(0xFF667085), fontSize: 16)),
                  const SizedBox(height: 28),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            initialValue: municipio,
                            decoration: const InputDecoration(labelText: 'Município', prefixIcon: Icon(Icons.location_city_outlined)),
                            items: const [
                              DropdownMenuItem(value: 'Campo Grande', child: Text('Campo Grande')),
                              DropdownMenuItem(value: 'Paraíso das Águas', child: Text('Paraíso das Águas')),
                              DropdownMenuItem(value: 'Inocência', child: Text('Inocência')),
                            ],
                            onChanged: (value) => setState(() => municipio = value),
                          ),
                          const SizedBox(height: 16),
                          const TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(labelText: 'CPF do responsável', prefixIcon: Icon(Icons.person_outline)),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            obscureText: ocultarSenha,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () => setState(() => ocultarSenha = !ocultarSenha),
                                icon: Icon(ocultarSenha ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: lembrar,
                                    onChanged: (value) => setState(
                                      () => lembrar = value ?? false,
                                    ),
                                  ),
                                  const Text('Lembrar acesso'),
                                ],
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('Esqueci a senha'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton.icon(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute<void>(builder: (_) => const HomePage()),
                                );
                              },
                              icon: const Icon(Icons.login_rounded),
                              label: const Text('Entrar', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Desenvolvido por MS Line Tecnologia', style: TextStyle(color: Color(0xFF98A2B3), fontSize: 13)),
                  const Text('Versão 0.2', style: TextStyle(color: Color(0xFFB0B7C3), fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
