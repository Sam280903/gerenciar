// test/apresentacao/telas/tutoriais/tutoriais_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/tutoriais/tutoriais_tela.dart';

void main() {
  // Função auxiliar para construir a tela dentro de um MaterialApp
  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TutoriaisTela(),
    ));
    // Aguarda as animações da tela terminarem
    await tester.pumpAndSettle();
  }

  testWidgets('Deve renderizar o campo de busca e as categorias de tutoriais',
      (WidgetTester tester) async {
    // ARRANGE & ACT
    await pumpTela(tester);

    // ASSERT
    // Verifica se o campo de busca está visível
    expect(find.widgetWithText(TextField, 'Buscar tutorial...'), findsOneWidget);

    // Verifica se as categorias são renderizadas (elas estão dentro de ExpansionTiles)
    // O widget ExpansionTile tem um 'title' que é um widget Text.
    expect(find.text('Cadastros'), findsOneWidget);
    expect(find.text('Agendamentos'), findsOneWidget);
    expect(find.text('Ordens de Serviço'), findsOneWidget);
    expect(find.text('Relatórios'), findsOneWidget);
  });

  testWidgets('Deve filtrar os tutoriais ao digitar na busca',
      (WidgetTester tester) async {
    // ARRANGE
    await pumpTela(tester);

    // Verifica o estado inicial
    expect(find.text('Cadastros'), findsOneWidget);
    expect(find.text('Agendamentos'), findsOneWidget);

    // ACT: Digita no campo de busca uma palavra que só existe na categoria "Cadastros"
    await tester.enterText(find.byType(TextField), 'CPF');
    await tester.pumpAndSettle();

    // ASSERT: Verifica se apenas a categoria relevante é exibida
    expect(find.text('Cadastros'), findsOneWidget);
    expect(find.text('Agendamentos'), findsNothing);
    expect(find.text('Ordens de Serviço'), findsNothing);
  });

  testWidgets('Deve exibir mensagem de "Nenhum resultado" para uma busca sem resultados',
      (WidgetTester tester) async {
    // ARRANGE
    await pumpTela(tester);

    // ACT: Digita um texto que não corresponde a nenhum tutorial
    await tester.enterText(find.byType(TextField), 'palavra_inexistente_123');
    await tester.pumpAndSettle();

    // ASSERT: Verifica se a mensagem de "Nenhum tutorial encontrado" é exibida
    expect(find.text('Nenhum tutorial encontrado'), findsOneWidget);
    // Verifica se nenhuma categoria é exibida
    expect(find.text('Cadastros'), findsNothing);
  });
}