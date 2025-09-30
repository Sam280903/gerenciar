// test/apresentacao/telas/tecnicos/tecnicos_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/tecnicos/tecnicos_tela.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/listar_tecnicos.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Importa o arquivo que será gerado pelo Mockito
import 'tecnicos_tela_test.mocks.dart';

// Gera os Mocks para as classes de serviço
@GenerateMocks([ListarTecnicos, AutenticacaoServico])
void main() {
  // Declara os mocks que serão usados nos testes
  late MockListarTecnicos mockListarTecnicos;
  late MockAutenticacaoServico mockAutenticacaoServico;

  // Dados de exemplo para simular a resposta do serviço
  final mockTecnicos = [
    Tecnico(id: '1', nome: 'Flávio Amorim', email: 'flavio@email.com', telefone: '64999999999', ativo: true),
    Tecnico(id: '2', nome: 'Samuel Augusto', email: 'samuel@email.com', telefone: '64888888888', ativo: true),
  ];

  // O `setUp` é executado antes de cada teste, garantindo um ambiente limpo
  setUp(() {
    mockListarTecnicos = MockListarTecnicos();
    mockAutenticacaoServico = MockAutenticacaoServico();
  });

  // Função auxiliar para construir a tela com os mocks injetados
  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: TecnicosTela(
        listarTecnicos: mockListarTecnicos,
        authServico: mockAutenticacaoServico,
      ),
    ));
  }

  testWidgets('Deve exibir a lista de técnicos após o carregamento', (WidgetTester tester) async {
    // ARRANGE (Preparar): Configura o comportamento dos mocks
    when(mockAutenticacaoServico.buscarDadosUsuarioLogado()).thenAnswer((_) async => {'perfil': 'tecnico'});
    when(mockListarTecnicos.executar(incluirInativos: anyNamed('incluirInativos')))
        .thenAnswer((_) async => mockTecnicos);

    // ACT (Agir): Constrói a tela
    await pumpTela(tester);
    
    // Aguarda a UI ser reconstruída após o carregamento dos dados
    await tester.pumpAndSettle();

    // ASSERT (Verificar): Verifica se os nomes dos técnicos estão na tela
    expect(find.text('Flávio Amorim'), findsOneWidget);
    expect(find.text('Samuel Augusto'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Deve exibir o FloatingActionButton para o perfil gestor', (WidgetTester tester) async {
    // ARRANGE: Simula um usuário gestor e uma lista vazia de técnicos
    when(mockAutenticacaoServico.buscarDadosUsuarioLogado()).thenAnswer((_) async => {'perfil': 'gestor'});
    when(mockListarTecnicos.executar(incluirInativos: anyNamed('incluirInativos')))
        .thenAnswer((_) async => []);

    // ACT: Constrói a tela
    await pumpTela(tester);
    await tester.pumpAndSettle();

    // ASSERT: Verifica se o botão "NOVO TÉCNICO" está visível
    expect(find.widgetWithText(FloatingActionButton, 'NOVO TÉCNICO'), findsOneWidget);
  });

  testWidgets('NÃO deve exibir o FloatingActionButton para o perfil técnico', (WidgetTester tester) async {
    // ARRANGE: Simula um usuário técnico e uma lista vazia
    when(mockAutenticacaoServico.buscarDadosUsuarioLogado()).thenAnswer((_) async => {'perfil': 'tecnico'});
    when(mockListarTecnicos.executar(incluirInativos: anyNamed('incluirInativos')))
        .thenAnswer((_) async => []);

    // ACT: Constrói a tela
    await pumpTela(tester);
    await tester.pumpAndSettle();

    // ASSERT: Verifica se o botão não está visível
    expect(find.byType(FloatingActionButton), findsNothing);
  });

  testWidgets('Deve filtrar a lista de técnicos ao digitar no campo de busca', (WidgetTester tester) async {
    // ARRANGE: Simula uma lista de técnicos
    when(mockAutenticacaoServico.buscarDadosUsuarioLogado()).thenAnswer((_) async => {'perfil': 'tecnico'});
    when(mockListarTecnicos.executar(incluirInativos: anyNamed('incluirInativos')))
        .thenAnswer((_) async => mockTecnicos);

    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    // Verifica que ambos os técnicos estão visíveis inicialmente
    expect(find.text('Flávio Amorim'), findsOneWidget);
    expect(find.text('Samuel Augusto'), findsOneWidget);

    // Digita "Flávio" no campo de busca
    await tester.enterText(find.byType(TextField), 'Flávio');
    await tester.pumpAndSettle();

    // ASSERT: Verifica que apenas o "Flávio" está visível
    expect(find.text('Flávio Amorim'), findsOneWidget);
    expect(find.text('Samuel Augusto'), findsNothing);
  });
}