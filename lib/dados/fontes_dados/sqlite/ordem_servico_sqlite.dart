// lib/dados/fontes_dados/sqlite/ordem_servico_sqlite.dart
import 'package:sqflite/sqflite.dart';
import 'package:gerenciar/dados/fontes_dados/sqlite/sqlite_conexao.dart';
import '../../modelos/ordem_servico_model.dart';

class OrdemServicoSQLite {
  Future<Database> get _db async => await SQLiteConexao.db;

  Future<void> reabrir(
      {required String id, required String justificativa}) async {
    final db = await _db;
    await db.update(
      'ordens_servico',
      {
        'status': 'Reaberto',
        'justificativaReabertura': justificativa,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> adicionar(OrdemServicoModel os) async {
    final db = await _db;
    await db.insert(
      'ordens_servico',
      os.toMapForDb(), // CORRIGIDO
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> atualizar(OrdemServicoModel os) async {
    final db = await _db;
    await db.update(
      'ordens_servico',
      os.toMapForDb(), // CORRIGIDO
      where: 'id = ?',
      whereArgs: [os.id],
    );
  }

  Future<void> inativar(String id) async {
    final db = await _db;
    await db.update(
      'ordens_servico',
      {'ativo': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<OrdemServicoModel?> buscarPorId(String id) async {
    final db = await _db;
    final resultado = await db.query(
      'ordens_servico',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (resultado.isNotEmpty) {
      return OrdemServicoModel.fromDbMap(resultado.first); // CORRIGIDO
    }
    return null;
  }

  Future<List<OrdemServicoModel>> listarTodos() async {
    final db = await _db;
    final resultado = await db.query(
      'ordens_servico',
      where: 'ativo = ?',
      whereArgs: [1],
    );
    return resultado
        .map((linha) => OrdemServicoModel.fromDbMap(linha)) // CORRIGIDO
        .toList();
  }
}
