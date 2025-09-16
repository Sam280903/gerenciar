// test/dominio/casos_uso/forma_pagamento/busca_forma_pagamento_test.dart//
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/buscar_forma_pagamento_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/buscar_forma_pagamento_por_nome.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/listar_formas_pagamento.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';

import 'cadastrar_forma_pagamento_test.mocks.dart';

void main() {
  late MockFormaPagamentoRepositorioInterface mockRepositorio;

  setUp(() {
    mockRepositorio = MockFormaPagamentoRepositorioInterface();
  });

  final formaPagamento = FormaPagamento(id: 'fp-1', nome: 'PIX', ativo: true);

  group('Busca de Formas de Pagamento', () {
    test('Deve retornar uma forma de pagamento ao buscar por ID', () async {
      final casoDeUso = BuscarFormaPagamentoPorId(mockRepositorio);
      when(mockRepositorio.buscarPorId(any))
          .thenAnswer((_) async => formaPagamento);
      final resultado = await casoDeUso.executar('fp-1');
      expect(resultado, formaPagamento);
    });

    test('Deve retornar uma forma de pagamento ao buscar por NOME', () async {
      final casoDeUso = BuscarFormaPagamentoPorNome(mockRepositorio);
      when(mockRepositorio.buscarPorNome(any))
          .thenAnswer((_) async => formaPagamento);
      final resultado = await casoDeUso.executar('PIX');
      expect(resultado, formaPagamento);
    });

    test('Deve retornar uma LISTA de formas de pagamento', () async {
      final casoDeUso = ListarFormasPagamento(mockRepositorio);
      final lista = [formaPagamento];
      when(mockRepositorio.listarTodos(
              incluirInativos: anyNamed('incluirInativos')))
          .thenAnswer((_) async => lista);
      final resultado = await casoDeUso.executar();
      expect(resultado, lista);
    });
  });
}
