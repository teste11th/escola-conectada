import 'dart:convert';

import 'package:http/http.dart' as http;

const escolaApiBaseUrl = 'https://escola-conectada-omega.vercel.app';

class SessaoResponsavel {
  const SessaoResponsavel({
    required this.token,
    required this.nomeResponsavel,
    required this.nomeAluno,
  });

  final String token;
  final String nomeResponsavel;
  final String nomeAluno;
}

abstract interface class AuthService {
  Future<SessaoResponsavel> entrar({
    required String cpf,
    required String senha,
  });
}

class AuthApiService implements AuthService {
  const AuthApiService();

  @override
  Future<SessaoResponsavel> entrar({
    required String cpf,
    required String senha,
  }) async {
    final response = await http.post(
      Uri.parse('$escolaApiBaseUrl/api/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'cpf': cpf, 'password': senha}),
    );

    final json = _decode(response.body);
    if (response.statusCode != 200) {
      throw AuthException(
        json['message']?.toString() ?? 'Não foi possível entrar.',
      );
    }

    final token = json['token']?.toString() ?? '';
    if (token.isEmpty) throw const AuthException('Sessão não recebida.');

    return SessaoResponsavel(
      token: token,
      nomeResponsavel:
          (json['responsible'] as Map?)?['name']?.toString() ?? 'Responsável',
      nomeAluno: (json['student'] as Map?)?['name']?.toString() ?? 'Aluno',
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

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
