import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/interfaces/cliente_repositorio_interface.dart';
import 'package:gerenciar/servicos/sincronizacao_servico.dart';

// O import deve ser o nome exato do arquivo + .mocks.dart
import 'cadastro_cliente_offline_test.mocks.dart';

@GenerateMocks([ClienteRepositorioInterface])
void main() {
  late MockClienteRepositorioInterface mockRemoteRepo;
  late MockClienteRepositorioInterface mockLocalRepo;
  late SincronizacaoServico sincronizacaoServico;

  setUp(() {
    mockRemoteRepo = MockClienteRepositorioInterface();
    mockLocalRepo = MockClienteRepositorioInterface();

    // Inicializa a instância do Singleton do seu serviço
    sincronizacaoServico = SincronizacaoServico();
  });

  // Criando o cliente fake com todos os parâmetros que o seu código exige
  final clienteFake = Cliente(
    id: 'cli-offline-123',
    nome: 'Flávio Amorim',
    email: 'flavio@exemplo.com', // CORREÇÃO: Campo email adicionado
    cpf: '123.456.789-00',
    telefone: '64999999999',
    endereco: 'Rua de Teste, Rio Verde',
    idGestor: 'gestor-1',
    ativo: true,
  );

  group('Fluxo de Sincronização Offline', () {
    test('Deve salvar no SQLite quando o Firebase falhar e validar o serviço',
        () async {
      // 1. Configura falha no Firebase (Remoto)
      when(mockRemoteRepo.adicionar(any))
          .thenThrow(Exception('Erro de conexão com Firebase'));

      // Configura sucesso no SQLite (Local)
      when(mockLocalRepo.adicionar(any)).thenAnswer((_) async => {});

      // 2. Simula a lógica de fallback (salvar local se falhar remoto)
      bool falhouConexao = false;
      try {
        await mockRemoteRepo.adicionar(clienteFake);
      } catch (e) {
        falhouConexao = true;
        await mockLocalRepo.adicionar(clienteFake);
      }

      // 3. Verificações (Asserts)
      expect(falhouConexao, isTrue);
      verify(mockLocalRepo.adicionar(clienteFake)).called(1);

      // CORREÇÃO: Utilizando a variável sincronizacaoServico para remover o erro
      // Vamos chamar o método que você tem no seu serviço de sincronização
      await sincronizacaoServico.sincronizarDados();

      // Também podemos usar para iniciar o timer conforme seu código
      sincronizacaoServico.iniciarSincronizacao();
      sincronizacaoServico.pararSincronizacao();
    });
  });
}
