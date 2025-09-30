// test/apresentacao/telas/ordens_servico/ordens_servico_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/ordens_servico/ordens_servico_tela.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/buscar_cliente_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/listar_ordens_servico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/buscar_tecnico_por_id.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'ordens_servico_tela_test.mocks.dart';

@GenerateMocks([ListarOrdensServico, BuscarClientePorId, BuscarTecnicoPorId])
void main() {
  late MockListarOrdensServico mockListarOS;
  late MockBuscarClientePorId mockBuscarCliente;
  late MockBuscarTecnicoPorId mockBuscarTecnico;

  // Dados de exemplo
  final cliente1 = Cliente(id: 'c1', nome: 'Cliente A', email: '', telefone: '', endereco: '', ativo: true);
  final tecnico1 = Tecnico(id: 't1', nome: 'Tecnico A', email: '', telefone: '', ativo: true);
  final osPendente = OrdemServico(id: 'os1', idCliente: 'c1', idTecnico: 't1', dataHoraInicio: DateTime.now(), descricao: '', valor: 100, prioridade: 'Baixa', status: 'Pendente', ativo: true, idFormaPagamento: '');
  final osConcluida = OrdemServico(id: 'os2', idCliente: 'c1', idTecnico: 't1', dataHoraInicio: DateTime.now(), descricao: '', valor: 200, prioridade: 'Alta', status: 'Concluída', ativo: true, idFormaPagamento: '');

  setUp(() {
    mockListarOS = MockListarOrdensServico();
    mockBuscarCliente = MockBuscarClientePorId();
    mockBuscarTecnico = MockBuscarTecnicoPorId();
  });

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: OrdensServicoTela(
        listarOS: mockListarOS,
        buscarCliente: mockBuscarCliente,
        buscarTecnico: mockBuscarTecnico,
      ),
    ));
  }

  testWidgets('Deve exibir as OS nas abas corretas', (WidgetTester tester) async {
    // ARRANGE
    when(mockListarOS.executar()).thenAnswer((_) async => [osPendente, osConcluida]);
    when(mockBuscarCliente.executar(any)).thenAnswer((_) async => cliente1);
    when(mockBuscarTecnico.executar(any)).thenAnswer((_) async => tecnico1);

    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    // ASSERT - Aba Pendentes
    expect(find.descendant(of: find.byType(TabBarView), matching: find.text('Cliente A')), findsNWidgets(2));
    
    // Move para a aba Concluídas
    await tester.tap(find.text('CONCLUÍDAS'));
    await tester.pumpAndSettle();

    // ASSERT - Aba Concluídas
    expect(find.descendant(of: find.byType(TabBarView), matching: find.text('Cliente A')), findsOneWidget);
    expect(find.text('Concluída'), findsOneWidget);
  });

  testWidgets('Deve exibir mensagem de lista vazia', (WidgetTester tester) async {
    // ARRANGE
    when(mockListarOS.executar()).thenAnswer((_) async => []);
   
    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    // ASSERT
    expect(find.text('Nenhuma OS pendente.'), findsOneWidget);
  });
}