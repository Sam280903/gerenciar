// lib/dados/fontes_dados/sqlite/ordem_servico_sqlite.dart
import 'package:sqflite/sqflite.dart';
import 'package:gerenciar/dados/fontes_dados/sqlite/sqlite_conexao.dart';
import '../../modelos/ordem_servico_model.dart';

class OrdemServicoSQLite {
  Future<Database> get _db async => await SQLiteConexao.db;

  Future<List<OrdemServicoModel>> listarNaoSincronizados() async {
    final db = await _db;
    final resultado = await db.query(
      'ordens_servico',
      where: 'sincronizado = ?',
      whereArgs: [0],
    );
    return resultado.map((linha) => OrdemServicoModel.fromDbMap(linha)).toList();
  }

  Future<void> marcarComoSincronizado(String id) async {
    final db = await _db;
    await db.update(
      'ordens_servico',
      {'sincronizado': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> reabrir(
      {required String id, required String justificativa}) async {
    final db = await _db;
    await db.update(
      'ordens_servico',
      {
        'status': 'Reaberto',
        'justificativaReabertura': justificativa,
        'sincronizado': 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> adicionar(OrdemServicoModel os) async {
    final db = await _db;
    await db.insert(
      'ordens_servico',
      os.toMapForDb(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> atualizar(OrdemServicoModel os) async {
    final db = await _db;
    final dados = os.toMapForDb()..['sincronizado'] = 0;
    await db.update(
      'ordens_servico',
      dados,
      where: 'id = ?',
      whereArgs: [os.id],
    );
  }

  Future<void> inativar(String id) async {
    final db = await _db;
    await db.update(
      'ordens_servico',
      {'ativo': 0, 'sincronizado': 0},
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
      return OrdemServicoModel.fromDbMap(resultado.first);
    }
    return null;
  }

  // MÉTODO ALTERADO
  Future<List<OrdemServicoModel>> listarTodos({required String idGestor}) async {
    final db = await _db;
    final resultado = await db.query(
      'ordens_servico',
      where: 'ativo = ? AND idGestor = ?',
      whereArgs: [1, idGestor],
    );
    return resultado
        .map((linha) => OrdemServicoModel.fromDbMap(linha))
        .toList();
  }
}