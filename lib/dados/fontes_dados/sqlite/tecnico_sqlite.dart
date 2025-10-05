// lib/dados/fontes_dados/sqlite/tecnico_sqlite.dart
import 'package:gerenciar/dados/fontes_dados/sqlite/sqlite_conexao.dart';
import 'package:sqflite/sqflite.dart';
import '../../modelos/tecnico_model.dart';

class TecnicoSQLite {
  Future<Database> get _db async => await SQLiteConexao.db;

  Future<List<TecnicoModel>> listarNaoSincronizados() async {
    final db = await _db;
    final resultado = await db.query(
      'tecnicos',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    return resultado
        .map((linha) => TecnicoModel.fromMap(linha, linha['id'] as String))
        .toList();
  }

  Future<void> marcarComoSincronizado(String id) async {
    final db = await _db;
    await db.update(
      'tecnicos',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> adicionarTecnico(TecnicoModel tecnico) async {
    final db = await _db;
    await db.insert('tecnicos', tecnico.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> atualizarTecnico(TecnicoModel tecnico) async {
    final db = await _db;
    final dados = tecnico.toMap()..['sincronizado'] = 0;
    await db.update('tecnicos', dados,
        where: 'id = ?', whereArgs: [tecnico.id]);
  }

  Future<void> inativarTecnico(String id) async {
    final db = await _db;
    await db.update('tecnicos', {'ativo': 0, 'sincronizado': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> reativarTecnico(String id) async {
    final db = await _db;
    await db.update('tecnicos', {'ativo': 1, 'sincronizado': 0},
        where: 'id = ?', whereArgs: [id]);
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

  // MÉTODO ALTERADO
  Future<List<TecnicoModel>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    final db = await _db;
    String where = 'idGestor = ?';
    List<dynamic> whereArgs = [idGestor];

    if (!incluirInativos) {
      where += ' AND ativo = ?';
      whereArgs.add(1);
    }
    
    final resultado = await db.query(
      'tecnicos',
      where: where,
      whereArgs: whereArgs,
    );
    return resultado
        .map((linha) => TecnicoModel.fromMap(linha, linha['id'] as String))
        .toList();
  }
}