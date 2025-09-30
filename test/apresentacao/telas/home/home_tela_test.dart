// test/apresentacao/telas/home/home_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/home/home_tela.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_tela_test.mocks.dart';

@GenerateMocks([AutenticacaoServico])
void main() {
  late MockAutenticacaoServico mockAuthServico;

  setUp(() {
    mockAuthServico = MockAutenticacaoServico();
  });

  Future<void> pumpTela(WidgetTester tester) async {
    // Para testar a Home, precisamos definir as rotas que ela pode acessar
    // para evitar erros de navegação.
    await tester.pumpWidget(MaterialApp(
      routes: {
        '/': (_) => HomeTela(authServico: mockAuthServico),
        '/ordens-servico': (_) => const Scaffold(body: Text('Ordens')),
        '/tecnicos': (_) => const Scaffold(body: Text('Técnicos')),
        '/agendamentos': (_) => const Scaffold(body: Text('Agendamentos')),
        '/clientes': (_) => const Scaffold(body: Text('Clientes')),
        '/relatorios': (_) => const Scaffold(body: Text('Relatórios')),
        '/tutoriais': (_) => const Scaffold(body: Text('Tutoriais')),
        '/formas-pagamento': (_) => const Scaffold(body: Text('Pagamentos')),
        '/suporte': (_) => const Scaffold(body: Text('Suporte')),
        '/login': (_) => const Scaffold(body: Text('Login')),
      },
    ));
  }

  testWidgets('Deve exibir o nome do usuário e o perfil "gestor"', (WidgetTester tester) async {
    // ARRANGE: Simula o retorno dos dados de um usuário gestor
    when(mockAuthServico.buscarDadosUsuarioLogado())
        .thenAnswer((_) async => {'nome': 'Gestor Teste', 'perfil': 'gestor'});

    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    // ASSERT
    expect(find.text('Olá, Gestor Teste'), findsOneWidget);
    expect(find.text('Perfil: gestor'), findsOneWidget);
  });

  testWidgets('Deve exibir o item de menu "Técnicos" para o perfil gestor', (WidgetTester tester) async {
    // ARRANGE: Simula um usuário gestor
    when(mockAuthServico.buscarDadosUsuarioLogado())
        .thenAnswer((_) async => {'perfil': 'gestor'});

    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    // ASSERT: Verifica se o item "Técnicos" está na tela
    expect(find.text('Técnicos'), findsOneWidget);
  });

  testWidgets('NÃO deve exibir o item de menu "Técnicos" para o perfil técnico', (WidgetTester tester) async {
    // ARRANGE: Simula um usuário técnico
    when(mockAuthServico.buscarDadosUsuarioLogado())
        .thenAnswer((_) async => {'perfil': 'tecnico'});
        
    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    // ASSERT: Verifica se o item "Técnicos" NÃO está na tela
    expect(find.text('Técnicos'), findsNothing);
  });

  testWidgets('Deve navegar para a tela de Ordens de Serviço', (WidgetTester tester) async {
    // ARRANGE
    when(mockAuthServico.buscarDadosUsuarioLogado()).thenAnswer((_) async => {});
    
    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('Ordens de Serviço'));
    await tester.pumpAndSettle();

    // ASSERT
    expect(find.text('Ordens'), findsOneWidget);
  });
}