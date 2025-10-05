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

  // AQUI ESTÁ A CORREÇÃO
  final tecnicoExemplo = Tecnico(
    id: '1',
    nome: 'Flávio Amorim',
    email: 'flavio@teste.com',
    telefone: '64999999999',
    ativo: true,
    idGestor: 'gestor-1', // ADICIONADO
  );

  test('Deve chamar o método adicionar do repositório ao cadastrar um técnico',
      () async {
    // 2. Ação (Act)
    when(mockRepositorio.adicionar(any)).thenAnswer((_) async => {});

    await casoDeUso.executar(tecnicoExemplo);

    // 3. Verificação (Assert)
    verify(mockRepositorio.adicionar(tecnicoExemplo));
    verifyNoMoreInteractions(
      mockRepositorio,
    );
  });

  test('Deve lançar uma exceção se o nome do técnico estiver vazio', () async {
    // 2. Ação (Act) e 3. Verificação (Assert)
    final tecnicoInvalido = Tecnico(
      id: '2',
      nome: '', // Nome vazio
      email: 'email@valido.com',
      telefone: '12345',
      ativo: true,
      idGestor: 'gestor-1', // ADICIONADO
    );

    expect(
      () => casoDeUso.executar(tecnicoInvalido),
      throwsA(isA<Exception>()),
    );
  });
}
