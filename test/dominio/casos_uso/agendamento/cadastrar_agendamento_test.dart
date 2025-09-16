// test/dominio/casos_uso/agendamento/cadastrar_agendamento_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/cadastrar_agendamento.dart';
import 'package:gerenciar/dominio/interfaces/agendamento_repositorio_interface.dart';

import 'cadastrar_agendamento_test.mocks.dart';

@GenerateMocks([AgendamentoRepositorioInterface])
void main() {
  late MockAgendamentoRepositorioInterface mockRepositorio;
  late CadastrarAgendamento casoDeUso;

  setUp(() {
    mockRepositorio = MockAgendamentoRepositorioInterface();
    casoDeUso = CadastrarAgendamento(mockRepositorio);
  });

  final agendamentoExemplo = Agendamento(
    id: 'ag-1',
    idTecnico: 'tec-1',
    idCliente: 'cli-1',
    dataHora: DateTime(2025, 10, 20, 14, 30),
    ativo: true,
  );

  test('Deve cadastrar um agendamento com sucesso se o horário estiver livre',
      () async {
    // Arrange: Configura o mock para retornar 'false' (horário livre)
    when(mockRepositorio.verificarDisponibilidade(any, any))
        .thenAnswer((_) async => false);
    // Configura o mock para o método de adicionar
    when(mockRepositorio.adicionar(any)).thenAnswer((_) async {});

    // Act: Executa o caso de uso
    await casoDeUso.executar(agendamentoExemplo);

    // Assert: Verifica se ambos os métodos foram chamados
    verify(mockRepositorio.verificarDisponibilidade(
        agendamentoExemplo.idTecnico, agendamentoExemplo.dataHora));
    verify(mockRepositorio.adicionar(agendamentoExemplo));
    verifyNoMoreInteractions(mockRepositorio);
  });

  test(
      'Deve lançar uma exceção se o técnico já tiver um agendamento no mesmo horário',
      () async {
    // Arrange: Configura o mock para retornar 'true' (horário ocupado)
    when(mockRepositorio.verificarDisponibilidade(any, any))
        .thenAnswer((_) async => true);

    // Act & Assert: Verifica se a execução lança a exceção esperada
    expect(
      () => casoDeUso.executar(agendamentoExemplo),
      throwsA(isA<Exception>().having(
        (e) => e.toString(),
        'message',
        contains('Este técnico já possui um atendimento neste horário'),
      )),
    );

    // Verifica que o método 'adicionar' NUNCA foi chamado
    verify(mockRepositorio.verificarDisponibilidade(
        agendamentoExemplo.idTecnico, agendamentoExemplo.dataHora));
    verifyNever(mockRepositorio.adicionar(any));
    verifyNoMoreInteractions(mockRepositorio);
  });
}
