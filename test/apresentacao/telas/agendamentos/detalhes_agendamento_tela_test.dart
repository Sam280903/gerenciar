// test/apresentacao/telas/agendamentos/detalhes_agendamento_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/agendamentos/detalhes_agendamento_tela.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/atualizar_agendamento.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'detalhes_agendamento_tela_test.mocks.dart';

@GenerateMocks([AtualizarAgendamento])
void main() {
  late MockAtualizarAgendamento mockAtualizarAgendamento;

  final agendamentoPendente = Agendamento(
    id: 'ag-1',
    idTecnico: 't1',
    idCliente: 'c1',
    idGestor: 'g1',
    dataHora: DateTime.now().add(const Duration(days: 1)),
    observacao: 'Verificar barulho estranho',
    status: 'Pendente',
    ativo: true,
  );

  Future<void> pumpTela(WidgetTester tester, Agendamento agendamento) async {
    await tester.pumpWidget(MaterialApp(
      home: DetalhesAgendamentoTela(
        agendamento: agendamento,
        atualizarAgendamento: mockAtualizarAgendamento,
      ),
    ));
  }

  setUp(() {
    mockAtualizarAgendamento = MockAtualizarAgendamento();
  });

  testWidgets(
      'Deve exibir os detalhes e os botões de ação para um agendamento Pendente',
      (WidgetTester tester) async {
    await pumpTela(tester, agendamentoPendente);

    expect(find.text('Pendente'), findsOneWidget);
    expect(find.text('Verificar barulho estranho'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'CONFIRMAR'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'CANCELAR'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'INATIVAR'), findsOneWidget);
  });

  testWidgets('Deve chamar o método de atualizar status ao tocar em CONFIRMAR',
      (WidgetTester tester) async {
    when(mockAtualizarAgendamento.executar(any)).thenAnswer((_) async {});
    await pumpTela(tester, agendamentoPendente);

    await tester.ensureVisible(find.text('CONFIRMAR'));
    await tester.tap(find.text('CONFIRMAR'));
    await tester.pumpAndSettle(); // Abre o diálogo

    expect(find.text('Confirmar Alteração de Status'), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'CONFIRMAR'));
    await tester.pump();

    // Verifica se o caso de uso foi chamado com o status correto
    verify(mockAtualizarAgendamento.executar(argThat(
      isA<Agendamento>().having((ag) => ag.status, 'status', 'Confirmado'),
    ))).called(1);
  });
}
