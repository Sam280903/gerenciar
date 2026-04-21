// RF05 - Cadastro de Clientes e RF08 - Inativação de cadastros
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/cadastrar_cliente.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/atualizar_cliente.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/buscar_cliente_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/inativar_cliente.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/listar_clientes.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/reativar_cliente.dart';

import 'cadastrar_cliente_test.mocks.dart';

void main() {
  late MockClienteRepositorioInterface mockRepositorio;
  late CadastrarCliente cadastrar;
  late AtualizarCliente atualizar;
  late BuscarClientePorId buscarPorId;
  late InativarCliente inativar;
  late ListarClientes listar;
  late ReativarCliente reativar;

  final clienteCompleto = Cliente(
    id: 'cli-1',
    nome: 'Maria Souza',
    email: 'maria@email.com',
    telefone: '64988880000',
    endereco: 'Rua das Flores, 100',
    cpf: '123.456.789-00',
    ativo: true,
    idGestor: 'gestor-1',
  );

  final clienteMinimo = Cliente(
    id: 'cli-2',
    nome: 'João Rápido',
    email: '',
    telefone: '64977770000',
    endereco: '',
    ativo: true,
    idGestor: 'gestor-1',
  );

  final clienteInativo = Cliente(
    id: 'cli-3',
    nome: 'Pedro Inativo',
    email: 'pedro@email.com',
    telefone: '64966660000',
    endereco: 'Rua B, 50',
    ativo: false,
    idGestor: 'gestor-1',
  );

  setUp(() {
    mockRepositorio = MockClienteRepositorioInterface();
    cadastrar = CadastrarCliente(mockRepositorio);
    atualizar = AtualizarCliente(mockRepositorio);
    buscarPorId = BuscarClientePorId(mockRepositorio);
    inativar = InativarCliente(mockRepositorio);
    listar = ListarClientes(mockRepositorio);
    reativar = ReativarCliente(mockRepositorio);
  });

  group('RF05 - Cadastro de Clientes', () {
    test('Deve cadastrar cliente com dados completos', () async {
      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(clienteCompleto);

      verify(mockRepositorio.adicionar(clienteCompleto));
    });

    test('RF12 - Deve permitir cadastro rápido (apenas nome e telefone)',
        () async {
      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(clienteMinimo);

      verify(mockRepositorio.adicionar(clienteMinimo));
    });

    test('Deve chamar adicionar exatamente uma vez por cadastro', () async {
      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(clienteCompleto);

      verify(mockRepositorio.adicionar(any)).called(1);
    });

    test('Deve cadastrar cliente com CPF opcional ausente', () async {
      final clienteSemCpf = Cliente(
        id: 'cli-4',
        nome: 'Lucas Sem CPF',
        email: 'lucas@email.com',
        telefone: '64955554444',
        endereco: 'Av. Principal, 200',
        ativo: true,
        idGestor: 'gestor-1',
      );

      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(clienteSemCpf);

      verify(mockRepositorio.adicionar(clienteSemCpf));
    });

    test('Deve cadastrar clientes de gestores diferentes independentemente',
        () async {
      final clienteGestor2 = Cliente(
        id: 'cli-5',
        nome: 'Fernanda Cliente',
        email: 'fernanda@email.com',
        telefone: '64944443333',
        endereco: 'Rua C, 10',
        ativo: true,
        idGestor: 'gestor-2',
      );

      when(mockRepositorio.adicionar(any)).thenAnswer((_) => Future.value());

      await cadastrar.executar(clienteGestor2);

      verify(mockRepositorio.adicionar(clienteGestor2));
    });

    test('Deve atualizar cliente com novos dados', () async {
      when(mockRepositorio.atualizar(any)).thenAnswer((_) => Future.value());

      await atualizar.executar(clienteCompleto);

      verify(mockRepositorio.atualizar(clienteCompleto));
    });

    test('Deve chamar atualizar exatamente uma vez', () async {
      when(mockRepositorio.atualizar(any)).thenAnswer((_) => Future.value());

      await atualizar.executar(clienteCompleto);

      verify(mockRepositorio.atualizar(any)).called(1);
    });

    test('Deve listar clientes ativos do gestor', () async {
      when(mockRepositorio.listarTodos(
              idGestor: anyNamed('idGestor'),
              incluirInativos: anyNamed('incluirInativos')))
          .thenAnswer((_) => Future.value([clienteCompleto, clienteMinimo]));

      final resultado = await listar.executar(idGestor: 'gestor-1');

      expect(resultado.length, equals(2));
      verify(mockRepositorio.listarTodos(
          idGestor: 'gestor-1', incluirInativos: false));
    });

    test('Deve retornar lista vazia quando não há clientes', () async {
      when(mockRepositorio.listarTodos(
              idGestor: anyNamed('idGestor'),
              incluirInativos: anyNamed('incluirInativos')))
          .thenAnswer((_) => Future.value([]));

      final resultado = await listar.executar(idGestor: 'gestor-sem-clientes');

      expect(resultado, isEmpty);
    });

    test('Deve listar clientes incluindo inativos quando solicitado', () async {
      when(mockRepositorio.listarTodos(
              idGestor: anyNamed('idGestor'),
              incluirInativos: anyNamed('incluirInativos')))
          .thenAnswer((_) =>
              Future.value([clienteCompleto, clienteMinimo, clienteInativo]));

      final resultado =
          await listar.executar(idGestor: 'gestor-1', incluirInativos: true);

      expect(resultado.length, equals(3));
      verify(mockRepositorio.listarTodos(
          idGestor: 'gestor-1', incluirInativos: true));
    });
  });

  group('RF08 - Inativação de Clientes pelo Gestor', () {
    test('Deve inativar cliente pelo id', () async {
      when(mockRepositorio.inativar(any)).thenAnswer((_) => Future.value());

      await inativar.executar('cli-1');

      verify(mockRepositorio.inativar('cli-1'));
    });

    test('Deve reativar cliente previamente inativado', () async {
      when(mockRepositorio.reativar(any)).thenAnswer((_) => Future.value());

      await reativar.executar('cli-1');

      verify(mockRepositorio.reativar('cli-1'));
    });

    test('Deve buscar cliente por id corretamente', () async {
      when(mockRepositorio.buscarPorId(any))
          .thenAnswer((_) => Future.value(clienteCompleto));

      final resultado = await buscarPorId.executar('cli-1');

      expect(resultado, equals(clienteCompleto));
      verify(mockRepositorio.buscarPorId('cli-1'));
    });

    test('Deve retornar null quando cliente não for encontrado', () async {
      when(mockRepositorio.buscarPorId(any))
          .thenAnswer((_) => Future.value(null));

      final resultado = await buscarPorId.executar('id-inexistente');

      expect(resultado, isNull);
    });

    test('Deve chamar inativar exatamente uma vez', () async {
      when(mockRepositorio.inativar(any)).thenAnswer((_) => Future.value());

      await inativar.executar('cli-1');

      verify(mockRepositorio.inativar(any)).called(1);
    });

    test('Deve chamar reativar exatamente uma vez', () async {
      when(mockRepositorio.reativar(any)).thenAnswer((_) => Future.value());

      await reativar.executar('cli-1');

      verify(mockRepositorio.reativar(any)).called(1);
    });

    test('Não deve reativar sem antes ter sido inativado (sequência correta)',
        () async {
      when(mockRepositorio.inativar(any)).thenAnswer((_) => Future.value());
      when(mockRepositorio.reativar(any)).thenAnswer((_) => Future.value());

      await inativar.executar('cli-3');
      await reativar.executar('cli-3');

      verifyInOrder([
        mockRepositorio.inativar('cli-3'),
        mockRepositorio.reativar('cli-3'),
      ]);
    });
  });
}
