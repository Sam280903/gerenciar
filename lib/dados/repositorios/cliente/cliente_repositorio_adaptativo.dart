// lib/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/interfaces/cliente_repositorio_interface.dart';
import 'cliente_repositorio_impl.dart';
import 'cliente_repositorio_impl_sqlite.dart';

class ClienteRepositorioAdaptativo implements ClienteRepositorioInterface {
  final _repositorioOnline = ClienteRepositorioImpl();
  final _repositorioOffline = ClienteRepositorioImplSQLite();

  Future<bool> _temConexao() async {
    final status = await Connectivity().checkConnectivity();
    return !status.contains(ConnectivityResult.none);
  }

  Future<ClienteRepositorioInterface> _escolherRepositorio() async {
    return await _temConexao() ? _repositorioOnline : _repositorioOffline;
  }

  @override
  Future<void> adicionar(Cliente cliente) async {
    final repo = await _escolherRepositorio();
    await repo.adicionar(cliente);
  }

  @override
  Future<void> atualizar(Cliente cliente) async {
    final repo = await _escolherRepositorio();
    await repo.atualizar(cliente);
  }

  @override
  Future<void> inativar(String id) async {
    final repo = await _escolherRepositorio();
    await repo.inativar(id);
  }

  @override
  Future<void> reativar(String id) async {
    final repo = await _escolherRepositorio();
    await repo.reativar(id);
  }

  @override
  Future<Cliente?> buscarPorId(String id) async {
    final repo = await _escolherRepositorio();
    return await repo.buscarPorId(id);
  }

  @override
  Future<List<Cliente>> listarTodos({bool incluirInativos = false}) async {
    final repo = await _escolherRepositorio();
    return await repo.listarTodos(incluirInativos: incluirInativos);
  }
}
