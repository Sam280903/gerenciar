// test/apresentacao/telas/ordens_servico/detalhes_os_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/ordens_servico/detalhes_os_tela.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/buscar_cliente_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/buscar_tecnico_por_id.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'detalhes_os_tela_test.mocks.dart';

@GenerateMocks([BuscarClientePorId, BuscarTecnicoPorId, AutenticacaoServico])
void main() {
  late MockBuscarClientePorId mockBuscarCliente;
  late MockBuscarTecnicoPorId mockBuscarTecnico;
  late MockAutenticacaoServico mockAuthServico;

  final osExemplo = OrdemServico(
    id: 'os-123456789',
    idCliente: 'cliente-1',
    idTecnico: 'tec-1',
    idGestor: 'gestor-1',
    dataHoraInicio: DateTime.now(),
    descricao: 'Ar condicionado não está gelando.',
    valor: 250.0,
    prioridade: 'Alta',
    status: 'Pendente',
    ativo: true,
    idFormaPagamento: 'fp-1',
  );

  final clienteExemplo = Cliente(
      id: 'cliente-1',
      nome: 'Cliente da OS',
      email: '',
      telefone: '',
      endereco: 'Rua da OS, 456',
      ativo: true,
      idGestor: 'gestor-1');

  final tecnicoExemplo = Tecnico(
      id: 'tec-1',
      nome: 'Técnico da OS',
      email: '',
      telefone: '',
      ativo: true,
      idGestor: 'gestor-1');

  Future<void> pumpTela(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DetalhesOSTela(
        ordemServico: osExemplo,
        authServico: mockAuthServico,
        buscarCliente: mockBuscarCliente,
        buscarTecnico: mockBuscarTecnico,
      ),
    ));
  }

  setUp(() {
    mockBuscarCliente = MockBuscarClientePorId();
    mockBuscarTecnico = MockBuscarTecnicoPorId();
    mockAuthServico = MockAutenticacaoServico();
    when(mockAuthServico.buscarDadosUsuarioLogado())
        .thenAnswer((_) async => {'perfil': 'gestor'});
  });

  testWidgets('Deve exibir CircularProgressIndicator e depois os dados da OS',
      (WidgetTester tester) async {
    // ARRANGE
    when(mockBuscarCliente.executar(any))
        .thenAnswer((_) async => clienteExemplo);
    when(mockBuscarTecnico.executar(any))
        .thenAnswer((_) async => tecnicoExemplo);

    await pumpTela(tester);

    // ACT & ASSERT
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Cliente da OS'), findsOneWidget);
    expect(find.text('Técnico da OS'), findsOneWidget);
    expect(find.text('Ar condicionado não está gelando.'), findsOneWidget);
    expect(find.text('R\$ 250.00'), findsOneWidget);
    expect(find.text('Pendente'), findsOneWidget);
  });
}
