// test/apresentacao/telas/ordens_servico/editar_os_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/ordens_servico/editar_os_tela.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/atualizar_ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'editar_os_tela_test.mocks.dart';

@GenerateMocks([AtualizarOrdemServico])
void main() {
  late MockAtualizarOrdemServico mockAtualizarOS;

  final osParaEditar = OrdemServico(
    id: 'os-edit-1',
    idCliente: 'c1',
    idTecnico: 't1',
    idFormaPagamento: 'fp1',
    idGestor: 'gestor-1',
    dataHoraInicio: DateTime.now(),
    descricao: 'Descrição Original',
    valor: 100.0,
    prioridade: 'Média',
    status: 'Pendente',
    ativo: true,
  );

  // CORREÇÃO: A função agora injeta o mock na tela
  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: EditarOSTela(
        ordemServico: osParaEditar,
        atualizarOS: mockAtualizarOS, // Injetando o mock!
      ),
    ));
  }

  setUp(() {
    mockAtualizarOS = MockAtualizarOrdemServico();
  });

  testWidgets('Deve preencher os campos com os dados da OS',
      (WidgetTester tester) async {
    await pumpTela(tester);

    expect(find.text('Descrição Original'), findsOneWidget);
    expect(find.text('100.00'), findsOneWidget);

    final dropdownFinder = find.widgetWithText(InputDecorator, 'Prioridade');
    expect(find.descendant(of: dropdownFinder, matching: find.text('Média')),
        findsOneWidget);
  });

  testWidgets('Deve chamar o método de atualizar ao salvar',
      (WidgetTester tester) async {
    when(mockAtualizarOS.executar(any)).thenAnswer((_) async {});
    await pumpTela(tester);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Descrição do Problema'),
        'Descrição Modificada');
    await tester.pump();

    await tester.tap(find.text('SALVAR ALTERAÇÕES'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Agora esta verificação funcionará corretamente!
    verify(mockAtualizarOS.executar(argThat(
      isA<OrdemServico>()
          .having((os) => os.descricao, 'descricao', 'Descrição Modificada'),
    ))).called(1);
  });
}
