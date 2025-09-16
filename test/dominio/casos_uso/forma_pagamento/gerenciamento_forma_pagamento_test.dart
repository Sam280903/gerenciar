// test/dominio/casos_uso/forma_pagamento/gerenciamento_forma_pagamento_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/atualizar_forma_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/inativar_forma_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/reativar_forma_pagamento.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';

import 'cadastrar_forma_pagamento_test.mocks.dart';

void main() {
  late MockFormaPagamentoRepositorioInterface mockRepositorio;

  setUp(() {
    mockRepositorio = MockFormaPagamentoRepositorioInterface();
  });

  final formaPagamento =
      FormaPagamento(id: 'fp-1', nome: 'Dinheiro', ativo: true);

  group('Gerenciamento de Formas de Pagamento', () {
    test('Deve chamar o método ATUALIZAR do repositório', () async {
      final casoDeUso = AtualizarFormaPagamento(mockRepositorio);
      when(mockRepositorio.atualizar(any)).thenAnswer((_) async => {});
      await casoDeUso.executar(formaPagamento);
      verify(mockRepositorio.atualizar(formaPagamento));
    });

    test('Deve chamar o método INATIVAR do repositório', () async {
      final casoDeUso = InativarFormaPagamento(mockRepositorio);
      when(mockRepositorio.inativar(any)).thenAnswer((_) async => {});
      await casoDeUso.executar(formaPagamento.id);
      verify(mockRepositorio.inativar(formaPagamento.id));
    });

    test('Deve chamar o método REATIVAR do repositório', () async {
      final casoDeUso = ReativarFormaPagamento(mockRepositorio);
      when(mockRepositorio.reativar(any)).thenAnswer((_) async => {});
      await casoDeUso.executar(formaPagamento.id);
      verify(mockRepositorio.reativar(formaPagamento.id));
    });
  });
}
