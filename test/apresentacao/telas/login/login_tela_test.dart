// test/apresentacao/telas/login/login_tela_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/login/login_tela.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_tela_test.mocks.dart';

@GenerateMocks([AutenticacaoServico])
void main() {
  late MockAutenticacaoServico mockAuthServico;

  setUp(() {
    mockAuthServico = MockAutenticacaoServico();
  });

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: LoginTela(authServico: mockAuthServico),
    ));
  }

  testWidgets('Deve renderizar os componentes da tela de login',
      (WidgetTester tester) async {
    await pumpTela(tester);

    expect(find.byType(Image), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'ENTRAR'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Esqueci a senha'), findsOneWidget);
  });

  testWidgets('Deve exibir mensagens de erro para campos vazios',
      (WidgetTester tester) async {
    await pumpTela(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'ENTRAR'));
    await tester.pump();

    expect(find.text('Informe o e-mail'), findsOneWidget);
    expect(find.text('Informe a senha'), findsOneWidget);
  });

  testWidgets('Deve exibir o CircularProgressIndicator ao tentar fazer login',
      (WidgetTester tester) async {
    when(mockAuthServico.login(any, any))
        .thenAnswer((_) async => null);

    await pumpTela(tester);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'), 'teste@teste.com');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'), '123456');

    await tester.tap(find.widgetWithText(ElevatedButton, 'ENTRAR'));
    await tester.pump();

    verify(mockAuthServico.login('teste@teste.com', '123456')).called(1);
  });
}
