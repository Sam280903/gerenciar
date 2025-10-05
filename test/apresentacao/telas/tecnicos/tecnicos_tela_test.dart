// test/apresentacao/telas/tecnicos/tecnicos_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/tecnicos/tecnicos_tela.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/listar_tecnicos.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'tecnicos_tela_test.mocks.dart';

@GenerateMocks([ListarTecnicos, AutenticacaoServico])
void main() {
  late MockListarTecnicos mockListarTecnicos;
  late MockAutenticacaoServico mockAutenticacaoServico;

  // DADOS ATUALIZADOS
  final mockTecnicos = [
    Tecnico(
        id: '1',
        nome: 'Flávio Amorim',
        email: 'flavio@email.com',
        telefone: '64999999999',
        ativo: true,
        idGestor: 'gestor-1'),
    Tecnico(
        id: '2',
        nome: 'Samuel Augusto',
        email: 'samuel@email.com',
        telefone: '64888888888',
        ativo: true,
        idGestor: 'gestor-1'),
  ];

  setUp(() {
    mockListarTecnicos = MockListarTecnicos();
    mockAutenticacaoServico = MockAutenticacaoServico();
  });

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TecnicosTela(
        listarTecnicos: mockListarTecnicos,
        authServico: mockAutenticacaoServico,
      ),
    ));
  }

  testWidgets('Deve exibir a lista de técnicos após o carregamento',
      (WidgetTester tester) async {
    // ARRANGE - CORRIGIDO
    when(mockAutenticacaoServico.buscarDadosUsuarioLogado())
        .thenAnswer((_) async => {'perfil': 'tecnico', 'idGestor': 'gestor-1'});
    when(mockListarTecnicos.executar(
            idGestor: anyNamed('idGestor'),
            incluirInativos: anyNamed('incluirInativos')))
        .thenAnswer((_) async => mockTecnicos);

    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    // ASSERT
    expect(find.text('Flávio Amorim'), findsOneWidget);
    expect(find.text('Samuel Augusto'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Deve exibir o FloatingActionButton para o perfil gestor',
      (WidgetTester tester) async {
    // ARRANGE - CORRIGIDO
    when(mockAutenticacaoServico.buscarDadosUsuarioLogado())
        .thenAnswer((_) async => {'perfil': 'gestor', 'idGestor': 'gestor-1'});
    when(mockListarTecnicos.executar(
            idGestor: anyNamed('idGestor'),
            incluirInativos: anyNamed('incluirInativos')))
        .thenAnswer((_) async => []);

    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    // ASSERT
    expect(find.widgetWithText(FloatingActionButton, 'NOVO TÉCNICO'),
        findsOneWidget);
  });

  testWidgets('NÃO deve exibir o FloatingActionButton para o perfil técnico',
      (WidgetTester tester) async {
    // ARRANGE - CORRIGIDO
    when(mockAutenticacaoServico.buscarDadosUsuarioLogado())
        .thenAnswer((_) async => {'perfil': 'tecnico', 'idGestor': 'gestor-1'});
    when(mockListarTecnicos.executar(
            idGestor: anyNamed('idGestor'),
            incluirInativos: anyNamed('incluirInativos')))
        .thenAnswer((_) async => []);

    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    // ASSERT
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('Deve filtrar a lista de técnicos ao digitar no campo de busca',
      (WidgetTester tester) async {
    // ARRANGE - CORRIGIDO
    when(mockAutenticacaoServico.buscarDadosUsuarioLogado())
        .thenAnswer((_) async => {'perfil': 'tecnico', 'idGestor': 'gestor-1'});
    when(mockListarTecnicos.executar(
            idGestor: anyNamed('idGestor'),
            incluirInativos: anyNamed('incluirInativos')))
        .thenAnswer((_) async => mockTecnicos);

    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    expect(find.text('Flávio Amorim'), findsOneWidget);
    expect(find.text('Samuel Augusto'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Flávio');
    await tester.pumpAndSettle();

    // ASSERT
    expect(find.text('Flávio Amorim'), findsOneWidget);
    expect(find.text('Samuel Augusto'), findsNothing);
  });
}
