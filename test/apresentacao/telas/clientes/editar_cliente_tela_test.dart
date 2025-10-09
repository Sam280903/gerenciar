// test/apresentacao/telas/clientes/editar_cliente_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/clientes/editar_cliente_tela.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/interfaces/cliente_repositorio_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Reutilizamos o mock gerado no teste de detalhes
import 'detalhes_cliente_tela_test.mocks.dart';

@GenerateMocks([ClienteRepositorioInterface])
void main() {
  late MockClienteRepositorioInterface mockClienteRepositorio;

  final clienteParaEditar = Cliente(
    id: 'cliente-edit-1',
    nome: 'Cliente Original',
    email: 'original@teste.com',
    telefone: '64111112222',
    endereco: 'Rua Antiga, 0',
    cpf: '111.111.111-11',
    ativo: true,
    idGestor: 'gestor-1',
  );

  Future<void> pumpTela(WidgetTester tester, Cliente cliente) async {
    await tester.pumpWidget(MaterialApp(
      home: EditarClienteTela(cliente: cliente),
    ));
  }

  setUp(() {
    mockClienteRepositorio = MockClienteRepositorioInterface();
  });

  testWidgets('Deve preencher os campos do formulário com os dados do cliente',
      (WidgetTester tester) async {
    // ARRANGE & ACT
    await pumpTela(tester, clienteParaEditar);

    // ASSERT
    expect(find.text('Cliente Original'), findsOneWidget);
    expect(find.text('64111112222'), findsOneWidget);
    expect(find.text('111.111.111-11'), findsOneWidget);
    expect(find.text('original@teste.com'), findsOneWidget);
    expect(find.text('Rua Antiga'), findsOneWidget);
  });

  testWidgets(
      'Deve chamar o método de atualizar com os dados modificados ao salvar',
      (WidgetTester tester) async {
    // ARRANGE
    when(mockClienteRepositorio.atualizar(any)).thenAnswer((_) async => {});

    await pumpTela(tester, clienteParaEditar);

    // ACT
    // 1. Limpa o campo de nome e insere um novo nome
    await tester.enterText(find.widgetWithText(TextFormField, 'Nome completo'),
        'Cliente Modificado');

    // 2. Toca no botão para salvar
    await tester.tap(find.text('SALVAR ALTERAÇÕES'));
    await tester.pump(); // Inicia o carregamento

    // ASSERT
    // 1. Verifica se o CircularProgressIndicator apareceu
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 2. Verifica se o método 'atualizar' foi chamado com o nome modificado
    verify(mockClienteRepositorio.atualizar(argThat(
      isA<Cliente>().having((c) => c.nome, 'nome', 'Cliente Modificado'),
    ))).called(1);
  });
}
