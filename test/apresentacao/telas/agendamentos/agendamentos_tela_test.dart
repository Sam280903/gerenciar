// test/apresentacao/telas/agendamentos/agendamentos_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/agendamentos/agendamentos_tela.dart';
import 'package:gerenciar/dados/repositorios/agendamento/agendamento_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'agendamentos_tela_test.mocks.dart';

@GenerateMocks([
  AgendamentoRepositorioAdaptativo,
  ClienteRepositorioAdaptativo,
  TecnicoRepositorioAdaptativo
])
void main() {
  late MockAgendamentoRepositorioAdaptativo mockAgendamentoRepo;
  late MockClienteRepositorioAdaptativo mockClienteRepo;
  late MockTecnicoRepositorioAdaptativo mockTecnicoRepo;

  final clienteExemplo = Cliente(id: 'cli-1', nome: 'Cliente Exemplo', email: '', telefone: '', endereco: '', ativo: true);
  final tecnicoExemplo = Tecnico(id: 'tec-1', nome: 'Tecnico Exemplo', email: '', telefone: '', ativo: true);
  final agendamentoProximo = Agendamento(
    id: 'ag-1',
    idCliente: 'cli-1',
    idTecnico: 'tec-1',
    dataHora: DateTime.now().add(const Duration(days: 1)),
    status: 'Pendente',
    ativo: true,
  );

  setUp(() {
    mockAgendamentoRepo = MockAgendamentoRepositorioAdaptativo();
    mockClienteRepo = MockClienteRepositorioAdaptativo();
    mockTecnicoRepo = MockTecnicoRepositorioAdaptativo();
  });

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AgendamentosTela(
        agendamentoRepo: mockAgendamentoRepo,
        clienteRepo: mockClienteRepo,
        tecnicoRepo: mockTecnicoRepo,
      ),
    ));
  }

  testWidgets('Deve exibir a lista de agendamentos próximos', (WidgetTester tester) async {
    // ARRANGE
    when(mockAgendamentoRepo.listarTodos(incluirInativos: anyNamed('incluirInativos')))
        .thenAnswer((_) async => [agendamentoProximo]);
    when(mockClienteRepo.buscarPorId(any)).thenAnswer((_) async => clienteExemplo);
    when(mockTecnicoRepo.buscarPorId(any)).thenAnswer((_) async => tecnicoExemplo);

    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    // ASSERT
    expect(find.text('Cliente Exemplo'), findsOneWidget);
    expect(find.text('Técnico: Tecnico Exemplo'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Deve exibir mensagem quando não houver agendamentos', (WidgetTester tester) async {
    // ARRANGE
    when(mockAgendamentoRepo.listarTodos(incluirInativos: anyNamed('incluirInativos')))
        .thenAnswer((_) async => []);
    when(mockClienteRepo.buscarPorId(any)).thenAnswer((_) async => null);
    when(mockTecnicoRepo.buscarPorId(any)).thenAnswer((_) async => null);

    // ACT
    await pumpTela(tester);
    await tester.pumpAndSettle();

    // ASSERT
    expect(find.text('Nenhum agendamento próximo.'), findsOneWidget);
  });
}