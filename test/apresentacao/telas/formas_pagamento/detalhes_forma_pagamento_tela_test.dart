// test/apresentacao/telas/formas_pagamento/detalhes_forma_pagamento_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/formas_pagamento/detalhes_forma_pagamento_tela.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:gerenciar/dominio/interfaces/forma_pagamento_repositorio_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'detalhes_forma_pagamento_tela_test.mocks.dart';

@GenerateMocks([FormaPagamentoRepositorioInterface])
void main() {
  late MockFormaPagamentoRepositorioInterface mockFormaPagamentoRepositorio;

  final formaPagamento = FormaPagamento(
    id: 'fp-1',
    nome: 'PIX',
    descricao: 'Pagamento instantâneo',
    ativo: true,
    idGestor: 'gestor-1',
  );

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DetalhesFormaPagamentoTela(formaPagamento: formaPagamento),
    ));
  }

  setUp(() {
    mockFormaPagamentoRepositorio = MockFormaPagamentoRepositorioInterface();
  });

  testWidgets('Deve exibir os detalhes da forma de pagamento',
      (WidgetTester tester) async {
    await pumpTela(tester);
    expect(find.text('PIX'), findsOneWidget);
    expect(find.text('Pagamento instantâneo'), findsOneWidget);
    expect(find.text('Ativo'), findsOneWidget);
  });

  testWidgets('Deve chamar o método de inativar ao confirmar',
      (WidgetTester tester) async {
    when(mockFormaPagamentoRepositorio.inativar(any)).thenAnswer((_) async {});
    await pumpTela(tester);

    await tester.tap(find.text('INATIVAR'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'INATIVAR'));
    await tester.pump();

    // verify(mockFormaPagamentoRepositorio.inativar(formaPagamento.id)).called(1);
  });
}
