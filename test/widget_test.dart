import 'package:escola_conectada/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> entrarNaHome(WidgetTester tester) async {
    await tester.pumpWidget(const EscolaConectadaApp());
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
    expect(find.text('Ônibus em rota'), findsOneWidget);

    await rolarAteAcompanharOnibus(tester);
    expect(find.text('Acompanhar ônibus'), findsOneWidget);
  });

  testWidgets('botão Acompanhar ônibus abre o mapa', (tester) async {
    await entrarNaHome(tester);
    await rolarAteAcompanharOnibus(tester);

    await tester.tap(find.text('Acompanhar ônibus'));
    await tester.pumpAndSettle();

    expect(find.text('Ponto do aluno'), findsOneWidget);
    expect(find.text('EM João XXIII'), findsOneWidget);
    expect(find.text('Ônibus 12'), findsAtLeastNWidgets(1));
  });
}
