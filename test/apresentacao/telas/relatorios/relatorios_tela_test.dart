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
    expect(find.widgetWithText(InputDecorator, 'Todos'), findsNWidgets(2)); // Técnico e Cliente
    expect(find.widgetWithText(DropdownButtonFormField<String>, 'Todos'), findsOneWidget);
    expect(find.text('GERAR RELATÓRIO'), findsOneWidget);
  });

  testWidgets('Deve mostrar o indicador de progresso ao gerar relatório', (WidgetTester tester) async {
    // ARRANGE
    when(mockRelatorioServico.gerarRelatorioOrdensServico(any))
        .thenAnswer((_) async => []);

    await pumpTela(tester);

    // ACT
    await tester.tap(find.text('GERAR RELATÓRIO'));
    await tester.pump();

    // ASSERT
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Verifica se o serviço foi chamado
    verify(mockRelatorioServico.gerarRelatorioOrdensServico(any)).called(1);
  });
}