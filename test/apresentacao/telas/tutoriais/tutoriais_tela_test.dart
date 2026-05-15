// test/apresentacao/telas/tutoriais/tutoriais_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/tutoriais/tutoriais_tela.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'tutoriais_tela_test.mocks.dart';

@GenerateMocks([AutenticacaoServico])
void main() {
  late MockAutenticacaoServico mockAuthServico;

  setUp(() {
    mockAuthServico = MockAutenticacaoServico();
    when(mockAuthServico.buscarDadosUsuarioLogado()).thenAnswer(
      (_) async => {'nome': 'Gestor Teste', 'perfil': 'gestor'},
    );
  });

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TutoriaisTela(authServico: mockAuthServico),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('Deve renderizar o campo de busca e as categorias de tutoriais',
      (WidgetTester tester) async {
    await pumpTela(tester);

    expect(find.widgetWithText(TextField, 'Buscar tutorial...'), findsOneWidget);
    expect(find.text('Cadastros'), findsOneWidget);
    expect(find.text('Agendamentos'), findsOneWidget);
    expect(find.text('Ordens de Serviço'), findsOneWidget);
    expect(find.text('Relatórios'), findsOneWidget);
  });

  testWidgets('Deve filtrar os tutoriais ao digitar na busca',
      (WidgetTester tester) async {
    await pumpTela(tester);

    expect(find.text('Cadastros'), findsOneWidget);
    expect(find.text('Agendamentos'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'CPF');
    await tester.pumpAndSettle();

    expect(find.text('Cadastros'), findsOneWidget);
    expect(find.text('Agendamentos'), findsNothing);
    expect(find.text('Ordens de Serviço'), findsNothing);
  });

  testWidgets(
      'Deve exibir mensagem de "Nenhum resultado" para uma busca sem resultados',
      (WidgetTester tester) async {
    await pumpTela(tester);

    await tester.enterText(find.byType(TextField), 'palavra_inexistente_123');
    await tester.pumpAndSettle();

    expect(find.text('Nenhum tutorial encontrado'), findsOneWidget);
    expect(find.text('Cadastros'), findsNothing);
  });

  testWidgets('Técnico não deve ver tutoriais exclusivos de gestor',
      (WidgetTester tester) async {
    when(mockAuthServico.buscarDadosUsuarioLogado()).thenAnswer(
      (_) async => {'nome': 'Técnico Teste', 'perfil': 'tecnico'},
    );

    await tester.pumpWidget(MaterialApp(
      home: TutoriaisTela(authServico: mockAuthServico),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Cadastros'), findsOneWidget);
    expect(find.text('Agendamentos'), findsOneWidget);
    expect(find.text('Ordens de Serviço'), findsOneWidget);
    expect(find.text('Relatórios'), findsNothing);
  });

  testWidgets('Gestor deve ver todos os tutoriais incluindo os exclusivos',
      (WidgetTester tester) async {
    await pumpTela(tester);

    expect(find.text('Relatórios'), findsOneWidget);
    expect(find.text('Cadastros'), findsOneWidget);
  });
}
