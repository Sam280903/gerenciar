// Testes de fluxo — RF05 e RF08: ciclo de vida completo de um Cliente
// Sem mocks: usa repositório real em memória
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/cadastrar_cliente.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/atualizar_cliente.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/buscar_cliente_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/inativar_cliente.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/listar_clientes.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/reativar_cliente.dart';

import '../helpers/cliente_repositorio_memoria.dart';

void main() {
  late ClienteRepositorioMemoria repositorio;
  late CadastrarCliente cadastrar;
  late AtualizarCliente atualizar;
  late BuscarClientePorId buscarPorId;
  late InativarCliente inativar;
  late ListarClientes listar;
  late ReativarCliente reativar;

  Cliente novoCliente({
    required String id,
    String nome = 'Maria Souza',
    String telefone = '64988880000',
    String email = '',
    String endereco = '',
    String? cpf,
    String idGestor = 'gestor-1',
  }) =>
      Cliente(
        id: id,
        nome: nome,
        email: email,
        telefone: telefone,
        endereco: endereco,
        cpf: cpf,
        ativo: true,
        idGestor: idGestor,
      );

  setUp(() {
    repositorio = ClienteRepositorioMemoria();
    cadastrar = CadastrarCliente(repositorio);
    atualizar = AtualizarCliente(repositorio);
    buscarPorId = BuscarClientePorId(repositorio);
    inativar = InativarCliente(repositorio);
    listar = ListarClientes(repositorio);
    reativar = ReativarCliente(repositorio);
  });

  group('Fluxo — Cadastro e listagem de clientes (RF05)', () {
    test('Cadastrar cliente completo e encontrá-lo na listagem', () async {
      final cliente = novoCliente(
        id: 'cli-1',
        nome: 'Maria Souza',
        email: 'maria@email.com',
        endereco: 'Rua das Flores, 100',
        cpf: '123.456.789-00',
      );

      await cadastrar.executar(cliente);
      final lista = await listar.executar(idGestor: 'gestor-1');

      expect(lista.length, equals(1));
      expect(lista.first.nome, equals('Maria Souza'));
      expect(lista.first.cpf, equals('123.456.789-00'));
    });

    test('Cadastrar cliente mínimo (apenas nome e telefone) é permitido',
        () async {
      final cliente = novoCliente(id: 'cli-1', nome: 'João Rápido');

      await cadastrar.executar(cliente);
      final lista = await listar.executar(idGestor: 'gestor-1');

      expect(lista.length, equals(1));
      expect(lista.first.email, isEmpty);
      expect(lista.first.endereco, isEmpty);
    });

    test('Cadastrar múltiplos clientes e todos aparecem na listagem', () async {
      await cadastrar.executar(novoCliente(id: 'cli-1', nome: 'Maria'));
      await cadastrar.executar(novoCliente(id: 'cli-2', nome: 'João'));
      await cadastrar.executar(novoCliente(id: 'cli-3', nome: 'Pedro'));

      final lista = await listar.executar(idGestor: 'gestor-1');

      expect(lista.length, equals(3));
    });

    test('Clientes de gestores diferentes não se misturam na listagem',
        () async {
      await cadastrar.executar(novoCliente(id: 'cli-1', nome: 'Maria', idGestor: 'gestor-1'));
      await cadastrar.executar(novoCliente(id: 'cli-2', nome: 'João', idGestor: 'gestor-2'));

      final listaG1 = await listar.executar(idGestor: 'gestor-1');
      final listaG2 = await listar.executar(idGestor: 'gestor-2');

      expect(listaG1.length, equals(1));
      expect(listaG2.length, equals(1));
      expect(listaG1.first.nome, equals('Maria'));
      expect(listaG2.first.nome, equals('João'));
    });

    test('Listagem vazia quando gestor não tem clientes', () async {
      await cadastrar.executar(novoCliente(id: 'cli-1', idGestor: 'gestor-1'));

      final lista = await listar.executar(idGestor: 'gestor-99');

      expect(lista, isEmpty);
    });
  });

  group('Fluxo — Busca de cliente por ID (RF05)', () {
    test('Cadastrar e buscar pelo ID retorna o cliente correto', () async {
      await cadastrar.executar(novoCliente(id: 'cli-1', nome: 'Maria Souza'));

      final encontrado = await buscarPorId.executar('cli-1');

      expect(encontrado, isNotNull);
      expect(encontrado!.nome, equals('Maria Souza'));
    });

    test('Buscar ID inexistente retorna null', () async {
      final resultado = await buscarPorId.executar('cli-inexistente');

      expect(resultado, isNull);
    });

    test('Buscar cliente correto entre vários cadastrados', () async {
      await cadastrar.executar(novoCliente(id: 'cli-1', nome: 'Maria'));
      await cadastrar.executar(novoCliente(id: 'cli-2', nome: 'João'));
      await cadastrar.executar(novoCliente(id: 'cli-3', nome: 'Pedro'));

      final encontrado = await buscarPorId.executar('cli-2');

      expect(encontrado!.nome, equals('João'));
    });
  });

  group('Fluxo — Atualização de cliente (RF05)', () {
    test('Atualizar endereço do cliente e verificar persistência', () async {
      await cadastrar.executar(novoCliente(id: 'cli-1', endereco: 'Rua A, 10'));

      final atualizado = novoCliente(id: 'cli-1', endereco: 'Rua B, 99');
      await atualizar.executar(atualizado);

      final encontrado = await buscarPorId.executar('cli-1');
      expect(encontrado!.endereco, equals('Rua B, 99'));
    });

    test('Atualizar e-mail do cliente', () async {
      await cadastrar.executar(novoCliente(id: 'cli-1', email: 'antigo@email.com'));

      final atualizado = novoCliente(id: 'cli-1', email: 'novo@email.com');
      await atualizar.executar(atualizado);

      final encontrado = await buscarPorId.executar('cli-1');
      expect(encontrado!.email, equals('novo@email.com'));
    });

    test('Atualização não afeta outros clientes', () async {
      await cadastrar.executar(novoCliente(id: 'cli-1', nome: 'Maria'));
      await cadastrar.executar(novoCliente(id: 'cli-2', nome: 'João'));

      await atualizar.executar(novoCliente(id: 'cli-1', nome: 'Maria Atualizada'));

      final cli2 = await buscarPorId.executar('cli-2');
      expect(cli2!.nome, equals('João'));
    });
  });

  group('Fluxo — Inativação e reativação de cliente (RF08)', () {
    test('Cadastrar → inativar → não aparece na listagem padrão', () async {
      await cadastrar.executar(novoCliente(id: 'cli-1'));

      await inativar.executar('cli-1');

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista, isEmpty);
    });

    test('Cliente inativado aparece ao incluir inativos', () async {
      await cadastrar.executar(novoCliente(id: 'cli-1', nome: 'Maria'));

      await inativar.executar('cli-1');

      final lista = await listar.executar(
          idGestor: 'gestor-1', incluirInativos: true);
      expect(lista.length, equals(1));
      expect(lista.first.ativo, isFalse);
    });

    test('Inativar → reativar → volta à listagem ativo', () async {
      await cadastrar.executar(novoCliente(id: 'cli-1'));

      await inativar.executar('cli-1');
      await reativar.executar('cli-1');

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista.length, equals(1));
      expect(lista.first.ativo, isTrue);
    });

    test('Inativar um cliente não afeta os demais', () async {
      await cadastrar.executar(novoCliente(id: 'cli-1', nome: 'Maria'));
      await cadastrar.executar(novoCliente(id: 'cli-2', nome: 'João'));
      await cadastrar.executar(novoCliente(id: 'cli-3', nome: 'Pedro'));

      await inativar.executar('cli-2');

      final lista = await listar.executar(idGestor: 'gestor-1');
      expect(lista.length, equals(2));
      expect(lista.any((c) => c.nome == 'João'), isFalse);
    });

    test('Reativar restaura todos os dados originais', () async {
      final original = novoCliente(
        id: 'cli-1',
        nome: 'Maria Souza',
        email: 'maria@email.com',
        cpf: '123.456.789-00',
      );

      await cadastrar.executar(original);
      await inativar.executar('cli-1');
      await reativar.executar('cli-1');

      final reativado = await buscarPorId.executar('cli-1');
      expect(reativado!.nome, equals('Maria Souza'));
      expect(reativado.email, equals('maria@email.com'));
      expect(reativado.cpf, equals('123.456.789-00'));
      expect(reativado.ativo, isTrue);
    });

    test('Listar incluindo inativos traz todos os clientes', () async {
      await cadastrar.executar(novoCliente(id: 'cli-1', nome: 'Ativo 1'));
      await cadastrar.executar(novoCliente(id: 'cli-2', nome: 'Ativo 2'));
      await cadastrar.executar(novoCliente(id: 'cli-3', nome: 'Vai inativar'));

      await inativar.executar('cli-3');

      final comInativos =
          await listar.executar(idGestor: 'gestor-1', incluirInativos: true);
      final semInativos = await listar.executar(idGestor: 'gestor-1');

      expect(comInativos.length, equals(3));
      expect(semInativos.length, equals(2));
    });
  });
}
