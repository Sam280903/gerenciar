// test/apresentacao/telas/formas_pagamento/formas_pagamento_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/formas_pagamento/formas_pagamento_tela.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/listar_formas_pagamento.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'formas_pagamento_tela_test.mocks.dart';

@GenerateMocks([ListarFormasPagamento])
void main() {
  late MockListarFormasPagamento mockListarFormasPagamento;

  final mockFormasPagamento = [
    FormaPagamento(id: '1', nome: 'Dinheiro', descricao: 'Pagamento em espécie', ativo: true),
    FormaPagamento(id: '2', nome: 'Cartão de Crédito', descricao: 'Pagamento parcelado', ativo: true),
  ];

  setUp(() {
    mockListarFormasPagamento = MockListarFormasPagamento();
  });

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: FormasPagamentoTela(
        listarFormasPagamento: mockListarFormasPagamento,
      ),
    ));
  }

  testWidgets('Deve exibir a lista de formas de pagamento após o carregamento', (WidgetTester tester) async {
    // ARRANGE
    when(mockListarFormasPagamento.executar(incluirInativos: anyNamed('incluirInativos')))
        .thenAnswer((_) async => mockFormasPagamento);

    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    // ASSERT
    expect(find.text('Dinheiro'), findsOneWidget);
    expect(find.text('Cartão de Crédito'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.widgetWithText(FloatingActionButton, 'NOVA FORMA'), findsOneWidget);
  });

  testWidgets('Deve exibir mensagem quando a lista de formas de pagamento está vazia', (WidgetTester tester) async {
    // ARRANGE
    when(mockListarFormasPagamento.executar(incluirInativos: anyNamed('incluirInativos')))
        .thenAnswer((_) async => []);

    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    // ASSERT
    expect(find.text('Nenhuma forma de pagamento ativa.'), findsOneWidget);
  });

  testWidgets('Deve filtrar a lista ao digitar no campo de busca', (WidgetTester tester) async {
    // ARRANGE
    when(mockListarFormasPagamento.executar(incluirInativos: anyNamed('incluirInativos')))
        .thenAnswer((_) async => mockFormasPagamento);

    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    expect(find.text('Dinheiro'), findsOneWidget);
    expect(find.text('Cartão de Crédito'), findsOneWidget);

    // Digita no campo de busca
    await tester.enterText(find.byType(TextField), 'Dinheiro');
    await tester.pumpAndSettle();

    // ASSERT
    expect(find.text('Dinheiro'), findsOneWidget);
    expect(find.text('Cartão de Crédito'), findsNothing);
  });
}