// test/fluxos/cadastro_cliente_fluxo_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/clientes/clientes_tela.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/cadastrar_cliente.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/listar_clientes.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'cadastro_cliente_fluxo_test.mocks.dart';

@GenerateMocks([
  ListarClientes,
  CadastrarCliente,
  AutenticacaoServico,
  http.Client,
])
void main() {
  late MockListarClientes mockListarClientes;
  late MockCadastrarCliente mockCadastrarCliente;
  late MockAutenticacaoServico mockAuthServico;
  late MockClient mockHttpClient;

  final novoCliente = Cliente(
    id: 'cliente-novo-1',
    nome: 'Cliente de Integração',
    telefone: '64912345678',
    email: '',
    endereco: '',
    cpf: '',
    ativo: true,
    idGestor: 'gestor-1',
  );

  setUp(() {
    mockListarClientes = MockListarClientes();
    mockCadastrarCliente = MockCadastrarCliente();
    mockAuthServico = MockAutenticacaoServico();
    mockHttpClient = MockClient();

    when(mockAuthServico.buscarDadosUsuarioLogado())
        .thenAnswer((_) async => {'idGestor': 'gestor-1'});
  });

  testWidgets('Deve cadastrar um novo cliente e exibi-lo na lista',
      (WidgetTester tester) async {
    // ARRANGE
    var callCount = 0;
    when(mockListarClientes.executar(
      idGestor: anyNamed('idGestor'),
      incluirInativos: anyNamed('incluirInativos'),
    )).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) {
        return []; // 1ª chamada: retorna lista vazia
      } else {
        return [novoCliente]; // 2ª chamada: retorna lista com o novo item
      }
    });

    when(mockCadastrarCliente.executar(any)).thenAnswer((_) async {});

    await tester.pumpWidget(MaterialApp(
      home: ClientesTela(
        listarClientes: mockListarClientes,
        httpClient: mockHttpClient,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Nenhum cliente ativo cadastrado.'), findsOneWidget);

    // ACT
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Novo Cliente'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome completo *'),
        novoCliente.nome);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Telefone *'), novoCliente.telefone);

    await tester.tap(find.text('SALVAR CLIENTE'));

    await tester.pumpAndSettle();

    // ASSERT
    expect(find.byType(ClientesTela), findsOneWidget);
    expect(find.text('Nenhum cliente ativo cadastrado.'), findsNothing);
    expect(find.text('Cliente de Integração'), findsOneWidget);
  });
}
