// Testes de fluxo — RF04, RF07, RF08, RF09, RF10: ciclo de vida completo de OS
// Sem mocks: usa repositório real em memória
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/cadastrar_ordem_servico.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/atualizar_ordem_servico.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/inativar_ordem_servico.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/listar_ordens_servico.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/reabrir_ordem_servico.dart';
import 'package:gerenciar/servicos/relatorio_servico.dart';

import '../helpers/ordem_servico_repositorio_memoria.dart';

void main() {
  late OrdemServicoRepositorioMemoria repositorio;
  late CadastrarOrdemServico cadastrar;
  late AtualizarOrdemServico atualizar;
  late InativarOrdemServico inativar;
  late ListarOrdensServico listar;
  late ReabrirOrdemServico reabrir;

  OrdemServico novaOs({
    required String id,
    String idTecnico = 'tec-1',
    String idCliente = 'cli-1',
    String status = 'Pendente',
    String prioridade = 'Normal',
    double valor = 200.0,
    DateTime? dataHoraInicio,
    DateTime? dataHoraFim,
    String? justificativa,
  }) =>
      OrdemServico(
        id: id,
        idTecnico: idTecnico,
        idCliente: idCliente,
        idFormaPagamento: 'fp-1',
        idGestor: 'gestor-1',
        dataHoraInicio: dataHoraInicio ?? DateTime(2025, 10, 20, 8, 0),
        dataHoraFim: dataHoraFim,
        descricao: 'Descrição da OS $id',
        valor: valor,
        prioridade: prioridade,
        status: status,
        justificativaReabertura: justificativa,
        ativo: true,
      );

  setUp(() {
    repositorio = OrdemServicoRepositorioMemoria();
    cadastrar = CadastrarOrdemServico(repositorio);
    atualizar = AtualizarOrdemServico(repositorio);
    inativar = InativarOrdemServico(repositorio);
    listar = ListarOrdensServico(repositorio);
    reabrir = ReabrirOrdemServico(repositorio);
  });

  group('Fluxo — Abertura de OS (RF09)', () {
    test('Abrir OS e encontrá-la na listagem', () async {
      await cadastrar.executar(novaOs(id: 'os-1'));

      final lista = await listar.executar(idGestor: 'gestor-1');

      expect(lista.length, equals(1));
      expect(lista.first.status, equals('Pendente'));
    });

    test('Abrir múltiplas OS e todas aparecem na listagem', () async {
      await cadastrar.executar(novaOs(id: 'os-1'));
      await cadastrar.executar(novaOs(id: 'os-2', idTecnico: 'tec-2'));
      await cadastrar.executar(novaOs(id: 'os-3', prioridade: 'Alta'));

      final lista = await listar.executar(idGestor: 'gestor-1');

      expect(lista.length, equals(3));
    });
  });

  group('Fluxo — Ciclo de vida completo: Pendente → Em Andamento → Concluída',
      () {
    test('OS percorre os três status em sequência correta', () async {
      await cadastrar.executar(novaOs(id: 'os-1'));

      // Pendente → Em Andamento
      await atualizar.executar(novaOs(id: 'os-1', status: 'Em Andamento'));
      final osEmAndamento =
          (await listar.executar(idGestor: 'gestor-1')).first;
      expect(osEmAndamento.status, equals('Em Andamento'));

      // Em Andamento → Concluída
      await atualizar.executar(novaOs(
        id: 'os-1',
        status: 'Concluída',
        dataHoraFim: DateTime(2025, 10, 20, 11, 0),
      ));

      final osConcluida = (await listar.executar(idGestor: 'gestor-1')).first;
      expect(osConcluida.status, equals('Concluída'));
      expect(osConcluida.dataHoraFim, isNotNull);
    });

    test('OS concluída tem dataHoraFim registrada', () async {
      await cadastrar.executar(novaOs(id: 'os-1'));
      await atualizar.executar(novaOs(
        id: 'os-1',
        status: 'Concluída',
        dataHoraFim: DateTime(2025, 10, 20, 11, 30),
      ));

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista.first.dataHoraFim, equals(DateTime(2025, 10, 20, 11, 30)));
    });

    test('OS pendente não tem dataHoraFim', () async {
      await cadastrar.executar(novaOs(id: 'os-1'));

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista.first.dataHoraFim, isNull);
    });
  });

  group('Fluxo — Reabertura de OS (RF07)', () {
    test('Concluída → reaberta com justificativa válida', () async {
      await cadastrar.executar(novaOs(id: 'os-1'));
      await atualizar.executar(novaOs(
        id: 'os-1',
        status: 'Concluída',
        dataHoraFim: DateTime(2025, 10, 20, 11, 0),
      ));

      await reabrir.executar(
          id: 'os-1', justificativa: 'Problema voltou a ocorrer');

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista.first.status, equals('Reaberta'));
      expect(lista.first.justificativaReabertura,
          equals('Problema voltou a ocorrer'));
      expect(lista.first.dataHoraFim, isNull);
    });

    test('Reaberta pode ser concluída novamente', () async {
      await cadastrar.executar(novaOs(id: 'os-1'));
      await atualizar.executar(novaOs(
          id: 'os-1', status: 'Concluída',
          dataHoraFim: DateTime(2025, 10, 20, 11, 0)));
      await reabrir.executar(id: 'os-1', justificativa: 'Serviço incompleto');
      await atualizar.executar(novaOs(
          id: 'os-1', status: 'Concluída',
          dataHoraFim: DateTime(2025, 10, 21, 10, 0)));

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista.first.status, equals('Concluída'));
    });

    test('Reabertura sem justificativa lança exceção e status não muda',
        () async {
      await cadastrar.executar(novaOs(id: 'os-1', status: 'Concluída'));

      await expectLater(
        () => reabrir.executar(id: 'os-1', justificativa: ''),
        throwsA(isA<Exception>()),
      );

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista.first.status, equals('Concluída'));
    });

    test('Reabertura sem ID lança exceção', () async {
      await expectLater(
        () => reabrir.executar(id: '', justificativa: 'Motivo'),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Fluxo — Inativação de OS (RF08)', () {
    test('Inativar OS remove da listagem', () async {
      await cadastrar.executar(novaOs(id: 'os-1'));
      await cadastrar.executar(novaOs(id: 'os-2', idTecnico: 'tec-2'));

      await inativar.executar('os-1');

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista.length, equals(1));
      expect(lista.first.id, equals('os-2'));
    });
  });

  group('Fluxo — Relatório com filtros (RF10)', () {
    setUp(() async {
      await cadastrar.executar(novaOs(
          id: 'os-1', idTecnico: 'tec-1', idCliente: 'cli-1',
          status: 'Pendente',
          dataHoraInicio: DateTime(2025, 10, 5, 8, 0)));
      await cadastrar.executar(novaOs(
          id: 'os-2', idTecnico: 'tec-1', idCliente: 'cli-2',
          status: 'Concluída',
          dataHoraInicio: DateTime(2025, 10, 10, 8, 0)));
      await cadastrar.executar(novaOs(
          id: 'os-3', idTecnico: 'tec-2', idCliente: 'cli-1',
          status: 'Em Andamento',
          dataHoraInicio: DateTime(2025, 10, 15, 8, 0)));
      await atualizar.executar(novaOs(
          id: 'os-2', idTecnico: 'tec-1', idCliente: 'cli-2',
          status: 'Concluída',
          dataHoraFim: DateTime(2025, 10, 10, 11, 0),
          dataHoraInicio: DateTime(2025, 10, 10, 8, 0)));
    });

    test('Filtrar por técnico retorna apenas as OS dele', () async {
      final filtros = FiltrosRelatorio(idTecnico: 'tec-1');
      final resultado =
          await repositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado.length, equals(2));
      expect(resultado.every((os) => os.idTecnico == 'tec-1'), isTrue);
    });

    test('Filtrar por status Pendente retorna apenas OS pendentes', () async {
      final filtros = FiltrosRelatorio(status: ['Pendente']);
      final resultado =
          await repositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado.length, equals(1));
      expect(resultado.first.id, equals('os-1'));
    });

    test('Filtrar por múltiplos status retorna todos os correspondentes',
        () async {
      final filtros =
          FiltrosRelatorio(status: ['Pendente', 'Em Andamento']);
      final resultado =
          await repositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado.length, equals(2));
    });

    test('Filtrar por período retorna apenas OS dentro do intervalo', () async {
      final filtros = FiltrosRelatorio(
        dataInicial: DateTime(2025, 10, 8),
        dataFinal: DateTime(2025, 10, 12),
      );
      final resultado =
          await repositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado.length, equals(1));
      expect(resultado.first.id, equals('os-2'));
    });

    test('Filtrar por cliente retorna apenas OS daquele cliente', () async {
      final filtros = FiltrosRelatorio(idCliente: 'cli-1');
      final resultado =
          await repositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado.length, equals(2));
      expect(resultado.every((os) => os.idCliente == 'cli-1'), isTrue);
    });

    test('Combinar técnico + status retorna intersecção correta', () async {
      final filtros = FiltrosRelatorio(
        idTecnico: 'tec-1',
        status: ['Concluída'],
      );
      final resultado =
          await repositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado.length, equals(1));
      expect(resultado.first.id, equals('os-2'));
    });

    test('Filtro fora do período retorna lista vazia', () async {
      final filtros = FiltrosRelatorio(
        dataInicial: DateTime(2025, 12, 1),
        dataFinal: DateTime(2025, 12, 31),
      );
      final resultado =
          await repositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado, isEmpty);
    });
  });
}
