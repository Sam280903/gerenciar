// lib/dados/fontes_dados/sqlite/cliente_sqlite.dart
import 'package:sqflite/sqflite.dart';
import 'package:gerenciar/dados/fontes_dados/sqlite/sqlite_conexao.dart';
import '../../modelos/cliente_model.dart';

class ClienteSQLite {
  Future<Database> get _db async => await SQLiteConexao.db;

  Future<List<ClienteModel>> listarNaoSincronizados() async {
    final db = await _db;
    final resultado = await db.query(
      'clientes',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    return resultado
        .map((row) => ClienteModel.fromMap(row, row['id'] as String))
        .toList();
  }

  Future<void> marcarComoSincronizado(String id) async {
    final db = await _db;
    await db.update(
      'clientes',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

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
      {'ativo': 0, 'sincronizado': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<void> reativarCliente(String id) async {
    final db = await _db;
    await db.update(
      'clientes',
      {'ativo': 1, 'sincronizado': 0},
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
  
  // MÉTODO ALTERADO
  Future<List<ClienteModel>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    final db = await _db;
    String where = 'idGestor = ?';
    List<dynamic> whereArgs = [idGestor];

    if (!incluirInativos) {
      where += ' AND ativo = ?';
      whereArgs.add(1);
    }

    final resultado = await db.query(
      'clientes',
      where: where,
      whereArgs: whereArgs,
    );

    return resultado
        .map((row) => ClienteModel.fromMap(row, row['id'] as String))
        .toList();
  }
}