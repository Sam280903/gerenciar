// lib/dados/fontes_dados/sqlite/sqlite_conexao.dart
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
      version: 2, // ** IMPORTANTE: Incremente a versão do banco **
      onCreate: _criarTabelas,
      onUpgrade: _atualizarTabelas, // ** Adicione o onUpgrade **
    );
  }

  static Future<void> _atualizarTabelas(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adiciona a coluna 'sincronizado' se a versão anterior for menor que 2
      await db.execute(
          'ALTER TABLE tecnicos ADD COLUMN sincronizado INTEGER DEFAULT 0');
      await db.execute(
          'ALTER TABLE clientes ADD COLUMN sincronizado INTEGER DEFAULT 0');
      await db.execute(
          'ALTER TABLE formas_pagamento ADD COLUMN sincronizado INTEGER DEFAULT 0');
      await db.execute(
          'ALTER TABLE ordens_servico ADD COLUMN sincronizado INTEGER DEFAULT 0');
      await db.execute(
          'ALTER TABLE agendamentos ADD COLUMN sincronizado INTEGER DEFAULT 0');
    }
  }

  static Future<void> _criarTabelas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tecnicos (
        id TEXT PRIMARY KEY,
        nome TEXT,
        email TEXT,
        telefone TEXT,
        ativo INTEGER,
        sincronizado INTEGER DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE clientes (
        id TEXT PRIMARY KEY,
        nome TEXT,
        email TEXT,
        telefone TEXT,
        endereco TEXT,
        cpf TEXT,
        ativo INTEGER,
        sincronizado INTEGER DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE formas_pagamento (
        id TEXT PRIMARY KEY,
        nome TEXT,
        descricao TEXT,
        ativo INTEGER,
        sincronizado INTEGER DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE ordens_servico (
        id TEXT PRIMARY KEY,
        idTecnico TEXT,
        idCliente TEXT,
        idFormaPagamento TEXT,
        dataHoraInicio TEXT,
        dataHoraFim TEXT,
        descricao TEXT,
        valor REAL,
        prioridade TEXT,
        status TEXT,
        justificativaReabertura TEXT,
        ativo INTEGER,
        sincronizado INTEGER DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE agendamentos (
        id TEXT PRIMARY KEY,
        idTecnico TEXT,
        idCliente TEXT,
        dataHora TEXT,
        observacao TEXT,
        status TEXT,
        ativo INTEGER,
        sincronizado INTEGER DEFAULT 0
      );
    ''');
  }

  static Future<void> fechar() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}