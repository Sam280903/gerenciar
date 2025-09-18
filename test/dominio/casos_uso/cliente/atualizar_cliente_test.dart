// test/dominio/casos_uso/cliente/atualizar_cliente_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/atualizar_cliente.dart';
<<<<<<< HEAD
// ignore: unused_import
import 'package:gerenciar/dominio/interfaces/cliente_repositorio_interface.dart';
=======
>>>>>>> e9b0753b2afe838214f05be953ba2d4f74fe5032

// Usa o mock já gerado em cadastrar_cliente_test.dart
import 'cadastrar_cliente_test.mocks.dart';

void main() {
  late MockClienteRepositorioInterface mockRepositorio;
  late AtualizarCliente casoDeUso;

  setUp(() {
    mockRepositorio = MockClienteRepositorioInterface();
    casoDeUso = AtualizarCliente(mockRepositorio);
  });

  final clienteAtualizado = Cliente(
    id: 'cliente-123',
    nome: 'Maria Silva Santos', // Nome atualizado
    email: 'maria.santos@teste.com',
    telefone: '64987654321',
    endereco: 'Rua das Flores, 123, Centro',
    cpf: '123.456.789-00',
    ativo: true,
  );

  test('Deve chamar o método atualizar do repositório ao atualizar um cliente',
      () async {
    // Arrange
    when(mockRepositorio.atualizar(any)).thenAnswer((_) async => {});

    // Act
    await casoDeUso.executar(clienteAtualizado);

    // Assert
    verify(mockRepositorio.atualizar(clienteAtualizado));
    verifyNoMoreInteractions(mockRepositorio);
  });
}
