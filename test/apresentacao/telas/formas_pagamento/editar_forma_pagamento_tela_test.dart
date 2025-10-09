// test/apresentacao/telas/formas_pagamento/editar_forma_pagamento_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/formas_pagamento/editar_forma_pagamento_tela.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/atualizar_forma_pagamento.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'editar_forma_pagamento_tela_test.mocks.dart';

@GenerateMocks([AtualizarFormaPagamento])
void main() {
  late MockAtualizarFormaPagamento mockAtualizarFormaPagamento;

  final formaPagamento = FormaPagamento(
    id: 'fp-1',
    nome: 'Nome Original',
    descricao: 'Desc Original',
    ativo: true,
    idGestor: 'g1',
  );

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) =>
                    EditarFormaPagamentoTela(formaPagamento: formaPagamento),
              );
            },
            child: const Text('Abrir Modal'),
          ),
        ),
      ),
    ));
  }

  setUp(() {
    mockAtualizarFormaPagamento = MockAtualizarFormaPagamento();
  });

  testWidgets('Deve chamar o método de atualizar ao salvar',
      (WidgetTester tester) async {
    when(mockAtualizarFormaPagamento.executar(any)).thenAnswer((_) async {});
    await pumpTela(tester);

    // Abre o modal
    await tester.tap(find.text('Abrir Modal'));
    await tester.pumpAndSettle();

    // Verifica se os campos estão preenchidos
    expect(find.text('Nome Original'), findsOneWidget);

    // Modifica o nome
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'), 'Nome Modificado');
    await tester.tap(find.text('SALVAR ALTERAÇÕES'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // // Verifica a chamada ao mock
    verify(mockAtualizarFormaPagamento.executar(argThat(
      isA<FormaPagamento>().having((fp) => fp.nome, 'nome', 'Nome Modificado'),
    ))).called(1);
  });
}
