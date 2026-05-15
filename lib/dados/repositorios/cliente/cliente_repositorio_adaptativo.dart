// lib/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gerenciar/dados/fontes_dados/sqlite/cliente_sqlite.dart';
import 'package:gerenciar/dados/modelos/cliente_model.dart';
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
    if (await _temConexao()) {
      // Online: salva no Firebase e espelha no SQLite
      await _repositorioOnline.adicionar(cliente);
      final model = ClienteModel.fromEntidade(cliente);
      final sqlite = ClienteSQLite();
      await sqlite.adicionarCliente(model);
      await sqlite.marcarComoSincronizado(cliente.id);
    } else {
      // Offline: salva só no SQLite (será sincronizado depois)
      await _repositorioOffline.adicionar(cliente);
    }
  }

  @override
  Future<void> atualizar(Cliente cliente) async {
    if (await _temConexao()) {
      await _repositorioOnline.atualizar(cliente);
      final model = ClienteModel.fromEntidade(cliente);
      final sqlite = ClienteSQLite();
      await sqlite.atualizarCliente(model);
      await sqlite.marcarComoSincronizado(cliente.id);
    } else {
      await _repositorioOffline.atualizar(cliente);
    }
  }

  @override
  Future<void> inativar(String id) async {
    if (await _temConexao()) {
      await _repositorioOnline.inativar(id);
      final sqlite = ClienteSQLite();
      await sqlite.inativarCliente(id);
      await sqlite.marcarComoSincronizado(id);
    } else {
      await _repositorioOffline.inativar(id);
    }
  }

  @override
  Future<void> reativar(String id) async {
    if (await _temConexao()) {
      await _repositorioOnline.reativar(id);
      final sqlite = ClienteSQLite();
      await sqlite.reativarCliente(id);
      await sqlite.marcarComoSincronizado(id);
    } else {
      await _repositorioOffline.reativar(id);
    }
  }

  @override
  Future<Cliente?> buscarPorId(String id) async {
    final repo = await _escolherRepositorio();
    return await repo.buscarPorId(id);
  }

  // MÉTODO ALTERADO
  @override
  Future<List<Cliente>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    final repo = await _escolherRepositorio();
    return await repo.listarTodos(
        idGestor: idGestor, incluirInativos: incluirInativos);
  }
}