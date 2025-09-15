// lib/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gerenciar/dominio/interfaces/tecnico_repositorio_interface.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'tecnico_repositorio_impl.dart';
import 'tecnico_repositorio_impl_sqlite.dart';

class TecnicoRepositorioAdaptativo implements TecnicoRepositorioInterface {
  final _repositorioFirebase = TecnicoRepositorioImpl();
  final _repositorioSQLite = TecnicoRepositorioImplSQLite();

  Future<bool> _temConexao() async {
    final resultado = await Connectivity().checkConnectivity();
    return !resultado.contains(ConnectivityResult.none);
  }

  Future<TecnicoRepositorioInterface> _repositorio() async {
    return await _temConexao() ? _repositorioFirebase : _repositorioSQLite;
  }

  @override
  Future<void> adicionar(Tecnico tecnico) async {
    final repo = await _repositorio();
    await repo.adicionar(tecnico);
  }

  @override
  Future<void> atualizar(Tecnico tecnico) async {
    final repo = await _repositorio();
    await repo.atualizar(tecnico);
  }

  @override
  Future<void> inativar(String id) async {
    final repo = await _repositorio();
    await repo.inativar(id);
  }

  @override
  Future<void> reativar(String id) async {
    final repo = await _repositorio();
    await repo.reativar(id);
  }

  @override
  Future<Tecnico?> buscarPorId(String id) async {
    final repo = await _repositorio();
    return await repo.buscarPorId(id);
  }

  @override
  Future<List<Tecnico>> listarTodos({bool incluirInativos = false}) async {
    final repo = await _repositorio();
    return await repo.listarTodos(incluirInativos: incluirInativos);
  }
}
