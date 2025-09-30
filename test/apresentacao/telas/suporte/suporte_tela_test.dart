// test/apresentacao/telas/suporte/suporte_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/suporte/suporte_tela.dart';

void main() {
  testWidgets('Deve renderizar todos os componentes da tela de suporte',
      (WidgetTester tester) async {
    // ARRANGE: Constrói a tela de suporte
    await tester.pumpWidget(const MaterialApp(home: SuporteTela()));

    // ASSERT: Verifica se os principais componentes estão visíveis
    expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    expect(find.text('Precisa de ajuda?'), findsOneWidget);
    expect(
        find.text(
            'Toque no botão abaixo para iniciar uma conversa com nossa equipe de suporte diretamente no WhatsApp.'),
        findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'ENTRAR EM CONTATO'),
        findsOneWidget);
  });

  testWidgets('Deve exibir o diálogo de opções ao tocar no botão de contato',
      (WidgetTester tester) async {
    // ARRANGE
    await tester.pumpWidget(const MaterialApp(home: SuporteTela()));

    // ACT: Toca no botão para entrar em contato
    await tester.tap(find.text('ENTRAR EM CONTATO'));
    await tester.pumpAndSettle(); // Aguarda o diálogo aparecer

    // ASSERT: Verifica se o AlertDialog com as opções é exibido
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Com quem você quer falar?'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Flávio Amorim'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Samuel Augusto'), findsOneWidget);
  });
}