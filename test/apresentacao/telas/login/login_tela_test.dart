// test/apresentacao/telas/login/login_tela_test.dart

import 'package:flutter/material.dart';
import 'package.flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/login/login_tela.dart';

void main() {
  // Teste para verificar se a tela de login é construída corretamente
  testWidgets('Deve renderizar os componentes da tela de login',
      (WidgetTester tester) async {
    // Envolve a LoginTela com um MaterialApp para fornecer o contexto necessário
    await tester.pumpWidget(const MaterialApp(home: LoginTela()));

    // Procura por um widget do tipo Image
    expect(find.byType(Image), findsOneWidget);

    // Procura pelos campos de texto de e-mail e senha
    expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);

    // Procura pelo botão "ENTRAR"
    expect(find.widgetWithText(ElevatedButton, 'ENTRAR'), findsOneWidget);

    // Procura pelo botão "Esqueci a senha"
    expect(find.widgetWithText(TextButton, 'Esqueci a senha'), findsOneWidget);
  });

  // Teste para validar os campos de e-mail e senha
  testWidgets('Deve exibir mensagens de erro para campos vazios',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginTela()));

    // Tenta tocar no botão "ENTRAR" sem preencher os campos
    await tester.tap(find.widgetWithText(ElevatedButton, 'ENTRAR'));

    // Aguarda a reconstrução da UI para exibir as mensagens de erro
    await tester.pump();

    // Verifica se as mensagens de erro são exibidas
    expect(find.text('Informe o e-mail'), findsOneWidget);
    expect(find.text('Informe a senha'), findsOneWidget);
  });

  // Teste para verificar o indicador de carregamento
  testWidgets('Deve exibir o CircularProgressIndicator ao tentar fazer login',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginTela()));

    // Preenche os campos de e-mail e senha
    await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'), 'teste@teste.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'), '123456');

    // Toca no botão "ENTRAR"
    await tester.tap(find.widgetWithText(ElevatedButton, 'ENTRAR'));

    // Aguarda a reconstrução da UI
    await tester.pump();

    // Verifica se o CircularProgressIndicator é exibido
    // Nota: Este teste assume que o login não será concluído instantaneamente
    // e que o estado de carregamento será ativado.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}