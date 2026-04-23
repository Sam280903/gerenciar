// test/apresentacao/telas/formas_pagamento/detalhes_forma_pagamento_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/formas_pagamento/detalhes_forma_pagamento_tela.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/inativar_forma_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/reativar_forma_pagamento.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'detalhes_forma_pagamento_tela_test.mocks.dart';

@GenerateMocks([InativarFormaPagamento, ReativarFormaPagamento])
void main() {
  late MockInativarFormaPagamento mockInativar;
  late MockReativarFormaPagamento mockReativar;

  final formaPagamento = FormaPagamento(
    id: 'fp-1',
    nome: 'PIX',
    descricao: 'Pagamento instantâneo',
    ativo: true,
    idGestor: 'gestor-1',
  );

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DetalhesFormaPagamentoTela(
        formaPagamento: formaPagamento,
        inativarFormaPagamento: mockInativar,
        reativarFormaPagamento: mockReativar,
      ),
    ));
  }

  setUp(() {
    mockInativar = MockInativarFormaPagamento();
    mockReativar = MockReativarFormaPagamento();
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
    when(mockInativar.executar(any)).thenAnswer((_) async {});
    await pumpTela(tester);

    await tester.tap(find.text('INATIVAR'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'INATIVAR'));
    await tester.pump();

    verify(mockInativar.executar(formaPagamento.id)).called(1);
  });
}
