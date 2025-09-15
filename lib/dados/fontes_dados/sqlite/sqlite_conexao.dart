import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SQLiteConexao {
  static Database? _db;

  static Future<Database> get db async {
    if (_db != null) return _db!;

    _db = await _abrirBanco();
    return _db!;
  }

  static Future<Database> _abrirBanco() async {
    final caminho = await getDatabasesPath();
    final caminhoBanco = join(caminho, 'gerenciar.db');

    return openDatabase(
      caminhoBanco,
      version: 1,
      onCreate: _criarTabelas,
    );
  }

  static Future<void> _criarTabelas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tecnicos (
        id TEXT PRIMARY KEY,
        nome TEXT,
        email TEXT,
        telefone TEXT,
        ativo INTEGER
      );
    ''');

    await db.execute('''
      CREATE TABLE clientes (
        id TEXT PRIMARY KEY,
        nome TEXT,
        email TEXT,
        telefone TEXT,
        endereco TEXT,
        ativo INTEGER
      );
    ''');

    await db.execute('''
      CREATE TABLE formas_pagamento (
        id TEXT PRIMARY KEY,
        nome TEXT,
        descricao TEXT,
        ativo INTEGER
      );
    ''');

    await db.execute('''
      CREATE TABLE ordens_servico (
        id TEXT PRIMARY KEY,
        idTecnico TEXT,
        idCliente TEXT,
        dataHoraInicio TEXT,
        dataHoraFim TEXT,
        descricao TEXT,
        valor REAL,
        status TEXT,
        ativo INTEGER
      );
    ''');

    await db.execute('''
      CREATE TABLE agendamentos (
        id TEXT PRIMARY KEY,
        idTecnico TEXT,
        idCliente TEXT,
        dataHora TEXT,
        observacao TEXT,
        ativo INTEGER
      );
    ''');

    // Adicione outras tabelas conforme o projeto cresce.
  }

  static Future<void> fechar() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
