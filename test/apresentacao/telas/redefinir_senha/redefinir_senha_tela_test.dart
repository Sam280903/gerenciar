// test/apresentacao/telas/redefinir_senha/redefinir_senha_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/redefinir_senha/redefinir_senha_tela.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'redefinir_senha_tela_test.mocks.dart';

@GenerateMocks([AutenticacaoServico])
void main() {
  late MockAutenticacaoServico mockAuthServico;

  setUp(() {
    mockAuthServico = MockAutenticacaoServico();
  });

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RedefinirSenhaTela(
        authServico: mockAuthServico,
      ),
    ));
  }

  testWidgets('Deve exibir mensagem de sucesso ao enviar o e-mail', (WidgetTester tester) async {
    // ARRANGE
    when(mockAuthServico.enviarEmailRedefinicaoSenha(any))
        .thenAnswer((_) async {});

    await pumpTela(tester);

    // ACT
    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'teste@teste.com');
    await tester.tap(find.text('ENVIAR E-MAIL'));
    await tester.pump(); // Inicia o carregamento
    
    // ASSERT: Verifica o indicador de progresso
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle(); // Conclui a ação

    // ASSERT: Verifica a mensagem de sucesso
    expect(find.text('E-mail de redefinição enviado! Verifique sua caixa de entrada.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Deve exibir mensagem de erro se o e-mail não for encontrado', (WidgetTester tester) async {
    // ARRANGE
    when(mockAuthServico.enviarEmailRedefinicaoSenha(any))
        .thenThrow(Exception('Nenhum usuário encontrado para este e-mail.'));

    await pumpTela(tester);

    // ACT
    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'erro@teste.com');
    await tester.tap(find.text('ENVIAR E-MAIL'));
    await tester.pumpAndSettle();

    // ASSERT
    expect(find.text('Nenhum usuário encontrado para este e-mail.'), findsOneWidget);
  });

  testWidgets('Deve exibir erro de validação para e-mail vazio', (WidgetTester tester) async {
    await pumpTela(tester);

    await tester.tap(find.text('ENVIAR E-MAIL'));
    await tester.pump();

    expect(find.text('Informe o e-mail'), findsOneWidget);
  });
}