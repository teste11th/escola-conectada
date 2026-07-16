import 'package:escola_conectada/pages/login_page.dart';
import 'package:escola_conectada/services/auth_service.dart';
import 'package:escola_conectada/services/rastreamento_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> entrarNaHome(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          authService: const _FakeAuthService(),
          rastreamentoServiceFactory: (_) => const RastreamentoDemoService(),
          exibirTilesMapa: false,
        ),
      ),
    );
    final campos = find.byType(TextField);
    await tester.enterText(campos.at(0), '12345678901');
    await tester.enterText(campos.at(1), 'EscolaDemo2026!');
    await tester.ensureVisible(find.text('Entrar'));
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();
  }

  Future<void> rolarAteAcompanharOnibus(WidgetTester tester) async {
    await tester.drag(find.byType(ListView), const Offset(0, -500));
    await tester.pumpAndSettle();
  }

  testWidgets('abre a Home pelo botão Entrar', (tester) async {
    await entrarNaHome(tester);

    expect(find.text('Pedro Henrique'), findsOneWidget);
    expect(find.text('Ônibus em movimento'), findsOneWidget);

    await rolarAteAcompanharOnibus(tester);
    expect(find.text('Acompanhar ônibus'), findsOneWidget);
  });

  testWidgets('botão Acompanhar ônibus abre o mapa', (tester) async {
    await entrarNaHome(tester);
    await rolarAteAcompanharOnibus(tester);

    await tester.tap(find.text('Acompanhar ônibus'));
    await tester.pumpAndSettle();

    expect(find.text('Localização do ônibus'), findsOneWidget);
    expect(find.text('Ônibus 12'), findsAtLeastNWidgets(1));
  });
}

class _FakeAuthService implements AuthService {
  const _FakeAuthService();

  @override
  Future<SessaoResponsavel> entrar({
    required String cpf,
    required String senha,
  }) async {
    return const SessaoResponsavel(
      token: 'token-de-teste',
      nomeResponsavel: 'Responsável demonstrativo',
      nomeAluno: 'Pedro Henrique',
    );
  }
}
