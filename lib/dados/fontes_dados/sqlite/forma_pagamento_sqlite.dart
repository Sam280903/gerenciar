// lib/dados/fontes_dados/sqlite/forma_pagamento_sqlite.dart
import 'package:sqflite/sqflite.dart';
import 'package:gerenciar/dados/fontes_dados/sqlite/sqlite_conexao.dart';
import '../../modelos/forma_pagamento_model.dart';

class FormaPagamentoSQLite {
  Future<Database> get _db async => await SQLiteConexao.db;

  Future<void> adicionar(FormaPagamentoModel forma) async {
    final db = await _db;
    await db.insert('formas_pagamento', forma.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> atualizar(FormaPagamentoModel forma) async {
    final db = await _db;
    await db.update('formas_pagamento', forma.toMap(),
        where: 'id = ?', whereArgs: [forma.id]);
  }

  Future<void> inativar(String id) async {
    final db = await _db;
    await db.update('formas_pagamento', {'ativo': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> reativar(String id) async {
    final db = await _db;
    await db.update('formas_pagamento', {'ativo': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<FormaPagamentoModel?> buscarPorId(String id) async {
    final db = await _db;
    final resultado =
        await db.query('formas_pagamento', where: 'id = ?', whereArgs: [id]);
    if (resultado.isNotEmpty) {
      return FormaPagamentoModel.fromMap(
          resultado.first, resultado.first['id'] as String);
    }
    return null;
  }

  Future<FormaPagamentoModel?> buscarPorNome(String nome) async {
    final db = await _db;
    final resultado = await db.query('formas_pagamento',
        where: 'nome = ?', whereArgs: [nome], limit: 1);
    if (resultado.isNotEmpty) {
      return FormaPagamentoModel.fromMap(
          resultado.first, resultado.first['id'] as String);
    }
    return null;
  }

  Future<List<FormaPagamentoModel>> listarTodos(
      {bool incluirInativos = false}) async {
    final db = await _db;
    final resultado = await db.query(
      'formas_pagamento',
      where: incluirInativos ? null : 'ativo = ?',
      whereArgs: incluirInativos ? null : [1],
    );
    return resultado
        .map((row) => FormaPagamentoModel.fromMap(row, row['id'] as String))
        .toList();
  }
}
