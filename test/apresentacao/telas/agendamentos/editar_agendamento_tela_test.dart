// test/apresentacao/telas/agendamentos/editar_agendamento_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/agendamentos/editar_agendamento_tela.dart';
import 'package:gerenciar/dados/repositorios/agendamento/agendamento_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/atualizar_agendamento.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'agendamentos_tela_test.mocks.dart';
import 'detalhes_agendamento_tela_test.mocks.dart';

@GenerateMocks([AtualizarAgendamento, AgendamentoRepositorioAdaptativo])
void main() {
  late MockAtualizarAgendamento mockAtualizarAgendamento;
  late MockAgendamentoRepositorioAdaptativo mockAgendamentoRepo;

  final agendamentoParaEditar = Agendamento(
    id: 'ag-edit-1',
    idTecnico: 't1',
    idCliente: 'c1',
    idGestor: 'g1',
    dataHora: DateTime(2025, 10, 20, 14, 30),
    observacao: 'Obs original',
    status: 'Pendente',
  );

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: EditarAgendamentoTela(
        agendamento: agendamentoParaEditar,
        atualizarAgendamento: mockAtualizarAgendamento,
        agendamentoRepo: mockAgendamentoRepo,
      ),
    ));
  }

  setUp(() {
    mockAtualizarAgendamento = MockAtualizarAgendamento();
    mockAgendamentoRepo = MockAgendamentoRepositorioAdaptativo();
    // Sem conflito por padrão
    when(mockAgendamentoRepo.verificarDisponibilidade(
      any, any,
      idExcluir: anyNamed('idExcluir'),
    )).thenAnswer((_) async => false);
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
    await tester.pumpAndSettle();

    verify(mockAtualizarAgendamento.executar(argThat(
      isA<Agendamento>()
          .having((ag) => ag.observacao, 'observacao', 'Obs modificada'),
    ))).called(1);
  });

  testWidgets('Deve bloquear salvamento quando houver conflito de horário',
      (WidgetTester tester) async {
    when(mockAgendamentoRepo.verificarDisponibilidade(
      any, any,
      idExcluir: anyNamed('idExcluir'),
    )).thenAnswer((_) async => true);

    await pumpTela(tester);
    await tester.tap(find.text('SALVAR ALTERAÇÕES'));
    await tester.pumpAndSettle();

    verifyNever(mockAtualizarAgendamento.executar(any));
    expect(
      find.text('Já existe atendimento agendado para este técnico neste horário.'),
      findsOneWidget,
    );
  });
}
