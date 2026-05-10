// test/apresentacao/telas/ordens_servico/editar_os_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/ordens_servico/editar_os_tela.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/buscar_forma_pagamento_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/listar_formas_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/atualizar_ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'editar_os_tela_test.mocks.dart';

@GenerateMocks([
  AtualizarOrdemServico,
  BuscarFormaPagamentoPorId,
  ListarFormasPagamento,
  AutenticacaoServico,
])
void main() {
  late MockAtualizarOrdemServico mockAtualizarOS;
  late MockBuscarFormaPagamentoPorId mockBuscarFormaPagamento;
  late MockListarFormasPagamento mockListarFormasPagamento;
  late MockAutenticacaoServico mockAuthServico;

  final formaPagamentoExemplo = FormaPagamento(
    id: 'fp1',
    nome: 'Dinheiro',
    ativo: true,
    idGestor: 'gestor-1',
  );

  final osParaEditar = OrdemServico(
    id: 'os-edit-1',
    idCliente: 'c1',
    idTecnico: 't1',
    idFormaPagamento: 'fp1',
    idGestor: 'gestor-1',
    dataHoraInicio: DateTime.now(),
    descricao: 'Descrição Original',
    valor: 100.0,
    prioridade: 'Média',
    status: 'Pendente',
    ativo: true,
  );

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: EditarOSTela(
        ordemServico: osParaEditar,
        atualizarOS: mockAtualizarOS,
        buscarFormaPagamento: mockBuscarFormaPagamento,
        listarFormasPagamento: mockListarFormasPagamento,
        authServico: mockAuthServico,
      ),
    ));
  }

  setUp(() {
    mockAtualizarOS = MockAtualizarOrdemServico();
    mockBuscarFormaPagamento = MockBuscarFormaPagamentoPorId();
    mockListarFormasPagamento = MockListarFormasPagamento();
    mockAuthServico = MockAutenticacaoServico();

    // Stub todas as dependências usadas no initState
    when(mockAuthServico.buscarDadosUsuarioLogado())
        .thenAnswer((_) async => {'perfil': 'gestor', 'idGestor': 'gestor-1'});
    when(mockAuthServico.buscarDadosUsuarioLogado(forcarAtualizacao: anyNamed('forcarAtualizacao')))
        .thenAnswer((_) async => {'perfil': 'gestor', 'idGestor': 'gestor-1'});
    when(mockBuscarFormaPagamento.executar(any))
        .thenAnswer((_) async => formaPagamentoExemplo);
    when(mockListarFormasPagamento.executar(idGestor: anyNamed('idGestor')))
        .thenAnswer((_) async => [formaPagamentoExemplo]);
  });

  testWidgets('Deve preencher os campos com os dados da OS',
      (WidgetTester tester) async {
    await pumpTela(tester);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Descrição Original'), findsOneWidget);
    expect(find.text('100.00'), findsOneWidget);
    expect(find.text('Média'), findsOneWidget);
  });

  testWidgets('Deve chamar o método de atualizar ao salvar',
      (WidgetTester tester) async {
    when(mockAtualizarOS.executar(any)).thenAnswer((_) async {});
    await pumpTela(tester);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Descrição do Problema'),
        'Descrição Modificada');
    await tester.pump();

    await tester.tap(find.text('SALVAR ALTERAÇÕES'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    verify(mockAtualizarOS.executar(argThat(
      isA<OrdemServico>()
          .having((os) => os.descricao, 'descricao', 'Descrição Modificada'),
    ))).called(1);
  });

  testWidgets('Deve exibir o formulário com os campos essenciais',
      (WidgetTester tester) async {
    await pumpTela(tester);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.widgetWithText(TextFormField, 'Descrição do Problema'),
        findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Data de Abertura'),
        findsOneWidget);
    expect(find.text('SALVAR ALTERAÇÕES'), findsOneWidget);
  });

  testWidgets('Deve exibir erro de validação ao limpar a descrição',
      (WidgetTester tester) async {
    await pumpTela(tester);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Apaga a descrição
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Descrição do Problema'), '');
    await tester.pump();

    await tester.tap(find.text('SALVAR ALTERAÇÕES'));
    await tester.pump();

    expect(find.text('Campo obrigatório'), findsOneWidget);
    verifyNever(mockAtualizarOS.executar(any));
  });

  testWidgets('Deve exibir SnackBar de erro caso a atualização falhe',
      (WidgetTester tester) async {
    when(mockAtualizarOS.executar(any))
        .thenThrow(Exception('Falha no servidor de banco de dados'));
    
    await pumpTela(tester);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tap(find.text('SALVAR ALTERAÇÕES'));
    await tester.pump(); // state
    await tester.pump(); // snackbar

    expect(find.textContaining('Falha no servidor de banco de dados'), findsOneWidget);
  });
}
