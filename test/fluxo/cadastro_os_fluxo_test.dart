// test/fluxos/cadastro_os_fluxo_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/ordens_servico/ordens_servico_tela.dart';
import 'package:gerenciar/apresentacao/widgets/_widget_selecao.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/buscar_cliente_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/listar_clientes.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/listar_formas_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/cadastrar_ordem_servico.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/listar_ordens_servico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/buscar_tecnico_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/listar_tecnicos.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/dominio/interfaces/agendamento_repositorio_interface.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'cadastro_os_fluxo_test.mocks.dart';

@GenerateMocks([
  ListarOrdensServico,
  BuscarClientePorId,
  BuscarTecnicoPorId,
  ListarClientes,
  ListarTecnicos,
  ListarFormasPagamento,
  CadastrarOrdemServico,
  AgendamentoRepositorioInterface,
  AutenticacaoServico,
])
void main() {
  late MockListarOrdensServico mockListarOS;
  late MockBuscarClientePorId mockBuscarCliente;
  late MockBuscarTecnicoPorId mockBuscarTecnico;
  late MockListarClientes mockListarClientes;
  late MockListarTecnicos mockListarTecnicos;
  late MockListarFormasPagamento mockListarFormasPagamento;
  late MockCadastrarOrdemServico mockCadastrarOS;
  late MockAgendamentoRepositorioInterface mockAgendamentoRepo;
  late MockAutenticacaoServico mockAuthServico;

  final cliente = Cliente(
      id: 'c1',
      nome: 'Cliente Para OS',
      email: '',
      telefone: '',
      endereco: '',
      ativo: true,
      idGestor: 'g1');
  final tecnico = Tecnico(
      id: 't1',
      nome: 'Técnico Para OS',
      email: '',
      telefone: '',
      ativo: true,
      idGestor: 'g1');
  final formaPgto =
      FormaPagamento(id: 'fp1', nome: 'Dinheiro', ativo: true, idGestor: 'g1');
  final novaOS = OrdemServico(
      id: 'os-nova-1',
      descricao: 'Teste de OS',
      idCliente: cliente.id,
      idTecnico: tecnico.id,
      idFormaPagamento: formaPgto.id,
      idGestor: 'g1',
      dataHoraInicio: DateTime.now(),
      valor: 150,
      prioridade: 'Baixa',
      status: 'Pendente',
      ativo: true);

  setUp(() {
    mockListarOS = MockListarOrdensServico();
    mockBuscarCliente = MockBuscarClientePorId();
    mockBuscarTecnico = MockBuscarTecnicoPorId();
    mockListarClientes = MockListarClientes();
    mockListarTecnicos = MockListarTecnicos();
    mockListarFormasPagamento = MockListarFormasPagamento();
    mockCadastrarOS = MockCadastrarOrdemServico();
    mockAgendamentoRepo = MockAgendamentoRepositorioInterface();
    mockAuthServico = MockAutenticacaoServico();

    when(mockAuthServico.buscarDadosUsuarioLogado())
        .thenAnswer((_) async => {'idGestor': 'g1'});
  });

  testWidgets('Deve criar uma nova Ordem de Serviço e exibi-la na lista',
      (WidgetTester tester) async {
    // ARRANGE
    var osCallCount = 0;
    when(mockListarOS.executar(idGestor: anyNamed('idGestor')))
        .thenAnswer((_) async {
      osCallCount++;
      if (osCallCount == 1) {
        return []; // 1ª chamada: lista vazia
      } else {
        return [novaOS]; // 2ª chamada: lista com a nova OS
      }
    });

    when(mockListarClientes.executar(idGestor: anyNamed('idGestor')))
        .thenAnswer((_) async => [cliente]);
    when(mockListarTecnicos.executar(idGestor: anyNamed('idGestor')))
        .thenAnswer((_) async => [tecnico]);
    when(mockListarFormasPagamento.executar(idGestor: anyNamed('idGestor')))
        .thenAnswer((_) async => [formaPgto]);

    when(mockAgendamentoRepo.verificarDisponibilidade(any, any))
        .thenAnswer((_) async => false);
    when(mockCadastrarOS.executar(any)).thenAnswer((_) async {});

    // Mocks para o recarregamento da lista na tela principal
    when(mockBuscarCliente.executar(cliente.id))
        .thenAnswer((_) async => cliente);
    when(mockBuscarTecnico.executar(tecnico.id))
        .thenAnswer((_) async => tecnico);

    await tester.pumpWidget(MaterialApp(
      home: OrdensServicoTela(
        listarOS: mockListarOS,
        buscarCliente: mockBuscarCliente,
        buscarTecnico: mockBuscarTecnico,
        listarClientes: mockListarClientes,
        listarTecnicos: mockListarTecnicos,
        listarFormasPagamento: mockListarFormasPagamento,
        cadastrarOS: mockCadastrarOS,
        agendamentoRepo: mockAgendamentoRepo,
      ),
    ));

    await tester.pumpAndSettle();

    // ACT
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.text('Nova Ordem de Serviço'), findsOneWidget);

    await tester.tap(find.widgetWithText(WidgetSelecao, 'Cliente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cliente Para OS'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(WidgetSelecao, 'Técnico Responsável'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Técnico Para OS'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(WidgetSelecao, 'Forma de Pagamento'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dinheiro'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Descrição do Problema'),
        'Teste de OS');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Valor do Serviço (R\$)'), '150');

    await tester.tap(find.text('SALVAR OS'));
    await tester.pumpAndSettle();

    // ASSERT FINAL
    expect(find.byType(OrdensServicoTela), findsOneWidget);
    expect(find.text('Cliente Para OS'), findsOneWidget);
    expect(find.text('Pendente'), findsOneWidget);
  });
}
