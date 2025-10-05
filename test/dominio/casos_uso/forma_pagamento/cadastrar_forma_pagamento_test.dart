// test/dominio/casos_uso/forma_pagamento/cadastrar_forma_pagamento_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/cadastrar_forma_pagamento.dart';
import 'package:gerenciar/dominio/interfaces/forma_pagamento_repositorio_interface.dart';

import 'cadastrar_forma_pagamento_test.mocks.dart';

// Anotação para gerar o mock
@GenerateMocks([FormaPagamentoRepositorioInterface])
void main() {
  // 1. Preparação (Setup)
  late MockFormaPagamentoRepositorioInterface mockRepositorio;
  late CadastrarFormaPagamento casoDeUso;

  setUp(() {
    mockRepositorio = MockFormaPagamentoRepositorioInterface();
    casoDeUso = CadastrarFormaPagamento(mockRepositorio);
  });

  // AQUI ESTÁ A CORREÇÃO
  final formaPagamentoExemplo = FormaPagamento(
    id: 'fp-1',
    nome: 'PIX',
    descricao: 'Pagamento instantâneo',
    ativo: true,
    idGestor: 'gestor-1', // ADICIONADO
  );

  test(
      'Deve chamar o método adicionar do repositório ao cadastrar uma forma de pagamento',
      () async {
    // Configura o mock
    when(mockRepositorio.adicionar(any)).thenAnswer((_) async => {});

    /// 2. Ação (Act)
    await casoDeUso.executar(formaPagamentoExemplo);

    // 3. Verificação (Assert)
    verify(mockRepositorio.adicionar(formaPagamentoExemplo));
    verifyNoMoreInteractions(mockRepositorio);
  });
}
