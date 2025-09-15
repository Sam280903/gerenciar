// lib/dados/fontes_dados/sqlite/agendamento_sqlite.dart

import 'package:sqflite/sqflite.dart';
import 'package:gerenciar/dados/fontes_dados/sqlite/sqlite_conexao.dart';
import '../../modelos/agendamento_model.dart';

class AgendamentoSQLite {
  Future<Database> get _db async => await SQLiteConexao.db;

  // Novo método para fazer a consulta no SQLite
  Future<bool> verificarConflito(String idTecnico, DateTime dataHora) async {
    final db = await _db;
    final resultado = await db.query(
      'agendamentos',
      where: 'idTecnico = ? AND dataHora = ? AND ativo = ?',
      whereArgs: [idTecnico, dataHora.toIso8601String(), 1],
      limit: 1,
    );
    // Se a consulta retornar alguma linha, o horário está ocupado.
    return resultado.isNotEmpty;
  }

  Future<void> adicionar(AgendamentoModel agendamento) async {
    final db = await _db;
    await db.insert(
      'agendamentos',
      agendamento.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> atualizar(AgendamentoModel agendamento) async {
    final db = await _db;
    await db.update(
      'agendamentos',
      agendamento.toMap(),
      where: 'id = ?',
      whereArgs: [agendamento.id],
    );
  }

  Future<void> inativar(String id) async {
    final db = await _db;
    await db.update(
      'agendamentos',
      {'ativo': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
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

  Future<List<AgendamentoModel>> listarTodos() async {
    final db = await _db;
    final resultado = await db.query(
      'agendamentos',
      where: 'ativo = ?',
      whereArgs: [1],
    );
    return resultado.map((linha) {
      return AgendamentoModel.fromMap(
        linha,
        linha['id'] as String,
      );
    }).toList();
  }
}
