// Testes de fluxo — Formas de Pagamento: ciclo de vida completo
// Sem mocks: usa repositório real em memória
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/cadastrar_forma_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/atualizar_forma_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/buscar_forma_pagamento_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/buscar_forma_pagamento_por_nome.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/inativar_forma_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/listar_formas_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/reativar_forma_pagamento.dart';

import '../helpers/forma_pagamento_repositorio_memoria.dart';

void main() {
  late FormaPagamentoRepositorioMemoria repositorio;
  late CadastrarFormaPagamento cadastrar;
  late AtualizarFormaPagamento atualizar;
  late BuscarFormaPagamentoPorId buscarPorId;
  late BuscarFormaPagamentoPorNome buscarPorNome;
  late InativarFormaPagamento inativar;
  late ListarFormasPagamento listar;
  late ReativarFormaPagamento reativar;

  FormaPagamento novaForma({
    required String id,
    required String nome,
    String? descricao,
    String idGestor = 'gestor-1',
  }) =>
      FormaPagamento(
        id: id,
        nome: nome,
        descricao: descricao,
        ativo: true,
        idGestor: idGestor,
      );

  setUp(() {
    repositorio = FormaPagamentoRepositorioMemoria();
    cadastrar = CadastrarFormaPagamento(repositorio);
    atualizar = AtualizarFormaPagamento(repositorio);
    buscarPorId = BuscarFormaPagamentoPorId(repositorio);
    buscarPorNome = BuscarFormaPagamentoPorNome(repositorio);
    inativar = InativarFormaPagamento(repositorio);
    listar = ListarFormasPagamento(repositorio);
    reativar = ReativarFormaPagamento(repositorio);
  });

  group('Fluxo — Cadastro e listagem de formas de pagamento', () {
    test('Cadastrar forma de pagamento e encontrá-la na listagem', () async {
      await cadastrar.executar(novaForma(id: 'fp-1', nome: 'PIX'));

      final lista = await listar.executar(idGestor: 'gestor-1');

      expect(lista.length, equals(1));
      expect(lista.first.nome, equals('PIX'));
    });

    test('Cadastrar com descrição opcional e verificar persistência', () async {
      await cadastrar.executar(novaForma(
        id: 'fp-1',
        nome: 'Cartão de Crédito',
        descricao: 'Visa, Master, Elo',
      ));

      final encontrada = await buscarPorId.executar('fp-1');

      expect(encontrada!.descricao, equals('Visa, Master, Elo'));
    });

    test('Cadastrar sem descrição também funciona', () async {
      await cadastrar.executar(novaForma(id: 'fp-1', nome: 'Dinheiro'));

      final encontrada = await buscarPorId.executar('fp-1');

      expect(encontrada!.descricao, isNull);
    });

    test('Cadastrar múltiplas formas e todas aparecem na listagem', () async {
      await cadastrar.executar(novaForma(id: 'fp-1', nome: 'PIX'));
      await cadastrar.executar(novaForma(id: 'fp-2', nome: 'Dinheiro'));
      await cadastrar.executar(novaForma(id: 'fp-3', nome: 'Cartão'));

      final lista = await listar.executar(idGestor: 'gestor-1');

      expect(lista.length, equals(3));
    });

    test('Formas de pagamento de gestores diferentes não se misturam', () async {
      await cadastrar.executar(novaForma(id: 'fp-1', nome: 'PIX', idGestor: 'gestor-1'));
      await cadastrar.executar(novaForma(id: 'fp-2', nome: 'Boleto', idGestor: 'gestor-2'));

      final listaG1 = await listar.executar(idGestor: 'gestor-1');
      final listaG2 = await listar.executar(idGestor: 'gestor-2');

      expect(listaG1.length, equals(1));
      expect(listaG1.first.nome, equals('PIX'));
      expect(listaG2.length, equals(1));
      expect(listaG2.first.nome, equals('Boleto'));
    });
  });

  group('Fluxo — Busca de forma de pagamento', () {
    test('Buscar por ID retorna a forma correta', () async {
      await cadastrar.executar(novaForma(id: 'fp-1', nome: 'PIX'));
      await cadastrar.executar(novaForma(id: 'fp-2', nome: 'Dinheiro'));

      final encontrada = await buscarPorId.executar('fp-2');

      expect(encontrada!.nome, equals('Dinheiro'));
    });

    test('Buscar por ID inexistente retorna null', () async {
      final resultado = await buscarPorId.executar('fp-inexistente');

      expect(resultado, isNull);
    });

    test('Buscar por nome retorna a forma correta', () async {
      await cadastrar.executar(novaForma(id: 'fp-1', nome: 'PIX'));
      await cadastrar.executar(novaForma(id: 'fp-2', nome: 'Dinheiro'));

      final encontrada = await buscarPorNome.executar('PIX');

      expect(encontrada!.id, equals('fp-1'));
    });

    test('Buscar por nome inexistente retorna null', () async {
      await cadastrar.executar(novaForma(id: 'fp-1', nome: 'PIX'));

      final resultado = await buscarPorNome.executar('Bitcoin');

      expect(resultado, isNull);
    });

    test('Busca por nome é case-sensitive', () async {
      await cadastrar.executar(novaForma(id: 'fp-1', nome: 'PIX'));

      final minusculo = await buscarPorNome.executar('pix');

      expect(minusculo, isNull);
    });
  });

  group('Fluxo — Atualização de forma de pagamento', () {
    test('Atualizar descrição e verificar persistência', () async {
      await cadastrar.executar(novaForma(
          id: 'fp-1', nome: 'Cartão', descricao: 'Somente débito'));

      await atualizar.executar(novaForma(
          id: 'fp-1', nome: 'Cartão', descricao: 'Débito e crédito'));

      final encontrada = await buscarPorId.executar('fp-1');
      expect(encontrada!.descricao, equals('Débito e crédito'));
    });

    test('Atualizar nome da forma de pagamento', () async {
      await cadastrar.executar(novaForma(id: 'fp-1', nome: 'Cartão Visa'));

      await atualizar.executar(novaForma(id: 'fp-1', nome: 'Cartão de Crédito'));

      final encontrada = await buscarPorId.executar('fp-1');
      expect(encontrada!.nome, equals('Cartão de Crédito'));
    });
  });

  group('Fluxo — Inativação e reativação de forma de pagamento', () {
    test('Cadastrar → inativar → não aparece na listagem padrão', () async {
      await cadastrar.executar(novaForma(id: 'fp-1', nome: 'Cheque'));

      await inativar.executar('fp-1');

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista, isEmpty);
    });

    test('Forma inativada aparece ao incluir inativos', () async {
      await cadastrar.executar(novaForma(id: 'fp-1', nome: 'Cheque'));

      await inativar.executar('fp-1');

      final lista =
          await listar.executar(idGestor: 'gestor-1', incluirInativos: true);
      expect(lista.length, equals(1));
      expect(lista.first.ativo, isFalse);
    });

    test('Inativar → reativar → volta à listagem ativa', () async {
      await cadastrar.executar(novaForma(id: 'fp-1', nome: 'Cheque'));

      await inativar.executar('fp-1');
      await reativar.executar('fp-1');

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista.length, equals(1));
      expect(lista.first.ativo, isTrue);
    });

    test('Inativar uma forma não afeta as demais', () async {
      await cadastrar.executar(novaForma(id: 'fp-1', nome: 'PIX'));
      await cadastrar.executar(novaForma(id: 'fp-2', nome: 'Dinheiro'));
      await cadastrar.executar(novaForma(id: 'fp-3', nome: 'Cheque'));

      await inativar.executar('fp-3');

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista.length, equals(2));
      expect(lista.any((f) => f.nome == 'Cheque'), isFalse);
    });

    test('Reativar com ID vazio lança exceção', () async {
      await expectLater(
        () => reativar.executar(''),
        throwsA(isA<Exception>()),
      );
    });

    test('Listar inclui inativos apenas quando solicitado', () async {
      await cadastrar.executar(novaForma(id: 'fp-1', nome: 'PIX'));
      await cadastrar.executar(novaForma(id: 'fp-2', nome: 'Dinheiro'));
      await inativar.executar('fp-2');

      final ativos = await listar.executar(idGestor: 'gestor-1');
      final todos =
          await listar.executar(idGestor: 'gestor-1', incluirInativos: true);

      expect(ativos.length, equals(1));
      expect(todos.length, equals(2));
    });
  });
}
