// RF relacionado a Formas de Pagamento - CRUD completo e validações
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/cadastrar_forma_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/atualizar_forma_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/buscar_forma_pagamento_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/buscar_forma_pagamento_por_nome.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/inativar_forma_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/listar_formas_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/reativar_forma_pagamento.dart';

import 'cadastrar_forma_pagamento_test.mocks.dart';

void main() {
  late MockFormaPagamentoRepositorioInterface mockRepositorio;
  late CadastrarFormaPagamento cadastrar;
  late AtualizarFormaPagamento atualizar;
  late BuscarFormaPagamentoPorId buscarPorId;
  late BuscarFormaPagamentoPorNome buscarPorNome;
  late InativarFormaPagamento inativar;
  late ListarFormasPagamento listar;
  late ReativarFormaPagamento reativar;

  final fpPix = FormaPagamento(
    id: 'fp-1',
    nome: 'PIX',
    descricao: 'Pagamento instantâneo',
    ativo: true,
    idGestor: 'gestor-1',
  );

  final fpDinheiro = FormaPagamento(
    id: 'fp-2',
    nome: 'Dinheiro',
    ativo: true,
    idGestor: 'gestor-1',
  );

  final fpCartao = FormaPagamento(
    id: 'fp-3',
    nome: 'Cartão de Crédito',
    descricao: 'Visa, Master, Elo',
    ativo: true,
    idGestor: 'gestor-1',
  );

  final fpInativo = FormaPagamento(
    id: 'fp-4',
    nome: 'Cheque',
    ativo: false,
    idGestor: 'gestor-1',
  );

  setUp(() {
    mockRepositorio = MockFormaPagamentoRepositorioInterface();
    cadastrar = CadastrarFormaPagamento(mockRepositorio);
    atualizar = AtualizarFormaPagamento(mockRepositorio);
    buscarPorId = BuscarFormaPagamentoPorId(mockRepositorio);
    buscarPorNome = BuscarFormaPagamentoPorNome(mockRepositorio);
    inativar = InativarFormaPagamento(mockRepositorio);
    listar = ListarFormasPagamento(mockRepositorio);
    reativar = ReativarFormaPagamento(mockRepositorio);
  });

  group('Cadastro de Formas de Pagamento', () {
    test('Deve cadastrar forma de pagamento com descrição', () async {
      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(fpPix);

      verify(mockRepositorio.adicionar(fpPix));
    });

    test('Deve cadastrar forma de pagamento sem descrição (opcional)', () async {
      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(fpDinheiro);

      verify(mockRepositorio.adicionar(fpDinheiro));
    });

    test('Deve chamar adicionar exatamente uma vez por cadastro', () async {
      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(fpPix);

      verify(mockRepositorio.adicionar(any)).called(1);
    });

    test('Deve cadastrar múltiplas formas de pagamento independentemente',
        () async {
      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(fpPix);
      await cadastrar.executar(fpDinheiro);
      await cadastrar.executar(fpCartao);

      verify(mockRepositorio.adicionar(any)).called(3);
    });

    test('Deve atualizar forma de pagamento com novos dados', () async {
      when(mockRepositorio.atualizar(any)).thenAnswer((_) => Future.value());

      await atualizar.executar(fpPix);

      verify(mockRepositorio.atualizar(fpPix));
    });

    test('Deve chamar atualizar exatamente uma vez', () async {
      when(mockRepositorio.atualizar(any)).thenAnswer((_) => Future.value());

      await atualizar.executar(fpCartao);

      verify(mockRepositorio.atualizar(any)).called(1);
    });
  });

  group('Busca de Formas de Pagamento', () {
    test('Deve retornar forma de pagamento ao buscar por ID existente',
        () async {
      when(mockRepositorio.buscarPorId(any))
          .thenAnswer((_) => Future.value(fpPix));

      final resultado = await buscarPorId.executar('fp-1');

      expect(resultado, equals(fpPix));
      verify(mockRepositorio.buscarPorId('fp-1'));
    });

    test('Deve retornar null ao buscar por ID inexistente', () async {
      when(mockRepositorio.buscarPorId(any))
          .thenAnswer((_) => Future.value(null));

      final resultado = await buscarPorId.executar('fp-inexistente');

      expect(resultado, isNull);
    });

    test('Deve retornar forma de pagamento ao buscar por nome exato', () async {
      when(mockRepositorio.buscarPorNome(any))
          .thenAnswer((_) => Future.value(fpPix));

      final resultado = await buscarPorNome.executar('PIX');

      expect(resultado, equals(fpPix));
      verify(mockRepositorio.buscarPorNome('PIX'));
    });

    test('Deve retornar null ao buscar por nome inexistente', () async {
      when(mockRepositorio.buscarPorNome(any))
          .thenAnswer((_) => Future.value(null));

      final resultado = await buscarPorNome.executar('Bitcoin');

      expect(resultado, isNull);
    });

    test('Deve buscar por nome com string exata passada ao repositório',
        () async {
      when(mockRepositorio.buscarPorNome(any))
          .thenAnswer((_) => Future.value(fpDinheiro));

      await buscarPorNome.executar('Dinheiro');

      final capturado =
          verify(mockRepositorio.buscarPorNome(captureAny)).captured.first;
      expect(capturado, equals('Dinheiro'));
    });
  });

  group('Listagem de Formas de Pagamento', () {
    test('Deve listar somente formas de pagamento ativas do gestor', () async {
      when(mockRepositorio.listarTodos(
              idGestor: anyNamed('idGestor'),
              incluirInativos: anyNamed('incluirInativos')))
          .thenAnswer((_) => Future.value([fpPix, fpDinheiro, fpCartao]));

      final resultado = await listar.executar(idGestor: 'gestor-1');

      expect(resultado.length, equals(3));
      verify(mockRepositorio.listarTodos(
          idGestor: 'gestor-1', incluirInativos: false));
    });

    test('Deve listar incluindo formas inativas quando solicitado', () async {
      when(mockRepositorio.listarTodos(
              idGestor: anyNamed('idGestor'),
              incluirInativos: anyNamed('incluirInativos')))
          .thenAnswer(
              (_) => Future.value([fpPix, fpDinheiro, fpCartao, fpInativo]));

      final resultado =
          await listar.executar(idGestor: 'gestor-1', incluirInativos: true);

      expect(resultado.length, equals(4));
      verify(mockRepositorio.listarTodos(
          idGestor: 'gestor-1', incluirInativos: true));
    });

    test('Deve retornar lista vazia quando não há formas de pagamento', () async {
      when(mockRepositorio.listarTodos(
              idGestor: anyNamed('idGestor'),
              incluirInativos: anyNamed('incluirInativos')))
          .thenAnswer((_) => Future.value([]));

      final resultado =
          await listar.executar(idGestor: 'gestor-sem-formas');

      expect(resultado, isEmpty);
    });
  });

  group('Inativação e Reativação de Formas de Pagamento', () {
    test('Deve inativar forma de pagamento pelo id', () async {
      when(mockRepositorio.inativar(any)).thenAnswer((_) => Future.value());

      await inativar.executar('fp-1');

      verify(mockRepositorio.inativar('fp-1'));
    });

    test('Deve chamar inativar exatamente uma vez', () async {
      when(mockRepositorio.inativar(any)).thenAnswer((_) => Future.value());

      await inativar.executar('fp-1');

      verify(mockRepositorio.inativar(any)).called(1);
    });

    test('Deve reativar forma de pagamento com id válido', () async {
      when(mockRepositorio.reativar(any)).thenAnswer((_) => Future.value());

      await reativar.executar('fp-4');

      verify(mockRepositorio.reativar('fp-4'));
    });

    test('Deve lançar exceção ao reativar com id vazio', () async {
      await expectLater(
        () => reativar.executar(''),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'mensagem',
          contains('ID da forma de pagamento é obrigatório'),
        )),
      );

      verifyNever(mockRepositorio.reativar(any));
    });

    test('Não deve chamar reativar quando id for inválido', () async {
      try {
        await reativar.executar('');
      } catch (_) {}

      verifyNever(mockRepositorio.reativar(any));
    });

    test('Deve executar inativar e reativar em sequência correta', () async {
      when(mockRepositorio.inativar(any)).thenAnswer((_) => Future.value());
      when(mockRepositorio.reativar(any)).thenAnswer((_) => Future.value());

      await inativar.executar('fp-1');
      await reativar.executar('fp-1');

      verifyInOrder([
        mockRepositorio.inativar('fp-1'),
        mockRepositorio.reativar('fp-1'),
      ]);
    });
  });
}
