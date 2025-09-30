// test/apresentacao/telas/boas_vindas/boas_vindas_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/boas_vindas/boas_vindas_tela.dart';
import 'package:gerenciar/app/rotas.dart';

void main() {
  // Um grupo de testes para a BoasVindasTela
  group('BoasVindasTela', () {
    testWidgets('Deve renderizar todos os componentes principais da tela',
        (WidgetTester tester) async {
      // ARRANGE: Constrói a tela de boas-vindas.
      // É preciso envolvê-la em um MaterialApp para que tenha acesso a temas e navegação.
      await tester.pumpWidget(MaterialApp(
        // Define uma rota "dummy" para evitar erros de navegação nos testes.
        routes: {
          Rotas.cadastroGestor: (_) => const Scaffold(body: Text('Cadastro')),
          Rotas.login: (_) => const Scaffold(body: Text('Login')),
        },
        home: const BoasVindasTela(),
      ));

      // ACT & ASSERT
      // Verifica se a imagem do logo está na tela.
      expect(find.byType(Image), findsOneWidget);

      // Verifica se os textos de boas-vindas são exibidos.
      expect(find.text('Bem-vindo ao GerenciAR'), findsOneWidget);
      expect(
          find.text(
              'Seu assistente para gestão de serviços de climatização.'),
          findsOneWidget);

      // Verifica se os dois botões de ação estão visíveis.
      expect(find.widgetWithText(ElevatedButton, 'PRIMEIRO ACESSO'),
          findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'JÁ TENHO CADASTRO'),
          findsOneWidget);
    });

    testWidgets('Deve navegar para a tela de cadastro ao tocar em "PRIMEIRO ACESSO"',
        (WidgetTester tester) async {
      // ARRANGE
      await tester.pumpWidget(MaterialApp(
        routes: {
          '/': (_) => const BoasVindasTela(), // Rota inicial
          Rotas.cadastroGestor: (_) =>
              const Scaffold(body: Center(child: Text('Tela de Cadastro'))),
        },
      ));

      // ACT: Toca no botão de primeiro acesso.
      await tester.tap(find.text('PRIMEIRO ACESSO'));
      // Aguarda a animação de transição da tela terminar.
      await tester.pumpAndSettle();

      // ASSERT: Verifica se a tela de cadastro foi exibida.
      expect(find.text('Tela de Cadastro'), findsOneWidget);
    });

    testWidgets('Deve navegar para a tela de login ao tocar em "JÁ TENHO CADASTRO"',
        (WidgetTester tester) async {
      // ARRANGE
      await tester.pumpWidget(MaterialApp(
        routes: {
          '/': (_) => const BoasVindasTela(), // Rota inicial
          Rotas.login: (_) =>
              const Scaffold(body: Center(child: Text('Tela de Login'))),
        },
      ));

      // ACT: Toca no botão de login.
      await tester.tap(find.text('JÁ TENHO CADASTRO'));
      await tester.pumpAndSettle();

      // ASSERT: Verifica se a tela de login foi exibida.
      expect(find.text('Tela de Login'), findsOneWidget);
    });
  });
}