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
      version: 4, // ** IMPORTANTE: Incrementei a versão do banco para 4 **
      onCreate: _criarTabelas,
      onUpgrade: _atualizarTabelas,
    );
  }

  static Future<void> _atualizarTabelas(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
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
    // ADICIONADO Bloco para a versão 3
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE tecnicos ADD COLUMN idGestor TEXT');
      await db.execute('ALTER TABLE clientes ADD COLUMN idGestor TEXT');
      await db.execute('ALTER TABLE formas_pagamento ADD COLUMN idGestor TEXT');
      await db.execute('ALTER TABLE ordens_servico ADD COLUMN idGestor TEXT');
      await db.execute('ALTER TABLE agendamentos ADD COLUMN idGestor TEXT');
    }
    // ADICIONADO Bloco para a versão 4
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE agendamentos ADD COLUMN lembreteNotificacao TEXT');
      await db.execute('ALTER TABLE agendamentos ADD COLUMN notificacaoEnviada INTEGER DEFAULT 0');
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
        sincronizado INTEGER DEFAULT 0,
        idGestor TEXT 
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
        sincronizado INTEGER DEFAULT 0,
        idGestor TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE formas_pagamento (
        id TEXT PRIMARY KEY,
        nome TEXT,
        descricao TEXT,
        ativo INTEGER,
        sincronizado INTEGER DEFAULT 0,
        idGestor TEXT
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
        sincronizado INTEGER DEFAULT 0,
        idGestor TEXT
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
        sincronizado INTEGER DEFAULT 0,
        idGestor TEXT,
        lembreteNotificacao TEXT,
        notificacaoEnviada INTEGER DEFAULT 0
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