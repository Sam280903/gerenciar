// RF07 - Reabertura de Atendimentos pelo Gestor
// RF09 - Abertura de Ordem de Serviço
// RF04 - Conclusão de Atendimento (atualização de status via OS)
// RF08 - Inativação de OS pelo Gestor
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/cadastrar_ordem_servico.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/reabrir_ordem_servico.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/atualizar_ordem_servico.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/inativar_ordem_servico.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/listar_ordens_servico.dart';

import 'listar_ordens_servico_test.mocks.dart';

void main() {
  late MockOrdemServicoRepositorioInterface mockRepositorio;
  late CadastrarOrdemServico cadastrar;
  late ReabrirOrdemServico reabrir;
  late AtualizarOrdemServico atualizar;
  late InativarOrdemServico inativar;
  late ListarOrdensServico listar;

  final ordemPendente = OrdemServico(
    id: 'os-1',
    idTecnico: 'tec-1',
    idCliente: 'cli-1',
    idFormaPagamento: 'fp-1',
    idGestor: 'gestor-1',
    dataHoraInicio: DateTime(2025, 10, 20, 8, 0),
    descricao: 'Manutenção preventiva ar-condicionado',
    valor: 250.0,
    prioridade: 'Normal',
    status: 'Pendente',
    ativo: true,
  );

  final ordemConcluida = OrdemServico(
    id: 'os-2',
    idTecnico: 'tec-1',
    idCliente: 'cli-1',
    idFormaPagamento: 'fp-1',
    idGestor: 'gestor-1',
    dataHoraInicio: DateTime(2025, 10, 18, 8, 0),
    dataHoraFim: DateTime(2025, 10, 18, 11, 0),
    descricao: 'Limpeza completa',
    valor: 180.0,
    prioridade: 'Baixa',
    status: 'Concluída',
    ativo: true,
  );

  final ordemEmAndamento = OrdemServico(
    id: 'os-3',
    idTecnico: 'tec-1',
    idCliente: 'cli-2',
    idFormaPagamento: 'fp-1',
    idGestor: 'gestor-1',
    dataHoraInicio: DateTime(2025, 10, 21, 9, 0),
    descricao: 'Instalação de split',
    valor: 400.0,
    prioridade: 'Alta',
    status: 'Em Andamento',
    ativo: true,
  );

  setUp(() {
    mockRepositorio = MockOrdemServicoRepositorioInterface();
    cadastrar = CadastrarOrdemServico(mockRepositorio);
    reabrir = ReabrirOrdemServico(mockRepositorio);
    atualizar = AtualizarOrdemServico(mockRepositorio);
    inativar = InativarOrdemServico(mockRepositorio);
    listar = ListarOrdensServico(mockRepositorio);
  });

  group('RF09 - Abertura de Ordem de Serviço', () {
    test('Deve abrir OS com dados válidos', () async {
      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(ordemPendente);

      verify(mockRepositorio.adicionar(ordemPendente));
    });

    test('Deve abrir OS com prioridade Alta', () async {
      final osUrgente = OrdemServico(
        id: 'os-4',
        idTecnico: 'tec-1',
        idCliente: 'cli-1',
        idFormaPagamento: 'fp-1',
        idGestor: 'gestor-1',
        dataHoraInicio: DateTime.now(),
        descricao: 'Compressor queimado',
        valor: 800.0,
        prioridade: 'Alta',
        status: 'Pendente',
        ativo: true,
      );

      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(osUrgente);

      verify(mockRepositorio.adicionar(osUrgente));
    });

    test('Deve abrir OS com prioridade Baixa', () async {
      final osBaixa = OrdemServico(
        id: 'os-5',
        idTecnico: 'tec-2',
        idCliente: 'cli-3',
        idFormaPagamento: 'fp-2',
        idGestor: 'gestor-1',
        dataHoraInicio: DateTime(2025, 11, 5, 10, 0),
        descricao: 'Verificação de filtros',
        valor: 80.0,
        prioridade: 'Baixa',
        status: 'Pendente',
        ativo: true,
      );

      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(osBaixa);

      verify(mockRepositorio.adicionar(osBaixa));
    });

    test('Deve chamar adicionar exatamente uma vez por abertura', () async {
      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(ordemPendente);

      verify(mockRepositorio.adicionar(any)).called(1);
    });

    test('Deve abrir OS com status inicial Pendente', () async {
      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(ordemPendente);

      final capturado =
          verify(mockRepositorio.adicionar(captureAny)).captured.first
              as OrdemServico;
      expect(capturado.status, equals('Pendente'));
    });

    test('Deve abrir OS com justificativaReabertura ausente no primeiro cadastro',
        () async {
      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(ordemPendente);

      final capturado =
          verify(mockRepositorio.adicionar(captureAny)).captured.first
              as OrdemServico;
      expect(capturado.justificativaReabertura, isNull);
    });
  });

  group('RF04 - Conclusão de Atendimento', () {
    test('Deve atualizar status da OS para Concluída', () async {
      when(mockRepositorio.atualizar(any)).thenAnswer((_) => Future.value());

      await atualizar.executar(ordemConcluida);

      verify(mockRepositorio.atualizar(ordemConcluida));
    });

    test('Deve registrar dataHoraFim ao concluir atendimento', () async {
      when(mockRepositorio.atualizar(any)).thenAnswer((_) => Future.value());

      await atualizar.executar(ordemConcluida);

      final capturado =
          verify(mockRepositorio.atualizar(captureAny)).captured.first
              as OrdemServico;
      expect(capturado.dataHoraFim, isNotNull);
      expect(capturado.status, equals('Concluída'));
    });

    test('Deve atualizar status de Pendente para Em Andamento', () async {
      when(mockRepositorio.atualizar(any)).thenAnswer((_) => Future.value());

      await atualizar.executar(ordemEmAndamento);

      final capturado =
          verify(mockRepositorio.atualizar(captureAny)).captured.first
              as OrdemServico;
      expect(capturado.status, equals('Em Andamento'));
    });

    test('Deve chamar atualizar exatamente uma vez por conclusão', () async {
      when(mockRepositorio.atualizar(any)).thenAnswer((_) => Future.value());

      await atualizar.executar(ordemConcluida);

      verify(mockRepositorio.atualizar(any)).called(1);
    });

    test('Deve preservar dados originais da OS ao concluir', () async {
      when(mockRepositorio.atualizar(any)).thenAnswer((_) => Future.value());

      await atualizar.executar(ordemConcluida);

      final capturado =
          verify(mockRepositorio.atualizar(captureAny)).captured.first
              as OrdemServico;
      expect(capturado.id, equals('os-2'));
      expect(capturado.valor, equals(180.0));
      expect(capturado.idTecnico, equals('tec-1'));
    });
  });

  group('RF07 - Reabertura de Atendimento pelo Gestor', () {
    test('Deve reabrir OS com id e justificativa válidos', () async {
      when(mockRepositorio.reabrir(
              id: anyNamed('id'), justificativa: anyNamed('justificativa')))
          .thenAnswer((_) => Future.value());

      await reabrir.executar(id: 'os-2', justificativa: 'Serviço incompleto');

      verify(mockRepositorio.reabrir(
          id: 'os-2', justificativa: 'Serviço incompleto'));
    });

    test('Deve lançar exceção quando id estiver vazio', () async {
      await expectLater(
        () => reabrir.executar(id: '', justificativa: 'Motivo válido'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'mensagem',
          contains('ID da Ordem de Serviço é obrigatório'),
        )),
      );

      verifyNever(mockRepositorio.reabrir(
          id: anyNamed('id'), justificativa: anyNamed('justificativa')));
    });

    test('Deve lançar exceção quando justificativa estiver vazia', () async {
      await expectLater(
        () => reabrir.executar(id: 'os-2', justificativa: ''),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'mensagem',
          contains('justificativa para a reabertura é obrigatória'),
        )),
      );

      verifyNever(mockRepositorio.reabrir(
          id: anyNamed('id'), justificativa: anyNamed('justificativa')));
    });

    test('Deve lançar exceção quando id e justificativa estiverem vazios',
        () async {
      await expectLater(
        () => reabrir.executar(id: '', justificativa: ''),
        throwsA(isA<Exception>()),
      );
    });

    test('Deve reabrir OS com justificativa detalhada', () async {
      when(mockRepositorio.reabrir(
              id: anyNamed('id'), justificativa: anyNamed('justificativa')))
          .thenAnswer((_) => Future.value());

      const justificativaLonga =
          'O cliente relatou que o equipamento voltou a apresentar o mesmo defeito após 3 dias.';
      await reabrir.executar(id: 'os-2', justificativa: justificativaLonga);

      verify(mockRepositorio.reabrir(
          id: 'os-2', justificativa: justificativaLonga));
    });

    test('Deve chamar reabrir exatamente uma vez por reabertura', () async {
      when(mockRepositorio.reabrir(
              id: anyNamed('id'), justificativa: anyNamed('justificativa')))
          .thenAnswer((_) => Future.value());

      await reabrir.executar(id: 'os-2', justificativa: 'Motivo técnico');

      verify(mockRepositorio.reabrir(
              id: anyNamed('id'), justificativa: anyNamed('justificativa')))
          .called(1);
    });

    test('Não deve chamar reabrir quando id for inválido', () async {
      try {
        await reabrir.executar(id: '', justificativa: 'Justificativa válida');
      } catch (_) {}

      verifyNever(mockRepositorio.reabrir(
          id: anyNamed('id'), justificativa: anyNamed('justificativa')));
    });
  });

  group('RF08 - Inativação de OS pelo Gestor', () {
    test('Deve inativar OS pelo id', () async {
      when(mockRepositorio.inativar(any)).thenAnswer((_) => Future.value());

      await inativar.executar('os-1');

      verify(mockRepositorio.inativar('os-1'));
    });

    test('Deve chamar inativar exatamente uma vez', () async {
      when(mockRepositorio.inativar(any)).thenAnswer((_) => Future.value());

      await inativar.executar('os-1');

      verify(mockRepositorio.inativar(any)).called(1);
    });

    test('Deve listar ordens de serviço do gestor', () async {
      final lista = [ordemPendente, ordemConcluida];

      when(mockRepositorio.listarTodos(idGestor: anyNamed('idGestor')))
          .thenAnswer((_) => Future.value(lista));

      final resultado = await listar.executar(idGestor: 'gestor-1');

      expect(resultado.length, equals(2));
      verify(mockRepositorio.listarTodos(idGestor: 'gestor-1'));
    });

    test('Deve retornar lista vazia quando não há OS cadastradas', () async {
      when(mockRepositorio.listarTodos(idGestor: anyNamed('idGestor')))
          .thenAnswer((_) => Future.value([]));

      final resultado = await listar.executar(idGestor: 'gestor-sem-os');

      expect(resultado, isEmpty);
    });
  });
}
