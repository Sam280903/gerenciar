// Testes de fluxo — RF02 e RF06: agendamento e prevenção de conflitos
// Sem mocks: usa repositório real em memória
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/cadastrar_agendamento.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/atualizar_agendamento.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/buscar_agendamento_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/listar_agendamentos.dart';

import '../helpers/agendamento_repositorio_memoria.dart';

void main() {
  late AgendamentoRepositorioMemoria repositorio;
  late CadastrarAgendamento cadastrar;
  late AtualizarAgendamento atualizar;
  late BuscarAgendamentoPorId buscarPorId;
  late ListarAgendamentos listar;

  final dataHora = DateTime(2025, 10, 20, 14, 30);

  setUp(() {
    repositorio = AgendamentoRepositorioMemoria();
    cadastrar = CadastrarAgendamento(repositorio);
    atualizar = AtualizarAgendamento(repositorio);
    buscarPorId = BuscarAgendamentoPorId(repositorio);
    listar = ListarAgendamentos(repositorio);
  });

  group('Fluxo — Cadastro e listagem de agendamentos (RF06)', () {
    test('Cadastrar agendamento e encontrá-lo na listagem', () async {
      final ag = Agendamento(
          id: 'ag-1', idTecnico: 'tec-1', idCliente: 'cli-1',
          idGestor: 'gestor-1', dataHora: dataHora);

      await cadastrar.executar(ag);
      final lista = await listar.executar(idGestor: 'gestor-1');

      expect(lista.length, equals(1));
      expect(lista.first.id, equals('ag-1'));
    });

    test('Cadastrar e buscar agendamento por ID', () async {
      final ag = Agendamento(
          id: 'ag-1', idTecnico: 'tec-1', idCliente: 'cli-1',
          idGestor: 'gestor-1', dataHora: dataHora);

      await cadastrar.executar(ag);
      final encontrado = await buscarPorId.executar('ag-1');

      expect(encontrado, isNotNull);
      expect(encontrado!.idCliente, equals('cli-1'));
    });

    test('Buscar ID inexistente retorna null', () async {
      final resultado = await buscarPorId.executar('ag-inexistente');
      expect(resultado, isNull);
    });

    test('Agendamentos de gestores diferentes não se misturam', () async {
      await cadastrar.executar(Agendamento(
          id: 'ag-1', idTecnico: 'tec-1', idCliente: 'cli-1',
          idGestor: 'gestor-1', dataHora: dataHora));
      await cadastrar.executar(Agendamento(
          id: 'ag-2', idTecnico: 'tec-2', idCliente: 'cli-2',
          idGestor: 'gestor-2',
          dataHora: DateTime(2025, 10, 21, 10, 0)));

      final lista1 = await listar.executar(idGestor: 'gestor-1');
      final lista2 = await listar.executar(idGestor: 'gestor-2');

      expect(lista1.length, equals(1));
      expect(lista2.length, equals(1));
    });
  });

  group('Fluxo — Prevenção de conflito de horário (RF02)', () {
    test('Mesmo técnico no mesmo horário é bloqueado', () async {
      await cadastrar.executar(Agendamento(
          id: 'ag-1', idTecnico: 'tec-1', idCliente: 'cli-1',
          idGestor: 'gestor-1', dataHora: dataHora));

      await expectLater(
        () => cadastrar.executar(Agendamento(
            id: 'ag-2', idTecnico: 'tec-1', idCliente: 'cli-2',
            idGestor: 'gestor-1', dataHora: dataHora)),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'mensagem',
          contains('Este técnico já possui um atendimento neste horário'),
        )),
      );

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista.length, equals(1));
    });

    test('Mesmo técnico em horário diferente é permitido', () async {
      await cadastrar.executar(Agendamento(
          id: 'ag-1', idTecnico: 'tec-1', idCliente: 'cli-1',
          idGestor: 'gestor-1', dataHora: dataHora));

      await cadastrar.executar(Agendamento(
          id: 'ag-2', idTecnico: 'tec-1', idCliente: 'cli-2',
          idGestor: 'gestor-1',
          dataHora: DateTime(2025, 10, 20, 16, 0)));

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista.length, equals(2));
    });

    test('Técnicos diferentes podem ter agendamentos no mesmo horário',
        () async {
      await cadastrar.executar(Agendamento(
          id: 'ag-1', idTecnico: 'tec-1', idCliente: 'cli-1',
          idGestor: 'gestor-1', dataHora: dataHora));

      await cadastrar.executar(Agendamento(
          id: 'ag-2', idTecnico: 'tec-2', idCliente: 'cli-2',
          idGestor: 'gestor-1', dataHora: dataHora));

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista.length, equals(2));
    });

    test('Conflito não persiste dados inválidos no repositório', () async {
      await cadastrar.executar(Agendamento(
          id: 'ag-1', idTecnico: 'tec-1', idCliente: 'cli-1',
          idGestor: 'gestor-1', dataHora: dataHora));

      try {
        await cadastrar.executar(Agendamento(
            id: 'ag-2', idTecnico: 'tec-1', idCliente: 'cli-2',
            idGestor: 'gestor-1', dataHora: dataHora));
      } catch (_) {}

      final ag2 = await buscarPorId.executar('ag-2');
      expect(ag2, isNull);
    });
  });

  group('Fluxo — Atualização de agendamento', () {
    test('Atualizar agendamento preserva os novos dados', () async {
      final ag = Agendamento(
          id: 'ag-1', idTecnico: 'tec-1', idCliente: 'cli-1',
          idGestor: 'gestor-1', dataHora: dataHora,
          observacao: 'Original');

      await cadastrar.executar(ag);

      final agAtualizado = Agendamento(
          id: 'ag-1', idTecnico: 'tec-1', idCliente: 'cli-1',
          idGestor: 'gestor-1', dataHora: dataHora,
          observacao: 'Levar kit de limpeza');

      await atualizar.executar(agAtualizado);

      final encontrado = await buscarPorId.executar('ag-1');
      expect(encontrado!.observacao, equals('Levar kit de limpeza'));
    });
  });
}
