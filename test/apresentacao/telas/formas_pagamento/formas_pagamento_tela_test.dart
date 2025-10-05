// test/apresentacao/telas/formas_pagamento/formas_pagamento_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/formas_pagamento/formas_pagamento_tela.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/listar_formas_pagamento.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart'; // ADICIONADO
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'formas_pagamento_tela_test.mocks.dart';

@GenerateMocks([
  ListarFormasPagamento,
  AutenticacaoServico
]) // ADICIONADO AutenticacaoServico
void main() {
  late MockListarFormasPagamento mockListarFormasPagamento;
  late MockAutenticacaoServico mockAuthServico; // ADICIONADO

  // DADOS ATUALIZADOS
  final mockFormasPagamento = [
    FormaPagamento(
        id: '1',
        nome: 'Dinheiro',
        descricao: 'Pagamento em espécie',
        ativo: true,
        idGestor: 'gestor-1'),
    FormaPagamento(
        id: '2',
        nome: 'Cartão de Crédito',
        descricao: 'Pagamento parcelado',
        ativo: true,
        idGestor: 'gestor-1'),
  ];

  setUp(() {
    mockListarFormasPagamento = MockListarFormasPagamento();
    mockAuthServico = MockAutenticacaoServico(); // ADICIONADO

    // Simula o serviço de autenticação para todos os testes neste grupo
    when(mockAuthServico.buscarDadosUsuarioLogado())
        .thenAnswer((_) async => {'idGestor': 'gestor-1'});
  });

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: FormasPagamentoTela(
        listarFormasPagamento: mockListarFormasPagamento,
        // O authServico não é injetado pelo construtor, mas o mock precisa existir
      ),
    ));
  }

  testWidgets('Deve exibir a lista de formas de pagamento após o carregamento',
      (WidgetTester tester) async {
    // ARRANGE - CORRIGIDO
    when(mockListarFormasPagamento.executar(
            idGestor: anyNamed('idGestor'),
            incluirInativos: anyNamed('incluirInativos')))
        .thenAnswer((_) async => mockFormasPagamento);

    // ACT
    await pumpTela(tester);

    // Injetar o mock do authServico manualmente se necessário (neste caso, a tela cria sua própria instância, então o mock global funciona)
    // A tela irá chamar o _authServico internamente. Como estamos usando um mock global, ele será interceptado.

    await tester.pumpAndSettle();

    // ASSERT
    expect(find.text('Dinheiro'), findsOneWidget);
    expect(find.text('Cartão de Crédito'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.widgetWithText(FloatingActionButton, 'NOVA FORMA'),
        findsOneWidget);
  });

  testWidgets(
      'Deve exibir mensagem quando a lista de formas de pagamento está vazia',
      (WidgetTester tester) async {
    // ARRANGE - CORRIGIDO
    when(mockListarFormasPagamento.executar(
            idGestor: anyNamed('idGestor'),
            incluirInativos: anyNamed('incluirInativos')))
        .thenAnswer((_) async => []);

    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    // ASSERT
    expect(find.text('Nenhuma forma de pagamento ativa.'), findsOneWidget);
  });

  testWidgets('Deve filtrar a lista ao digitar no campo de busca',
      (WidgetTester tester) async {
    // ARRANGE - CORRIGIDO
    when(mockListarFormasPagamento.executar(
            idGestor: anyNamed('idGestor'),
            incluirInativos: anyNamed('incluirInativos')))
        .thenAnswer((_) async => mockFormasPagamento);

    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    expect(find.text('Dinheiro'), findsOneWidget);
    expect(find.text('Cartão de Crédito'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Dinheiro');
    await tester.pumpAndSettle();

    // ASSERT
    expect(find.text('Dinheiro'), findsOneWidget);
    expect(find.text('Cartão de Crédito'), findsNothing);
  });
}
