// test/dominio/casos_uso/cliente/busca_cliente_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/buscar_cliente_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/listar_clientes.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';

import 'cadastrar_cliente_test.mocks.dart';

void main() {
  late MockClienteRepositorioInterface mockRepositorio;
  late BuscarClientePorId buscarPorId;
  late ListarClientes listar;

  setUp(() {
    mockRepositorio = MockClienteRepositorioInterface();
    buscarPorId = BuscarClientePorId(mockRepositorio);
    listar = ListarClientes(mockRepositorio);
  });

  final clienteExemplo = Cliente(
    id: 'cliente-123',
    nome: 'Maria Silva',
    email: 'maria@teste.com',
    telefone: '64987654321',
    endereco: 'Rua das Flores, 123',
    cpf: '123.456.789-00',
    ativo: true,
  );

  group('Busca de Clientes', () {
    test('Deve retornar um cliente ao buscar por id', () async {
      when(mockRepositorio.buscarPorId(any))
          .thenAnswer((_) async => clienteExemplo);
      final resultado = await buscarPorId.executar('cliente-123');
      expect(resultado, clienteExemplo);
      verify(mockRepositorio.buscarPorId('cliente-123'));
    });

    test('Deve retornar uma lista de clientes', () async {
      final lista = [clienteExemplo];
      when(mockRepositorio.listarTodos(
              incluirInativos: anyNamed('incluirInativos')))
          .thenAnswer((_) async => lista);
      final resultado = await listar.executar();
      expect(resultado, lista);
      verify(mockRepositorio.listarTodos(incluirInativos: false));
    });
  });
}
