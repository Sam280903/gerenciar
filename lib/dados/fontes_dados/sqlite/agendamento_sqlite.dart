// lib/dados/fontes_dados/sqlite/agendamento_sqlite.dart
import 'package:sqflite/sqflite.dart';
import 'package:gerenciar/dados/fontes_dados/sqlite/sqlite_conexao.dart';
import '../../modelos/agendamento_model.dart';

class AgendamentoSQLite {
  Future<Database> get _db async => await SQLiteConexao.db;

  Future<List<AgendamentoModel>> listarNaoSincronizados() async {
    final db = await _db;
    final resultado = await db.query(
      'agendamentos',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    return resultado
        .map((linha) => AgendamentoModel.fromMap(linha, linha['id'] as String))
        .toList();
  }

  Future<void> marcarComoSincronizado(String id) async {
    final db = await _db;
    await db.update(
      'agendamentos',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<bool> verificarConflito(String idTecnico, DateTime dataHora) async {
    final db = await _db;
    final resultado = await db.query(
      'agendamentos',
      where: 'idTecnico = ? AND dataHora = ? AND ativo = ?',
      whereArgs: [idTecnico, dataHora.toIso8601String(), 1],
      limit: 1,
    );
    return resultado.isNotEmpty;
  }

  Future<void> adicionar(AgendamentoModel agendamento) async {
    final db = await _db;
    await db.insert(
      'agendamentos',
      agendamento.toMapForDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> atualizar(AgendamentoModel agendamento) async {
    final db = await _db;
    final dados = agendamento.toMapForDb()..['sincronizado'] = 0;
    await db.update(
      'agendamentos',
      dados,
      where: 'id = ?',
      whereArgs: [agendamento.id],
    );
  }

  Future<void> inativar(String id) async {
    final db = await _db;
    await db.update(
      'agendamentos',
      {'ativo': 0, 'sincronizado': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> reativar(String id) async {
    final db = await _db;
    await db.update('agendamentos', {'ativo': 1, 'sincronizado': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<AgendamentoModel?> buscarPorId(String id) async {
    final db = await _db;
    final resultado = await db.query(
      'agendamentos',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (resultado.isNotEmpty) {
      return AgendamentoModel.fromMap(
        resultado.first,
        resultado.first['id'] as String,
      );
    }
    return null;
  }

  // MÉTODO ALTERADO
  Future<List<AgendamentoModel>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    final db = await _db;
    String where = 'idGestor = ?';
    List<dynamic> whereArgs = [idGestor];

    if (!incluirInativos) {
      where += ' AND ativo = ?';
      whereArgs.add(1);
    }

    final resultado = await db.query(
      'agendamentos',
      where: where,
      whereArgs: whereArgs,
    );
    return resultado.map((linha) {
      return AgendamentoModel.fromMap(
        linha,
        linha['id'] as String,
      );
    }).toList();
  }
}