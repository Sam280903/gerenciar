// test/dominio/casos_uso/cliente/cadastrar_cliente_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/cadastrar_cliente.dart';
import 'package:gerenciar/dominio/interfaces/cliente_repositorio_interface.dart';

import 'cadastrar_cliente_test.mocks.dart';

// Anotação para gerar o mock do repositório de cliente
@GenerateMocks([ClienteRepositorioInterface])
void main() {
  // 1. Preparação (Setup)
  late MockClienteRepositorioInterface mockRepositorio;
  late CadastrarCliente casoDeUso;

  setUp(() {
    mockRepositorio = MockClienteRepositorioInterface();
    casoDeUso = CadastrarCliente(mockRepositorio);
  });

  // AQUI ESTÁ A CORREÇÃO
  final clienteExemplo = Cliente(
    id: 'cliente-123',
    nome: 'Maria Silva',
    email: 'maria@teste.com',
    telefone: '64987654321',
    endereco: 'Rua das Flores, 123',
    cpf: '123.456.789-00',
    ativo: true,
    idGestor: 'gestor-1', // ADICIONADO
  );

  test('Deve chamar o método adicionar do repositório ao cadastrar um cliente',
      () async {
    // Configura o mock para simular uma chamada bem-sucedida ao repositório.
    when(mockRepositorio.adicionar(any)).thenAnswer((_) async => {});

    // 2. Ação (Act)
    // Executa o caso de uso com o cliente de exemplo.
    await casoDeUso.executar(clienteExemplo);

    // 3. Verificação (Assert)
    // Verifica se o método 'adicionar' do mock foi chamado exatamente uma vez
    // com o cliente que criamos.
    verify(mockRepositorio.adicionar(clienteExemplo));
    verifyNoMoreInteractions(
        mockRepositorio); // Garante que mais nada foi chamado
  });
}
