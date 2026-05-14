// RF02 - Evitar agendamento duplicado para o mesmo técnico no mesmo horário
// RF06 - Agendamento de Atendimentos (listagem, busca, atualização)
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/cadastrar_agendamento.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/atualizar_agendamento.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/buscar_agendamento_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/listar_agendamentos.dart';

import 'cadastrar_agendamento_test.mocks.dart';

void main() {
  late MockAgendamentoRepositorioInterface mockRepositorio;
  late CadastrarAgendamento cadastrar;
  late AtualizarAgendamento atualizar;
  late BuscarAgendamentoPorId buscarPorId;
  late ListarAgendamentos listar;

  final dataHora = DateTime(2025, 10, 20, 14, 30);
  final dataHoraAlternativa = DateTime(2025, 10, 20, 16, 0);

  final agendamento = Agendamento(
    id: 'ag-1',
    idTecnico: 'tec-1',
    idCliente: 'cli-1',
    idGestor: 'gestor-1',
    dataHora: dataHora,
  );

  setUp(() {
    mockRepositorio = MockAgendamentoRepositorioInterface();
    cadastrar = CadastrarAgendamento(mockRepositorio);
    atualizar = AtualizarAgendamento(mockRepositorio);
    buscarPorId = BuscarAgendamentoPorId(mockRepositorio);
    listar = ListarAgendamentos(mockRepositorio);
  });

  group('RF02 - Evitar agendamento duplicado', () {
    test('Deve cadastrar quando horário estiver disponível', () async {
      when(mockRepositorio.verificarDisponibilidade(any, any))
          .thenAnswer((_) => Future.value(false));
      when(mockRepositorio.adicionar(any))
          .thenAnswer((_) => Future.value());

      await cadastrar.executar(agendamento);

      verify(mockRepositorio.verificarDisponibilidade('tec-1', dataHora));
      verify(mockRepositorio.adicionar(agendamento));
    });

    test('Deve bloquear cadastro quando técnico já tem atendimento no horário',
        () async {
      when(mockRepositorio.verificarDisponibilidade(any, any))
          .thenAnswer((_) => Future.value(true));

      await expectLater(
        () => cadastrar.executar(agendamento),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'mensagem',
          contains('Este técnico já possui um atendimento neste horário'),
        )),
      );

      verifyNever(mockRepositorio.adicionar(any));
    });

    test('Deve verificar disponibilidade com idTecnico e dataHora corretos',
        () async {
      when(mockRepositorio.verificarDisponibilidade(any, any))
          .thenAnswer((_) => Future.value(false));
      when(mockRepositorio.adicionar(any))
          .thenAnswer((_) => Future.value());

      await cadastrar.executar(agendamento);

      final captured = verify(mockRepositorio.verificarDisponibilidade(
              captureAny, captureAny))
          .captured;
      expect(captured[0], equals('tec-1'));
      expect(captured[1], equals(dataHora));
    });

    test('Deve chamar verificarDisponibilidade antes de adicionar', () async {
      final ordem = <String>[];

      when(mockRepositorio.verificarDisponibilidade(any, any))
          .thenAnswer((_) async {
        ordem.add('verificar');
        return false;
      });
      when(mockRepositorio.adicionar(any)).thenAnswer((_) async {
        ordem.add('adicionar');
      });

      await cadastrar.executar(agendamento);

      expect(ordem, equals(['verificar', 'adicionar']));
    });

    test('Dois técnicos diferentes podem ter agendamentos no mesmo horário',
        () async {
      final agendamentoTec2 = Agendamento(
        id: 'ag-2',
        idTecnico: 'tec-2',
        idCliente: 'cli-1',
        idGestor: 'gestor-1',
        dataHora: dataHora,
      );

      when(mockRepositorio.verificarDisponibilidade('tec-2', dataHora))
          .thenAnswer((_) => Future.value(false));
      when(mockRepositorio.adicionar(any))
          .thenAnswer((_) => Future.value());

      await cadastrar.executar(agendamentoTec2);

      verify(mockRepositorio.adicionar(agendamentoTec2));
    });

    test('Deve permitir o mesmo técnico em horário diferente', () async {
      final agendamentoNovoHorario = Agendamento(
        id: 'ag-3',
        idTecnico: 'tec-1',
        idCliente: 'cli-2',
        idGestor: 'gestor-1',
        dataHora: dataHoraAlternativa,
      );

      when(mockRepositorio.verificarDisponibilidade('tec-1', dataHoraAlternativa))
          .thenAnswer((_) => Future.value(false));
      when(mockRepositorio.adicionar(any))
          .thenAnswer((_) => Future.value());

      await cadastrar.executar(agendamentoNovoHorario);

      verify(mockRepositorio.adicionar(agendamentoNovoHorario));
    });

    test('Deve chamar adicionar exatamente uma vez quando disponível', () async {
      when(mockRepositorio.verificarDisponibilidade(any, any))
          .thenAnswer((_) => Future.value(false));
      when(mockRepositorio.adicionar(any))
          .thenAnswer((_) => Future.value());

      await cadastrar.executar(agendamento);

      verify(mockRepositorio.adicionar(any)).called(1);
    });

    test('Deve verificar disponibilidade exatamente uma vez por cadastro', () async {
      when(mockRepositorio.verificarDisponibilidade(any, any))
          .thenAnswer((_) => Future.value(false));
      when(mockRepositorio.adicionar(any))
          .thenAnswer((_) => Future.value());

      await cadastrar.executar(agendamento);

      verify(mockRepositorio.verificarDisponibilidade(any, any)).called(1);
    });

    test('Deve cadastrar agendamento com observação opcional', () async {
      final agendamentoComObs = Agendamento(
        id: 'ag-4',
        idTecnico: 'tec-1',
        idCliente: 'cli-1',
        idGestor: 'gestor-1',
        dataHora: dataHora,
        observacao: 'Levar kit de limpeza',
      );

      when(mockRepositorio.verificarDisponibilidade(any, any))
          .thenAnswer((_) => Future.value(false));
      when(mockRepositorio.adicionar(any))
          .thenAnswer((_) => Future.value());

      await cadastrar.executar(agendamentoComObs);

      verify(mockRepositorio.adicionar(agendamentoComObs));
    });
  });

  group('RF06 - Agendamento de Atendimentos', () {
    test('Deve listar agendamentos do gestor', () async {
      final lista = [agendamento];

      when(mockRepositorio.listarTodos(idGestor: anyNamed('idGestor')))
          .thenAnswer((_) => Future.value(lista));

      final resultado = await listar.executar(idGestor: 'gestor-1');

      expect(resultado, equals(lista));
      verify(mockRepositorio.listarTodos(idGestor: 'gestor-1'));
    });

    test('Deve retornar lista vazia quando não há agendamentos', () async {
      when(mockRepositorio.listarTodos(idGestor: anyNamed('idGestor')))
          .thenAnswer((_) => Future.value([]));

      final resultado = await listar.executar(idGestor: 'gestor-1');

      expect(resultado, isEmpty);
    });

    test('Deve buscar agendamento por id', () async {
      when(mockRepositorio.buscarPorId(any))
          .thenAnswer((_) => Future.value(agendamento));

      final resultado = await buscarPorId.executar('ag-1');

      expect(resultado, equals(agendamento));
      verify(mockRepositorio.buscarPorId('ag-1'));
    });

    test('Deve retornar null quando agendamento não for encontrado', () async {
      when(mockRepositorio.buscarPorId(any))
          .thenAnswer((_) => Future.value(null));

      final resultado = await buscarPorId.executar('ag-inexistente');

      expect(resultado, isNull);
    });

    test('Deve atualizar agendamento existente', () async {
      when(mockRepositorio.atualizar(any))
          .thenAnswer((_) => Future.value());

      await atualizar.executar(agendamento);

      verify(mockRepositorio.atualizar(agendamento));
    });

  });
}
