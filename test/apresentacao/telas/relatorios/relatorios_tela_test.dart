// test/apresentacao/telas/relatorios/relatorios_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/relatorios/relatorios_tela.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/listar_clientes.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/listar_tecnicos.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart'; // ADICIONADO
import 'package:gerenciar/servicos/relatorio_servico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'relatorios_tela_test.mocks.dart';

@GenerateMocks([
  RelatorioServico,
  ListarTecnicos,
  ListarClientes,
  AutenticacaoServico
]) // ADICIONADO AutenticacaoServico
void main() {
  late MockRelatorioServico mockRelatorioServico;
  late MockListarTecnicos mockListarTecnicos;
  late MockListarClientes mockListarClientes;
  late MockAutenticacaoServico mockAuthServico; // ADICIONADO

  setUp(() {
    mockRelatorioServico = MockRelatorioServico();
    mockListarTecnicos = MockListarTecnicos();
    mockListarClientes = MockListarClientes();
    mockAuthServico = MockAutenticacaoServico(); // ADICIONADO

    when(mockAuthServico.buscarDadosUsuarioLogado())
        .thenAnswer((_) async => {'idGestor': 'gestor-1'});
  });

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: RelatoriosTela(
        relatorioServico: mockRelatorioServico,
        listarTecnicos: mockListarTecnicos,
        listarClientes: mockListarClientes,
        authServico: mockAuthServico,
      ),
    ));
  }

  testWidgets('Deve renderizar todos os campos de filtro',
      (WidgetTester tester) async {
    await pumpTela(tester);
    await tester.pumpAndSettle(); // Aguarda o _carregarDadosIniciais

    expect(find.widgetWithText(TextFormField, 'Data Inicial'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Data Final'), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String?>), findsOneWidget);
    expect(find.text('GERAR RELATÓRIO'), findsOneWidget);
  });

  testWidgets(
      'Deve mostrar o indicador de progresso e texto "GERANDO..." ao gerar relatório',
      (WidgetTester tester) async {
    // ARRANGE - CORRIGIDO
    when(mockRelatorioServico.gerarRelatorioOrdensServico(any, any))
        .thenAnswer((_) async => []);

    await pumpTela(tester);
    await tester.pumpAndSettle(); // Aguarda o _carregarDadosIniciais

    // ACT
    await tester.tap(find.text('GERAR RELATÓRIO'));
    await tester.pump();

    // VERIFICA SE O MÉTODO FOI CHAMADO COM 2 ARGUMENTOS
    verify(mockRelatorioServico.gerarRelatorioOrdensServico(any, any))
        .called(1);
  });
}
