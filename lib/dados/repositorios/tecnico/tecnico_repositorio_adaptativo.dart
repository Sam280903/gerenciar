// lib/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gerenciar/dados/fontes_dados/sqlite/tecnico_sqlite.dart';
import 'package:gerenciar/dados/modelos/tecnico_model.dart';
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
    if (await _temConexao()) {
      // Online: salva no Firebase e espelha no SQLite
      await _repositorioFirebase.adicionar(tecnico);
      final model = TecnicoModel.fromEntidade(tecnico);
      final sqlite = TecnicoSQLite();
      await sqlite.adicionarTecnico(model);
      await sqlite.marcarComoSincronizado(tecnico.id);
    } else {
      // Offline: salva só no SQLite (será sincronizado depois)
      await _repositorioSQLite.adicionar(tecnico);
    }
  }

  @override
  Future<void> atualizar(Tecnico tecnico) async {
    if (await _temConexao()) {
      await _repositorioFirebase.atualizar(tecnico);
      final model = TecnicoModel.fromEntidade(tecnico);
      final sqlite = TecnicoSQLite();
      await sqlite.atualizarTecnico(model);
      await sqlite.marcarComoSincronizado(tecnico.id);
    } else {
      await _repositorioSQLite.atualizar(tecnico);
    }
  }

  @override
  Future<void> inativar(String id) async {
    if (await _temConexao()) {
      await _repositorioFirebase.inativar(id);
      final sqlite = TecnicoSQLite();
      await sqlite.inativarTecnico(id);
      await sqlite.marcarComoSincronizado(id);
    } else {
      await _repositorioSQLite.inativar(id);
    }
  }

  @override
  Future<void> reativar(String id) async {
    if (await _temConexao()) {
      await _repositorioFirebase.reativar(id);
      final sqlite = TecnicoSQLite();
      await sqlite.reativarTecnico(id);
      await sqlite.marcarComoSincronizado(id);
    } else {
      await _repositorioSQLite.reativar(id);
    }
  }

  @override
  Future<Tecnico?> buscarPorId(String id) async {
    final repo = await _repositorio();
    return await repo.buscarPorId(id);
  }

  // MÉTODO ALTERADO
  @override
  Future<List<Tecnico>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    final repo = await _repositorio();
    return await repo.listarTodos(
        idGestor: idGestor, incluirInativos: incluirInativos);
  }
}