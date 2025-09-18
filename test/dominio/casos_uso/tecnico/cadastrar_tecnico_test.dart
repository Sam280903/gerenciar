// test/dominio/casos_uso/tecnico/cadastrar_tecnico_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/cadastrar_tecnico.dart';
import 'package:gerenciar/dominio/interfaces/tecnico_repositorio_interface.dart';

// Importe o arquivo gerado pelo mockito
import 'cadastrar_tecnico_test.mocks.dart';

// Anotação para gerar o mock
@GenerateMocks([TecnicoRepositorioInterface])
void main() {
  // 1. Preparação (Setup)
  late MockTecnicoRepositorioInterface mockRepositorio;
  late CadastrarTecnico casoDeUso;

  setUp(() {
    mockRepositorio = MockTecnicoRepositorioInterface();
    casoDeUso = CadastrarTecnico(mockRepositorio);
  });

  // Criação de um técnico de exemplo para os testes
  final tecnicoExemplo = Tecnico(
    id: '1',
    nome: 'Flávio Amorim',
    email: 'flavio@teste.com',
    telefone: '64999999999',
    ativo: true,
  );

  test('Deve chamar o método adicionar do repositório ao cadastrar um técnico',
      () async {
    // 2. Ação (Act)
    // Configura o mock para não fazer nada quando 'adicionar' for chamado.
    // Usamos `thenAnswer` para simular uma ação assíncrona bem-sucedida.
    when(mockRepositorio.adicionar(any)).thenAnswer((_) async => {});

    // Executa o caso de uso
    await casoDeUso.executar(tecnicoExemplo);

    // 3. Verificação (Assert)
    // Verifica se o método 'adicionar' do mock foi chamado exatamente uma vez
    // com o técnico que criamos.
    verify(mockRepositorio.adicionar(tecnicoExemplo));
    verifyNoMoreInteractions(
      mockRepositorio,
    ); // Garante que mais nada foi chamado
  });

  test('Deve lançar uma exceção se o nome do técnico estiver vazio', () async {
    // 2. Ação (Act) e 3. Verificação (Assert)
    final tecnicoInvalido = Tecnico(
      id: '2',
      nome: '', // Nome vazio
      email: 'email@valido.com',
      telefone: '12345',
      ativo: true,
    );

    // Verifica se a execução do caso de uso com dados inválidos
    // lança (throws) uma Exceção.//
    expect(
      () => casoDeUso.executar(tecnicoInvalido),
      throwsA(isA<Exception>()),
    );
  });
}
