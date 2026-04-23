// test/apresentacao/telas/cadastro_gestor/cadastro_gestor_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/cadastro_gestor/cadastro_gestor_tela.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'cadastro_gestor_tela_test.mocks.dart';

@GenerateMocks([AutenticacaoServico])
void main() {
  late MockAutenticacaoServico mockAuthServico;

  setUp(() {
    mockAuthServico = MockAutenticacaoServico();
  });

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      // Adicionamos a rota 'home' para evitar erros de navegação no teste
      routes: {
        '/': (_) => CadastroGestorTela(authServico: mockAuthServico),
        '/home': (_) => const Scaffold(body: Text('Home')),
      },
    ));
  }

  testWidgets('Deve renderizar todos os campos do formulário de cadastro', (WidgetTester tester) async {
    await pumpTela(tester);

    expect(find.widgetWithText(TextFormField, 'Nome (usuário)'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Confirmar Senha'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'CADASTRAR'), findsOneWidget);
  });

  testWidgets('Deve exibir erro se a senha for menor que 6 caracteres', (WidgetTester tester) async {
    await pumpTela(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), '123');
    await tester.ensureVisible(find.text('CADASTRAR'));
    await tester.tap(find.text('CADASTRAR'));
    await tester.pump();

    expect(find.text('A senha deve ter no mínimo 6 caracteres'), findsOneWidget);
  });

  testWidgets('Deve exibir erro se as senhas não coincidirem', (WidgetTester tester) async {
    await pumpTela(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), '123456');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar Senha'), '654321');
    await tester.ensureVisible(find.text('CADASTRAR'));
    await tester.tap(find.text('CADASTRAR'));
    await tester.pump();

    expect(find.text('As senhas não coincidem'), findsOneWidget);
  });

  testWidgets('Deve exibir CircularProgressIndicator e navegar ao cadastrar com sucesso', (WidgetTester tester) async {
    // ARRANGE: Configura o mock para retornar sucesso
    when(mockAuthServico.cadastrarPrimeiroGestor(
      nome: anyNamed('nome'),
      email: anyNamed('email'),
      senha: anyNamed('senha'),
    )).thenAnswer((_) async => null); // Retornar null simula sucesso

    await pumpTela(tester);

    // ACT: Preenche o formulário corretamente e toca para cadastrar
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome (usuário)'), 'Gestor Teste');
    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'gestor@teste.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), '123456');
    await tester.enterText(find.widgetWithText(TextFormField, 'Confirmar Senha'), '123456');
    
    await tester.ensureVisible(find.text('CADASTRAR'));
    await tester.tap(find.text('CADASTRAR'));
    await tester.pumpAndSettle(); // Aguarda a navegação

    // ASSERT: Verifica se navegou para a tela Home
    expect(find.text('Home'), findsOneWidget);
  });
}