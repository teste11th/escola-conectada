import 'package:flutter/material.dart';

void main() {
  runApp(const EscolaConectadaApp());
}

class EscolaConectadaApp extends StatelessWidget {
  const EscolaConectadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Escola Conectada',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 420,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    const Icon(
                      Icons.directions_bus_rounded,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Escola Conectada",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Transporte Escolar Inteligente",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 35),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Município",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "Campo Grande",
                          child: Text("Campo Grande"),
                        ),
                        DropdownMenuItem(
                          value: "Catanduva",
                          child: Text("Catanduva"),
                        ),
                      ],
                      onChanged: (v) {},
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      decoration: const InputDecoration(
                        labelText: "CPF do responsável",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Senha",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.login),
                        label: const Text(
                          "Entrar",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextButton(
                      onPressed: () {},
                      child: const Text("Esqueci minha senha"),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Versão 0.1",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}