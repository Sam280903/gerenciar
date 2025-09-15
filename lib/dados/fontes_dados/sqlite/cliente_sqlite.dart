// lib/dados/fontes_dados/sqlite/cliente_sqlite.dart
import 'package:sqflite/sqflite.dart';
import 'package:gerenciar/dados/fontes_dados/sqlite/sqlite_conexao.dart';
import '../../modelos/cliente_model.dart';

class ClienteSQLite {
  Future<Database> get _db async => await SQLiteConexao.db;

  Future<void> adicionarCliente(ClienteModel cliente) async {
    final db = await _db;
    await db.insert(
      'clientes',
      cliente.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> atualizarCliente(ClienteModel cliente) async {
    final db = await _db;
    await db.update(
      'clientes',
      cliente.toMap(),
      where: 'id = ?',
      whereArgs: [cliente.id],
    );
  }

  Future<void> inativarCliente(String id) async {
    final db = await _db;
    await db.update(
      'clientes',
      {'ativo': 0}, // 0 para false no SQLite
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // MÉTODO FALTANTE ADICIONADO
  Future<void> reativarCliente(String id) async {
    final db = await _db;
    await db.update(
      'clientes',
      {'ativo': 1}, // 1 para true no SQLite
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<ClienteModel?> buscarPorId(String id) async {
    final db = await _db;
    final resultado = await db.query(
      'clientes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (resultado.isNotEmpty) {
      return ClienteModel.fromMap(
          resultado.first, resultado.first['id'] as String);
    }
    return null;
  }

  // MÉTODO ATUALIZADO COM O PARÂMETRO
  Future<List<ClienteModel>> listarTodos({bool incluirInativos = false}) async {
    final db = await _db;
    final resultado = await db.query(
      'clientes',
      // Se for para incluir inativos, a cláusula 'where' é nula e busca todos.
      where: incluirInativos ? null : 'ativo = ?',
      whereArgs: incluirInativos ? null : [1],
    );

    return resultado
        .map((row) => ClienteModel.fromMap(row, row['id'] as String))
        .toList();
  }
}
