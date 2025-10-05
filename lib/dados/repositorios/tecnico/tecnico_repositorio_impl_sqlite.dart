// lib/dados/repositorios/tecnico/tecnico_repositorio_impl_sqlite.dart

import 'package:gerenciar/dominio/interfaces/tecnico_repositorio_interface.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import '../../modelos/tecnico_model.dart';
import '../../fontes_dados/sqlite/tecnico_sqlite.dart';

class TecnicoRepositorioImplSQLite implements TecnicoRepositorioInterface {
  final TecnicoSQLite _fonteSQLite = TecnicoSQLite();

  @override
  Future<void> adicionar(Tecnico tecnico) async {
    final model = TecnicoModel.fromEntidade(tecnico);
    await _fonteSQLite.adicionarTecnico(model);
  }

  @override
  Future<void> atualizar(Tecnico tecnico) async {
    final model = TecnicoModel.fromEntidade(tecnico);
    await _fonteSQLite.atualizarTecnico(model);
  }

  @override
  Future<void> inativar(String id) async {
    await _fonteSQLite.inativarTecnico(id);
  }

  @override
  Future<void> reativar(String id) async {
    await _fonteSQLite.reativarTecnico(id);
  }

  @override
  Future<Tecnico?> buscarPorId(String id) async {
    final model = await _fonteSQLite.buscarPorId(id);
    return model?.toEntidade();
  }

  // MÉTODO ALTERADO
  @override
  Future<List<Tecnico>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    final modelos = await _fonteSQLite.listarTodos(
        idGestor: idGestor, incluirInativos: incluirInativos);
    return modelos.map((m) => m.toEntidade()).toList();
  }
}