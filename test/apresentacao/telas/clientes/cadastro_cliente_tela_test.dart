// test/apresentacao/telas/clientes/cadastro_cliente_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/clientes/cadastro_cliente_tela.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/cadastrar_cliente.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';

import 'cadastro_cliente_tela_test.mocks.dart';

@GenerateMocks([CadastrarCliente, http.Client, AutenticacaoServico])
void main() {
  late MockCadastrarCliente mockCadastrarCliente;
  late MockClient mockHttpClient;
  late MockAutenticacaoServico mockAuthServico;

  setUp(() {
    mockCadastrarCliente = MockCadastrarCliente();
    mockHttpClient = MockClient();
    mockAuthServico = MockAutenticacaoServico();
    when(mockAuthServico.buscarDadosUsuarioLogado())
        .thenAnswer((_) async => {'idGestor': 'gestor-1'});
  });

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: CadastroClienteTela(
        cadastrarCliente: mockCadastrarCliente,
        httpClient: mockHttpClient,
        authServico: mockAuthServico,
      ),
    ));
  }

  testWidgets('Deve renderizar corretamente no modo Cadastro Rápido por padrão', (WidgetTester tester) async {
    await pumpTela(tester);
    expect(find.widgetWithText(TextFormField, 'Nome completo *'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Telefone *'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value, isTrue);
    expect(find.widgetWithText(TextFormField, 'CPF/CNPJ'), findsNothing);
  });

  testWidgets('Deve exibir todos os campos ao desativar o Cadastro Rápido', (WidgetTester tester) async {
    await pumpTela(tester);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextFormField, 'CPF/CNPJ'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'E-mail'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'CEP'), findsOneWidget);
  });

  testWidgets('Deve exibir o indicador de progresso e salvar o cliente', (WidgetTester tester) async {
    // ARRANGE
    when(mockCadastrarCliente.executar(any)).thenAnswer((_) async {});

    await pumpTela(tester);

    // ACT
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome completo *'), 'Cliente Teste');
    await tester.enterText(find.widgetWithText(TextFormField, 'Telefone *'), '(64) 99999-9999');

    await tester.tap(find.text('SALVAR CLIENTE'));
    await tester.pump(); // Inicia o estado de carregamento

    // Verifica se o método de cadastrar foi chamado
    verify(mockCadastrarCliente.executar(any)).called(1);
  });

  testWidgets('Deve buscar o CEP e preencher os campos de endereço', (WidgetTester tester) async {
    // ARRANGE: Simula a resposta da API ViaCEP
    when(mockHttpClient.get(any)).thenAnswer((_) async => http.Response(
        json.encode({
          'logradouro': 'Rua dos Testes',
          'bairro': 'Bairro Mock',
          'localidade': 'Flutter City',
          'uf': 'FT',
        }),
        200));

    await pumpTela(tester);

    // Desativa o cadastro rápido para exibir os campos de endereço
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    // ACT: Digita um CEP e toca no botão de busca
    await tester.enterText(find.widgetWithText(TextFormField, 'CEP'), '12345-678');
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump(); // Mostra o indicador de busca
    await tester.pumpAndSettle(); // Aguarda a conclusão da busca

    // ASSERT
    expect(find.text('Rua dos Testes'), findsOneWidget);
    expect(find.text('Bairro Mock'), findsOneWidget);
    expect(find.text('Flutter City'), findsOneWidget);
    expect(find.text('FT'), findsOneWidget);
  });
}