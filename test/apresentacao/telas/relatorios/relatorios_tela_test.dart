// test/apresentacao/telas/relatorios/relatorios_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/relatorios/relatorios_tela.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/listar_clientes.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/listar_tecnicos.dart';
import 'package:gerenciar/servicos/relatorio_servico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'relatorios_tela_test.mocks.dart';

@GenerateMocks([RelatorioServico, ListarTecnicos, ListarClientes])
void main() {
  late MockRelatorioServico mockRelatorioServico;
  late MockListarTecnicos mockListarTecnicos;
  late MockListarClientes mockListarClientes;

  setUp(() {
    mockRelatorioServico = MockRelatorioServico();
    mockListarTecnicos = MockListarTecnicos();
    mockListarClientes = MockListarClientes();
  });

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RelatoriosTela(
        relatorioServico: mockRelatorioServico,
        listarTecnicos: mockListarTecnicos,
        listarClientes: mockListarClientes,
      ),
    ));
  }

  testWidgets('Deve renderizar todos os campos de filtro', (WidgetTester tester) async {
    await pumpTela(tester);

    expect(find.widgetWithText(TextFormField, 'Data Inicial'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Data Final'), findsOneWidget);
    // Os campos de Técnico e Cliente usam InputDecorator com o texto 'Todos'
    expect(find.widgetWithText(InputDecorator, 'Todos'), findsNWidgets(2)); 
    // O Dropdown de Status também tem o texto 'Todos' como hint
    expect(find.widgetWithText(DropdownButtonFormField<String>, 'Todos'), findsOneWidget);
    expect(find.text('GERAR RELATÓRIO'), findsOneWidget);
  });

  testWidgets('Deve mostrar o indicador de progresso e texto "GERANDO..." ao gerar relatório', (WidgetTester tester) async {
    // ARRANGE: Configura o mock para simular a geração do relatório
    when(mockRelatorioServico.gerarRelatorioOrdensServico(any))
        .thenAnswer((_) async => []); // Retorna uma lista vazia para o teste

    await pumpTela(tester);

    // ACT: Toca no botão para gerar o relatório
    await tester.tap(find.text('GERAR RELATÓRIO'));
    await tester.pump(); // Inicia o estado de carregamento

    // ASSERT
    // Verifica se o indicador de progresso está visível dentro do botão
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // Verifica se o texto do botão mudou para "GERANDO..."
    expect(find.text('GERANDO...'), findsOneWidget);
    
    // Verifica se o serviço para gerar o relatório foi chamado
    verify(mockRelatorioServico.gerarRelatorioOrdensServico(any)).called(1);
  });
}