// Testes de fluxo — RF03 e RF08: ciclo de vida completo de um Técnico
// Sem mocks: usa repositório real em memória
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/cadastrar_tecnico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/atualizar_tecnico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/buscar_tecnico_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/inativar_tecnico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/listar_tecnicos.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/reativar_tecnico.dart';

import '../helpers/tecnico_repositorio_memoria.dart';

void main() {
  late TecnicoRepositorioMemoria repositorio;
  late CadastrarTecnico cadastrar;
  late AtualizarTecnico atualizar;
  late BuscarTecnicoPorId buscarPorId;
  late InativarTecnico inativar;
  late ListarTecnicos listar;
  late ReativarTecnico reativar;

  setUp(() {
    repositorio = TecnicoRepositorioMemoria();
    cadastrar = CadastrarTecnico(repositorio);
    atualizar = AtualizarTecnico(repositorio);
    buscarPorId = BuscarTecnicoPorId(repositorio);
    inativar = InativarTecnico(repositorio);
    listar = ListarTecnicos(repositorio);
    reativar = ReativarTecnico(repositorio);
  });

  group('Fluxo — Cadastro e listagem de técnicos', () {
    test('Cadastrar um técnico e encontrá-lo na listagem', () async {
      final tecnico = Tecnico(
        id: 'tec-1',
        nome: 'Carlos Silva',
        email: 'carlos@empresa.com',
        telefone: '64999990000',
        ativo: true,
        idGestor: 'gestor-1',
      );

      await cadastrar.executar(tecnico);
      final lista = await listar.executar(idGestor: 'gestor-1');

      expect(lista.length, equals(1));
      expect(lista.first.nome, equals('Carlos Silva'));
    });

    test('Cadastrar múltiplos técnicos e todos aparecem na listagem', () async {
      await cadastrar.executar(Tecnico(
          id: 'tec-1', nome: 'Carlos', email: 'c@e.com',
          telefone: '111', ativo: true, idGestor: 'gestor-1'));
      await cadastrar.executar(Tecnico(
          id: 'tec-2', nome: 'Ana', email: 'a@e.com',
          telefone: '222', ativo: true, idGestor: 'gestor-1'));
      await cadastrar.executar(Tecnico(
          id: 'tec-3', nome: 'Pedro', email: 'p@e.com',
          telefone: '333', ativo: true, idGestor: 'gestor-1'));

      final lista = await listar.executar(idGestor: 'gestor-1');

      expect(lista.length, equals(3));
    });

    test('Técnicos de gestores diferentes não se misturam na listagem',
        () async {
      await cadastrar.executar(Tecnico(
          id: 'tec-1', nome: 'Carlos', email: 'c@e.com',
          telefone: '111', ativo: true, idGestor: 'gestor-1'));
      await cadastrar.executar(Tecnico(
          id: 'tec-2', nome: 'Ana', email: 'a@e.com',
          telefone: '222', ativo: true, idGestor: 'gestor-2'));

      final listaGestor1 = await listar.executar(idGestor: 'gestor-1');
      final listaGestor2 = await listar.executar(idGestor: 'gestor-2');

      expect(listaGestor1.length, equals(1));
      expect(listaGestor2.length, equals(1));
      expect(listaGestor1.first.nome, equals('Carlos'));
      expect(listaGestor2.first.nome, equals('Ana'));
    });

    test('Não deve cadastrar técnico com nome vazio — dados não persistem',
        () async {
      final tecnicoInvalido = Tecnico(
          id: 'tec-x', nome: '', email: 'valido@e.com',
          telefone: '111', ativo: true, idGestor: 'gestor-1');

      await expectLater(
        () => cadastrar.executar(tecnicoInvalido),
        throwsA(isA<Exception>()),
      );

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista, isEmpty);
    });
  });

  group('Fluxo — Busca de técnico por ID', () {
    test('Cadastrar e buscar pelo ID retorna o técnico correto', () async {
      final tecnico = Tecnico(
          id: 'tec-1', nome: 'Carlos Silva', email: 'carlos@e.com',
          telefone: '111', ativo: true, idGestor: 'gestor-1');

      await cadastrar.executar(tecnico);
      final encontrado = await buscarPorId.executar('tec-1');

      expect(encontrado, isNotNull);
      expect(encontrado!.nome, equals('Carlos Silva'));
    });

    test('Buscar ID inexistente retorna null', () async {
      final resultado = await buscarPorId.executar('tec-inexistente');
      expect(resultado, isNull);
    });

    test('Buscar com ID vazio lança exceção', () async {
      await expectLater(
        () => buscarPorId.executar(''),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('Fluxo — Atualização de técnico', () {
    test('Cadastrar e atualizar nome do técnico', () async {
      final tecnico = Tecnico(
          id: 'tec-1', nome: 'Carlos Silva', email: 'carlos@e.com',
          telefone: '111', ativo: true, idGestor: 'gestor-1');

      await cadastrar.executar(tecnico);

      final tecnicoAtualizado = Tecnico(
          id: 'tec-1', nome: 'Carlos Souza', email: 'carlos@e.com',
          telefone: '111', ativo: true, idGestor: 'gestor-1');

      await atualizar.executar(tecnicoAtualizado);

      final encontrado = await buscarPorId.executar('tec-1');
      expect(encontrado!.nome, equals('Carlos Souza'));
    });

    test('Atualizar sem ID lança exceção e dados originais permanecem',
        () async {
      final tecnico = Tecnico(
          id: 'tec-1', nome: 'Carlos Silva', email: 'carlos@e.com',
          telefone: '111', ativo: true, idGestor: 'gestor-1');
      await cadastrar.executar(tecnico);

      final semId = Tecnico(
          id: '', nome: 'Novo Nome', email: 'novo@e.com',
          telefone: '999', ativo: true, idGestor: 'gestor-1');

      await expectLater(
        () => atualizar.executar(semId),
        throwsA(isA<Exception>()),
      );

      final original = await buscarPorId.executar('tec-1');
      expect(original!.nome, equals('Carlos Silva'));
    });
  });

  group('Fluxo — Inativação e reativação de técnico (RF08)', () {
    test('Cadastrar → inativar → não aparece na listagem padrão', () async {
      await cadastrar.executar(Tecnico(
          id: 'tec-1', nome: 'Carlos', email: 'c@e.com',
          telefone: '111', ativo: true, idGestor: 'gestor-1'));

      await inativar.executar('tec-1');

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista, isEmpty);
    });

    test('Inativar → aparece ao incluir inativos', () async {
      await cadastrar.executar(Tecnico(
          id: 'tec-1', nome: 'Carlos', email: 'c@e.com',
          telefone: '111', ativo: true, idGestor: 'gestor-1'));

      await inativar.executar('tec-1');

      final lista =
          await listar.executar(idGestor: 'gestor-1', incluirInativos: true);
      expect(lista.length, equals(1));
      expect(lista.first.ativo, isFalse);
    });

    test('Inativar → reativar → volta a aparecer na listagem padrão', () async {
      await cadastrar.executar(Tecnico(
          id: 'tec-1', nome: 'Carlos', email: 'c@e.com',
          telefone: '111', ativo: true, idGestor: 'gestor-1'));

      await inativar.executar('tec-1');
      await reativar.executar('tec-1');

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista.length, equals(1));
      expect(lista.first.ativo, isTrue);
    });

    test('Inativar um técnico não afeta os outros', () async {
      await cadastrar.executar(Tecnico(
          id: 'tec-1', nome: 'Carlos', email: 'c@e.com',
          telefone: '111', ativo: true, idGestor: 'gestor-1'));
      await cadastrar.executar(Tecnico(
          id: 'tec-2', nome: 'Ana', email: 'a@e.com',
          telefone: '222', ativo: true, idGestor: 'gestor-1'));

      await inativar.executar('tec-1');

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista.length, equals(1));
      expect(lista.first.nome, equals('Ana'));
    });
  });
}
