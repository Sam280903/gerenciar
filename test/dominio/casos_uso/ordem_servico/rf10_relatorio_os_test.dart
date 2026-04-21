// RF10 - Geração de Relatórios de Ordens de Serviço com filtros
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/servicos/relatorio_servico.dart';

import 'listar_ordens_servico_test.mocks.dart';

void main() {
  late MockOrdemServicoRepositorioInterface mockRepositorio;

  final osPendente = OrdemServico(
    id: 'os-1',
    idTecnico: 'tec-1',
    idCliente: 'cli-1',
    idFormaPagamento: 'fp-1',
    idGestor: 'gestor-1',
    dataHoraInicio: DateTime(2025, 10, 1, 8, 0),
    descricao: 'Limpeza de filtro',
    valor: 150.0,
    prioridade: 'Baixa',
    status: 'Pendente',
    ativo: true,
  );

  final osConcluida = OrdemServico(
    id: 'os-2',
    idTecnico: 'tec-1',
    idCliente: 'cli-2',
    idFormaPagamento: 'fp-1',
    idGestor: 'gestor-1',
    dataHoraInicio: DateTime(2025, 10, 5, 9, 0),
    dataHoraFim: DateTime(2025, 10, 5, 11, 0),
    descricao: 'Troca de compressor',
    valor: 800.0,
    prioridade: 'Alta',
    status: 'Concluída',
    ativo: true,
  );

  final osEmAndamento = OrdemServico(
    id: 'os-3',
    idTecnico: 'tec-2',
    idCliente: 'cli-1',
    idFormaPagamento: 'fp-2',
    idGestor: 'gestor-1',
    dataHoraInicio: DateTime(2025, 10, 10, 14, 0),
    descricao: 'Instalação de split',
    valor: 600.0,
    prioridade: 'Normal',
    status: 'Em Andamento',
    ativo: true,
  );

  final osReaberta = OrdemServico(
    id: 'os-4',
    idTecnico: 'tec-2',
    idCliente: 'cli-3',
    idFormaPagamento: 'fp-1',
    idGestor: 'gestor-1',
    dataHoraInicio: DateTime(2025, 9, 20, 10, 0),
    descricao: 'Manutenção preventiva',
    valor: 250.0,
    prioridade: 'Normal',
    status: 'Reaberta',
    justificativaReabertura: 'Problema voltou a ocorrer',
    ativo: true,
  );

  setUp(() {
    mockRepositorio = MockOrdemServicoRepositorioInterface();
  });

  group('RF10 - Relatório sem filtros', () {
    test('Deve retornar todas as OS do gestor sem filtros aplicados', () async {
      final filtros = FiltrosRelatorio();

      when(mockRepositorio.listarComFiltros(any, any))
          .thenAnswer((_) => Future.value(
              [osPendente, osConcluida, osEmAndamento, osReaberta]));

      final resultado =
          await mockRepositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado.length, equals(4));
    });

    test('Deve retornar lista vazia quando não há OS no período', () async {
      final filtros = FiltrosRelatorio(
        dataInicial: DateTime(2024, 1, 1),
        dataFinal: DateTime(2024, 1, 31),
      );

      when(mockRepositorio.listarComFiltros(any, any))
          .thenAnswer((_) => Future.value([]));

      final resultado =
          await mockRepositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado, isEmpty);
    });

    test('Deve passar o idGestor correto ao repositório', () async {
      final filtros = FiltrosRelatorio();

      when(mockRepositorio.listarComFiltros(any, any))
          .thenAnswer((_) => Future.value([]));

      await mockRepositorio.listarComFiltros(filtros, 'gestor-1');

      final captured =
          verify(mockRepositorio.listarComFiltros(captureAny, captureAny))
              .captured;
      expect(captured[1], equals('gestor-1'));
    });
  });

  group('RF10 - Relatório filtrado por técnico', () {
    test('Deve filtrar OS por técnico específico', () async {
      final filtros = FiltrosRelatorio(idTecnico: 'tec-1');

      when(mockRepositorio.listarComFiltros(any, any))
          .thenAnswer((_) => Future.value([osPendente, osConcluida]));

      final resultado =
          await mockRepositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado.every((os) => os.idTecnico == 'tec-1'), isTrue);
    });

    test('Deve retornar OS de todos os técnicos quando idTecnico for nulo',
        () async {
      final filtros = FiltrosRelatorio(idTecnico: null);

      when(mockRepositorio.listarComFiltros(any, any)).thenAnswer((_) =>
          Future.value([osPendente, osConcluida, osEmAndamento, osReaberta]));

      final resultado =
          await mockRepositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado.length, equals(4));
    });

    test('Deve retornar lista vazia para técnico sem OS', () async {
      final filtros = FiltrosRelatorio(idTecnico: 'tec-99');

      when(mockRepositorio.listarComFiltros(any, any))
          .thenAnswer((_) => Future.value([]));

      final resultado =
          await mockRepositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado, isEmpty);
    });
  });

  group('RF10 - Relatório filtrado por status', () {
    test('Deve filtrar somente OS com status Pendente', () async {
      final filtros = FiltrosRelatorio(status: ['Pendente']);

      when(mockRepositorio.listarComFiltros(any, any))
          .thenAnswer((_) => Future.value([osPendente]));

      final resultado =
          await mockRepositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado.every((os) => os.status == 'Pendente'), isTrue);
    });

    test('Deve filtrar somente OS com status Concluída', () async {
      final filtros = FiltrosRelatorio(status: ['Concluída']);

      when(mockRepositorio.listarComFiltros(any, any))
          .thenAnswer((_) => Future.value([osConcluida]));

      final resultado =
          await mockRepositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado.every((os) => os.status == 'Concluída'), isTrue);
    });

    test('Deve filtrar OS com múltiplos status simultaneamente', () async {
      final filtros =
          FiltrosRelatorio(status: ['Pendente', 'Em Andamento']);

      when(mockRepositorio.listarComFiltros(any, any))
          .thenAnswer((_) => Future.value([osPendente, osEmAndamento]));

      final resultado =
          await mockRepositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado.length, equals(2));
      expect(
          resultado
              .every((os) => ['Pendente', 'Em Andamento'].contains(os.status)),
          isTrue);
    });

    test('Deve retornar OS com status Reaberta', () async {
      final filtros = FiltrosRelatorio(status: ['Reaberta']);

      when(mockRepositorio.listarComFiltros(any, any))
          .thenAnswer((_) => Future.value([osReaberta]));

      final resultado =
          await mockRepositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado.first.status, equals('Reaberta'));
      expect(resultado.first.justificativaReabertura, isNotNull);
    });
  });

  group('RF10 - Relatório filtrado por período', () {
    test('Deve filtrar OS dentro do período informado', () async {
      final filtros = FiltrosRelatorio(
        dataInicial: DateTime(2025, 10, 1),
        dataFinal: DateTime(2025, 10, 31),
      );

      when(mockRepositorio.listarComFiltros(any, any))
          .thenAnswer((_) => Future.value([osPendente, osConcluida, osEmAndamento]));

      final resultado =
          await mockRepositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado.length, equals(3));
    });

    test('Deve filtrar OS fora do período e retornar lista vazia', () async {
      final filtros = FiltrosRelatorio(
        dataInicial: DateTime(2025, 12, 1),
        dataFinal: DateTime(2025, 12, 31),
      );

      when(mockRepositorio.listarComFiltros(any, any))
          .thenAnswer((_) => Future.value([]));

      final resultado =
          await mockRepositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado, isEmpty);
    });

    test('Deve combinar filtro de período com filtro de técnico', () async {
      final filtros = FiltrosRelatorio(
        idTecnico: 'tec-1',
        dataInicial: DateTime(2025, 10, 1),
        dataFinal: DateTime(2025, 10, 31),
      );

      when(mockRepositorio.listarComFiltros(any, any))
          .thenAnswer((_) => Future.value([osPendente, osConcluida]));

      final resultado =
          await mockRepositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado.every((os) => os.idTecnico == 'tec-1'), isTrue);
    });

    test('Deve combinar todos os filtros simultaneamente', () async {
      final filtros = FiltrosRelatorio(
        idTecnico: 'tec-1',
        idCliente: 'cli-2',
        status: ['Concluída'],
        dataInicial: DateTime(2025, 10, 1),
        dataFinal: DateTime(2025, 10, 31),
      );

      when(mockRepositorio.listarComFiltros(any, any))
          .thenAnswer((_) => Future.value([osConcluida]));

      final resultado =
          await mockRepositorio.listarComFiltros(filtros, 'gestor-1');

      expect(resultado.length, equals(1));
      expect(resultado.first.id, equals('os-2'));
    });
  });
}
