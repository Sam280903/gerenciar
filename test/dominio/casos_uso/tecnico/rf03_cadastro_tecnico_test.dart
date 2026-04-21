// RF03 - Cadastro de Técnicos: validações obrigatórias de nome e e-mail
// RF08 - Inativação/Reativação de cadastros de Técnicos
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/cadastrar_tecnico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/atualizar_tecnico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/buscar_tecnico_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/inativar_tecnico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/listar_tecnicos.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/reativar_tecnico.dart';

import 'cadastrar_tecnico_test.mocks.dart';

void main() {
  late MockTecnicoRepositorioInterface mockRepositorio;
  late CadastrarTecnico cadastrar;
  late AtualizarTecnico atualizar;
  late BuscarTecnicoPorId buscarPorId;
  late InativarTecnico inativar;
  late ListarTecnicos listar;
  late ReativarTecnico reativar;

  final tecnicoValido = Tecnico(
    id: 'tec-1',
    nome: 'Carlos Silva',
    email: 'carlos@empresa.com',
    telefone: '64999990000',
    ativo: true,
    idGestor: 'gestor-1',
  );

  final tecnicoInativo = Tecnico(
    id: 'tec-5',
    nome: 'Ana Lima',
    email: 'ana@empresa.com',
    telefone: '64988880000',
    ativo: false,
    idGestor: 'gestor-1',
  );

  setUp(() {
    mockRepositorio = MockTecnicoRepositorioInterface();
    cadastrar = CadastrarTecnico(mockRepositorio);
    atualizar = AtualizarTecnico(mockRepositorio);
    buscarPorId = BuscarTecnicoPorId(mockRepositorio);
    inativar = InativarTecnico(mockRepositorio);
    listar = ListarTecnicos(mockRepositorio);
    reativar = ReativarTecnico(mockRepositorio);
  });

  group('RF03 - Cadastro de Técnicos', () {
    test('Deve cadastrar técnico com dados válidos', () async {
      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(tecnicoValido);

      verify(mockRepositorio.adicionar(tecnicoValido));
    });

    test('Deve chamar adicionar exatamente uma vez por cadastro', () async {
      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(tecnicoValido);

      verify(mockRepositorio.adicionar(any)).called(1);
    });

    test('Deve lançar exceção quando nome estiver vazio', () async {
      final tecnicoSemNome = Tecnico(
        id: 'tec-2',
        nome: '',
        email: 'valido@email.com',
        telefone: '64999990000',
        ativo: true,
        idGestor: 'gestor-1',
      );

      await expectLater(
        () => cadastrar.executar(tecnicoSemNome),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'mensagem',
          contains('obrigatórios'),
        )),
      );

      verifyNever(mockRepositorio.adicionar(any));
    });

    test('Deve lançar exceção quando e-mail estiver vazio', () async {
      final tecnicoSemEmail = Tecnico(
        id: 'tec-3',
        nome: 'João Técnico',
        email: '',
        telefone: '64999990000',
        ativo: true,
        idGestor: 'gestor-1',
      );

      await expectLater(
        () => cadastrar.executar(tecnicoSemEmail),
        throwsA(isA<Exception>()),
      );

      verifyNever(mockRepositorio.adicionar(any));
    });

    test('Deve lançar exceção quando nome e e-mail estiverem vazios', () async {
      final tecnicoInvalido = Tecnico(
        id: 'tec-4',
        nome: '',
        email: '',
        telefone: '64999990000',
        ativo: true,
        idGestor: 'gestor-1',
      );

      await expectLater(
        () => cadastrar.executar(tecnicoInvalido),
        throwsA(isA<Exception>()),
      );
    });

    test('Não deve chamar adicionar quando nome for inválido', () async {
      final tecnicoSemNome = Tecnico(
        id: 'tec-2',
        nome: '',
        email: 'valido@email.com',
        telefone: '64999990000',
        ativo: true,
        idGestor: 'gestor-1',
      );

      try {
        await cadastrar.executar(tecnicoSemNome);
      } catch (_) {}

      verifyNever(mockRepositorio.adicionar(any));
    });

    test('Deve cadastrar técnico com telefone diferente', () async {
      final tecnicoAlternativo = Tecnico(
        id: 'tec-6',
        nome: 'Pedro Técnico',
        email: 'pedro@empresa.com',
        telefone: '64911112222',
        ativo: true,
        idGestor: 'gestor-1',
      );

      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(tecnicoAlternativo);

      verify(mockRepositorio.adicionar(tecnicoAlternativo));
    });

    test('Deve atualizar técnico com dados válidos', () async {
      when(mockRepositorio.atualizar(any)).thenAnswer((_) => Future.value());

      await atualizar.executar(tecnicoValido);

      verify(mockRepositorio.atualizar(tecnicoValido));
    });

    test('Deve lançar exceção ao atualizar técnico sem ID', () async {
      final tecnicoSemId = Tecnico(
        id: '',
        nome: 'Sem ID',
        email: 'semid@email.com',
        telefone: '64900000000',
        ativo: true,
        idGestor: 'gestor-1',
      );

      await expectLater(
        () => atualizar.executar(tecnicoSemId),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'mensagem',
          contains('ID do técnico é obrigatório'),
        )),
      );

      verifyNever(mockRepositorio.atualizar(any));
    });

    test('Deve buscar técnico por id existente', () async {
      when(mockRepositorio.buscarPorId(any))
          .thenAnswer((_) => Future.value(tecnicoValido));

      final resultado = await buscarPorId.executar('tec-1');

      expect(resultado, equals(tecnicoValido));
      verify(mockRepositorio.buscarPorId('tec-1'));
    });

    test('Deve retornar null quando técnico não for encontrado', () async {
      when(mockRepositorio.buscarPorId(any))
          .thenAnswer((_) => Future.value(null));

      final resultado = await buscarPorId.executar('tec-inexistente');

      expect(resultado, isNull);
    });

    test('Deve lançar exceção ao buscar técnico com id vazio', () async {
      await expectLater(
        () => buscarPorId.executar(''),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'mensagem',
          contains('ID do técnico é obrigatório'),
        )),
      );
    });
  });

  group('RF08 - Inativação de Técnicos pelo Gestor', () {
    test('Deve inativar técnico pelo id', () async {
      when(mockRepositorio.inativar(any)).thenAnswer((_) => Future.value());

      await inativar.executar('tec-1');

      verify(mockRepositorio.inativar('tec-1'));
    });

    test('Deve reativar técnico previamente inativado', () async {
      when(mockRepositorio.reativar(any)).thenAnswer((_) => Future.value());

      await reativar.executar('tec-1');

      verify(mockRepositorio.reativar('tec-1'));
    });

    test('Deve chamar inativar exatamente uma vez', () async {
      when(mockRepositorio.inativar(any)).thenAnswer((_) => Future.value());

      await inativar.executar('tec-1');

      verify(mockRepositorio.inativar(any)).called(1);
    });

    test('Deve chamar reativar exatamente uma vez', () async {
      when(mockRepositorio.reativar(any)).thenAnswer((_) => Future.value());

      await reativar.executar('tec-1');

      verify(mockRepositorio.reativar(any)).called(1);
    });

    test('Deve listar somente técnicos ativos do gestor', () async {
      when(mockRepositorio.listarTodos(
              idGestor: anyNamed('idGestor'),
              incluirInativos: anyNamed('incluirInativos')))
          .thenAnswer((_) => Future.value([tecnicoValido]));

      final resultado = await listar.executar(idGestor: 'gestor-1');

      expect(resultado, equals([tecnicoValido]));
      verify(mockRepositorio.listarTodos(
          idGestor: 'gestor-1', incluirInativos: false));
    });

    test('Deve listar técnicos incluindo inativos quando solicitado', () async {
      when(mockRepositorio.listarTodos(
              idGestor: anyNamed('idGestor'),
              incluirInativos: anyNamed('incluirInativos')))
          .thenAnswer((_) => Future.value([tecnicoValido, tecnicoInativo]));

      final resultado =
          await listar.executar(idGestor: 'gestor-1', incluirInativos: true);

      expect(resultado.length, equals(2));
      verify(mockRepositorio.listarTodos(
          idGestor: 'gestor-1', incluirInativos: true));
    });

    test('Deve retornar lista vazia quando não há técnicos', () async {
      when(mockRepositorio.listarTodos(
              idGestor: anyNamed('idGestor'),
              incluirInativos: anyNamed('incluirInativos')))
          .thenAnswer((_) => Future.value([]));

      final resultado = await listar.executar(idGestor: 'gestor-sem-tecnicos');

      expect(resultado, isEmpty);
    });
  });
}
