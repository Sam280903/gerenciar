// test/apresentacao/telas/clientes/detalhes_cliente_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/clientes/detalhes_cliente_tela.dart';
import 'package:gerenciar/apresentacao/telas/clientes/editar_cliente_tela.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/interfaces/cliente_repositorio_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'detalhes_cliente_tela_test.mocks.dart';

// A anotação para gerar o mock do repositório
@GenerateMocks([ClienteRepositorioInterface])
void main() {
  late MockClienteRepositorioInterface mockClienteRepositorio;

  // Cliente de exemplo que será usado nos testes
  final clienteAtivo = Cliente(
    id: 'cliente-1',
    nome: 'Cliente Teste Ativo',
    email: 'ativo@teste.com',
    telefone: '64999998888',
    endereco: 'Rua dos Testes, 123',
    cpf: '123.456.789-00',
    ativo: true,
    idGestor: 'gestor-1',
  );

  // Função para "inflar" a tela de detalhes com o cliente de exemplo
  Future<void> pumpTela(WidgetTester tester, Cliente cliente) async {
    await tester.pumpWidget(MaterialApp(
      home: DetalhesClienteTela(cliente: cliente),
      // Adicionamos uma rota para a tela de edição para evitar erros de navegação
      routes: {
        '/editar-cliente': (_) => EditarClienteTela(cliente: cliente),
      },
    ));
  }

  setUp(() {
    mockClienteRepositorio = MockClienteRepositorioInterface();
  });

  testWidgets('Deve exibir todos os dados do cliente na tela de detalhes',
      (WidgetTester tester) async {
    // ARRANGE & ACT
    await pumpTela(tester, clienteAtivo);

    // ASSERT
    expect(find.text('Cliente Teste Ativo'), findsOneWidget);
    expect(find.text('123.456.789-00'), findsOneWidget);
    expect(find.text('64999998888'), findsOneWidget);
    expect(find.text('ativo@teste.com'), findsOneWidget);
    expect(find.text('Rua dos Testes, 123'), findsOneWidget);
    expect(find.text('Ativo'), findsOneWidget);
  });

  testWidgets('Deve chamar o método de inativar ao confirmar a inativação',
      (WidgetTester tester) async {
    // ARRANGE
    // Configura o mock para o método 'inativar'
    when(mockClienteRepositorio.inativar(any)).thenAnswer((_) async => {});

    await pumpTela(tester, clienteAtivo);

    // ACT
    // 1. Toca no botão 'INATIVAR'
    await tester.tap(find.widgetWithText(OutlinedButton, 'INATIVAR'));
    await tester.pumpAndSettle(); // Aguarda o diálogo aparecer

    // 2. Verifica se o diálogo está visível
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Confirmar Inativação'), findsOneWidget);

    // 3. Toca no botão de confirmação dentro do diálogo
    await tester.tap(find.widgetWithText(TextButton, 'INATIVAR'));
    await tester.pumpAndSettle(); // Aguarda a ação ser concluída

    // ASSERT
    // Verifica se o método inativar do repositório foi chamado com o ID correto
    verify(mockClienteRepositorio.inativar(clienteAtivo.id)).called(1);
  });

  testWidgets('Deve navegar para a tela de edição ao tocar em EDITAR',
      (WidgetTester tester) async {
    // ARRANGE
    await pumpTela(tester, clienteAtivo);

    // ACT
    await tester.tap(find.widgetWithText(ElevatedButton, 'EDITAR'));
    await tester.pumpAndSettle(); // Aguarda a navegação

    // ASSERT
    // Verifica se a tela de edição foi aberta
    expect(find.byType(EditarClienteTela), findsOneWidget);
    expect(find.text("Editar Cliente"), findsOneWidget);
  });
}
