// test/apresentacao/telas/agendamentos/editar_agendamento_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/agendamentos/editar_agendamento_tela.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/atualizar_agendamento.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'detalhes_agendamento_tela_test.mocks.dart';

@GenerateMocks([AtualizarAgendamento])
void main() {
  late MockAtualizarAgendamento mockAtualizarAgendamento;

  final agendamentoParaEditar = Agendamento(
    id: 'ag-edit-1',
    idTecnico: 't1',
    idCliente: 'c1',
    idGestor: 'g1',
    dataHora: DateTime(2025, 10, 20, 14, 30),
    observacao: 'Obs original',
    status: 'Pendente',
    ativo: true,
  );

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: EditarAgendamentoTela(agendamento: agendamentoParaEditar),
    ));
  }

  setUp(() {
    mockAtualizarAgendamento = MockAtualizarAgendamento();
  });

  testWidgets('Deve preencher os campos com os dados do agendamento',
      (WidgetTester tester) async {
    await pumpTela(tester);

    expect(find.text('20/10/2025'), findsOneWidget);
    expect(find.text('Obs original'), findsOneWidget);
  });

  testWidgets('Deve chamar o método de atualizar ao salvar',
      (WidgetTester tester) async {
    when(mockAtualizarAgendamento.executar(any)).thenAnswer((_) async {});
    await pumpTela(tester);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Observações'), 'Obs modificada');
    await tester.tap(find.text('SALVAR ALTERAÇÕES'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Verifica a chamada ao mock
    verify(mockAtualizarAgendamento.executar(argThat(
      isA<Agendamento>()
          .having((ag) => ag.observacao, 'observacao', 'Obs modificada'),
    ))).called(1);
  });
}
