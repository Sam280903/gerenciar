// lib/dados/fontes_dados/sqlite/tecnico_sqlite.dart

import 'package:gerenciar/dados/fontes_dados/sqlite/sqlite_conexao.dart';
import 'package:sqflite/sqflite.dart';
import '../../modelos/tecnico_model.dart';

class TecnicoSQLite {
  Future<Database> get _db async => await SQLiteConexao.db;

  Future<void> adicionarTecnico(TecnicoModel tecnico) async {
    final db = await _db;
    await db.insert('tecnicos', tecnico.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> atualizarTecnico(TecnicoModel tecnico) async {
    final db = await _db;
    await db.update('tecnicos', tecnico.toMap(),
        where: 'id = ?', whereArgs: [tecnico.id]);
  }

  Future<void> inativarTecnico(String id) async {
    final db = await _db;
    await db.update('tecnicos', {'ativo': 0}, where: 'id = ?', whereArgs: [id]);
  }

  // MÉTODO FALTANTE ADICIONADO
  Future<void> reativarTecnico(String id) async {
    final db = await _db;
    await db.update('tecnicos', {'ativo': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<TecnicoModel?> buscarPorId(String id) async {
    final db = await _db;
    final resultado =
        await db.query('tecnicos', where: 'id = ?', whereArgs: [id]);
    if (resultado.isNotEmpty) {
      return TecnicoModel.fromMap(
          resultado.first, resultado.first['id'] as String);
    }
    return null;
  }

  // MÉTODO ATUALIZADO
  Future<List<TecnicoModel>> listarTodos({bool incluirInativos = false}) async {
    final db = await _db;
    final resultado = await db.query(
      'tecnicos',
      // Se for para incluir inativos, a cláusula 'where' é nula e busca todos.
      where: incluirInativos ? null : 'ativo = ?',
      whereArgs: incluirInativos ? null : [1],
    );
    return resultado
        .map((linha) => TecnicoModel.fromMap(linha, linha['id'] as String))
        .toList();
  }
}
