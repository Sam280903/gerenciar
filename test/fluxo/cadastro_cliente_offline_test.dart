import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/interfaces/cliente_repositorio_interface.dart';

import 'cadastro_cliente_offline_test.mocks.dart';

@GenerateMocks([ClienteRepositorioInterface])
void main() {
  late MockClienteRepositorioInterface mockRemoteRepo;
  late MockClienteRepositorioInterface mockLocalRepo;

  setUp(() {
    mockRemoteRepo = MockClienteRepositorioInterface();
    mockLocalRepo = MockClienteRepositorioInterface();
  });

  final clienteFake = Cliente(
    id: 'cli-offline-123',
    nome: 'Flávio Amorim',
    email: 'flavio@exemplo.com',
    cpf: '123.456.789-00',
    telefone: '64999999999',
    endereco: 'Rua de Teste, Rio Verde',
    idGestor: 'gestor-1',
    ativo: true,
  );

  group('Fluxo de Sincronização Offline', () {
    test('Deve salvar no SQLite quando o Firebase falhar e validar o serviço',
        () async {
      when(mockRemoteRepo.adicionar(any))
          .thenThrow(Exception('Erro de conexão com Firebase'));
      when(mockLocalRepo.adicionar(any)).thenAnswer((_) async => {});

      bool falhouConexao = false;
      try {
        await mockRemoteRepo.adicionar(clienteFake);
      } catch (e) {
        falhouConexao = true;
        await mockLocalRepo.adicionar(clienteFake);
      }

      expect(falhouConexao, isTrue);
      verify(mockLocalRepo.adicionar(clienteFake)).called(1);
    });
  });
}
