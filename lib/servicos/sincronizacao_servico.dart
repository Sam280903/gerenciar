// lib/servicos/sincronizacao_servico.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

// Fontes de dados Firebase
import 'package:gerenciar/dados/fontes_dados/firebase/cliente_firebase.dart';
import 'package:gerenciar/dados/fontes_dados/firebase/tecnico_firebase.dart';
import 'package:gerenciar/dados/fontes_dados/firebase/agendamento_firebase.dart';
import 'package:gerenciar/dados/fontes_dados/firebase/ordem_servico_firebase.dart';
import 'package:gerenciar/dados/fontes_dados/firebase/forma_pagamento_firebase.dart';

// Fontes de dados SQLite
import 'package:gerenciar/dados/fontes_dados/sqlite/cliente_sqlite.dart';
import 'package:gerenciar/dados/fontes_dados/sqlite/tecnico_sqlite.dart';
import 'package:gerenciar/dados/fontes_dados/sqlite/agendamento_sqlite.dart';
import 'package:gerenciar/dados/fontes_dados/sqlite/ordem_servico_sqlite.dart';
import 'package:gerenciar/dados/fontes_dados/sqlite/forma_pagamento_sqlite.dart';

class SincronizacaoServico {
  // Instâncias para Firebase
  final _clienteFirebase = ClienteFirebase();
  final _tecnicoFirebase = TecnicoFirebase();
  final _agendamentoFirebase = AgendamentoFirebase();
  final _osFirebase = OrdemServicoFirebase();
  final _formaPagamentoFirebase = FormaPagamentoFirebase();

  // Instâncias para SQLite
  final _clienteSqlite = ClienteSQLite();
  final _tecnicoSqlite = TecnicoSQLite();
  final _agendamentoSqlite = AgendamentoSQLite();
  final _osSqlite = OrdemServicoSQLite();
  final _formaPagamentoSqlite = FormaPagamentoSQLite();

  // Singleton
  static final SincronizacaoServico _instance =
      SincronizacaoServico._internal();
  factory SincronizacaoServico() => _instance;
  SincronizacaoServico._internal();

  Timer? _timer;
  StreamSubscription? _connectivitySubscription;

  void iniciarSincronizacao() {
    // 1. Inicia o Timer Periódico (Fallback)
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await sincronizarDados();
    });

    // 2. Escuta mudanças de conectividade (Sincronização imediata ao voltar online)
    _connectivitySubscription?.cancel();
    Timer? debounce;
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        debounce?.cancel();
        debounce = Timer(const Duration(seconds: 3), () {
          if (kDebugMode) debugPrint("--- CONEXÃO RESTABELECIDA: Sincronizando agora ---");
          sincronizarDados();
        });
      }
    });

    sincronizarDados(); // Executa uma vez ao iniciar o app
  }

  void pararSincronizacao() {
    _timer?.cancel();
    _connectivitySubscription?.cancel();
  }

  Future<bool> _temConexao() async {
    final status = await Connectivity().checkConnectivity();
    return !status.contains(ConnectivityResult.none);
  }

  Future<void> sincronizarDados() async {
    if (await _temConexao()) {
      if (kDebugMode) debugPrint("--- INICIANDO SINCRONIZAÇÃO COMPLETA ---");
      await _sincronizarParaNuvem();
      await _sincronizarDaNuvem();
      if (kDebugMode) debugPrint("--- SINCRONIZAÇÃO COMPLETA CONCLUÍDA ---");
    } else {
      if (kDebugMode) debugPrint("Dispositivo offline. Operando apenas com banco local.");
    }
  }

  Future<void> _sincronizarParaNuvem() async {
    if (kDebugMode) debugPrint("--- Subindo dados locais pendentes... ---");
    await _uploadClientes();
    await _uploadTecnicos();
    await _uploadAgendamentos();
    await _uploadOrdensServico();
    await _uploadFormasPagamento();
  }

  Future<void> _sincronizarDaNuvem() async {
    if (kDebugMode) debugPrint("--- Atualizando banco local com dados da nuvem... ---");

    // Em vez de delete total, buscamos o que há de novo para fazer o "Upsert"
    // Isso evita apagar dados locais que o usuário acabou de criar offline

    try {
      final agendamentosNuvem = await _agendamentoFirebase.listarRecentes();
      for (final a in agendamentosNuvem) {
        // A lógica de adicionar deve verificar se o ID já existe (Update or Insert)
        await _agendamentoSqlite.adicionar(a);
      }

      final clientesNuvem = await _clienteFirebase.listarRecentes();
      for (final c in clientesNuvem) {
        await _clienteSqlite.adicionarCliente(c);
      }

      final formasNuvem = await _formaPagamentoFirebase.listarRecentes();
      for (final f in formasNuvem) {
        await _formaPagamentoSqlite.adicionar(f);
      }

      final osNuvem = await _osFirebase.listarRecentes();
      for (final os in osNuvem) {
        await _osSqlite.adicionar(os);
      }

      final tecnicosNuvem = await _tecnicoFirebase.listarRecentes();
      for (final t in tecnicosNuvem) {
        await _tecnicoSqlite.adicionarTecnico(t);
      }
    } catch (e) {
      if (kDebugMode) debugPrint("Erro ao baixar dados da nuvem: $e");
    }
  }

  // --- MÉTODOS DE UPLOAD (LOCAL -> NUVEM) ---

  Future<void> _uploadClientes() async {
    final itens = await _clienteSqlite.listarNaoSincronizados();
    for (final model in itens) {
      try {
        await _clienteFirebase.adicionarCliente(model);
        await _clienteSqlite.marcarComoSincronizado(model.id);
        if (kDebugMode) debugPrint('Cliente ${model.nome} sincronizado.');
      } catch (e) {
        if (kDebugMode) debugPrint('Erro no upload do cliente ${model.id}: $e');
      }
    }
  }

  Future<void> _uploadTecnicos() async {
    final itens = await _tecnicoSqlite.listarNaoSincronizados();
    for (final model in itens) {
      try {
        await _tecnicoFirebase.adicionarTecnico(model);
        await _tecnicoSqlite.marcarComoSincronizado(model.id);
        if (kDebugMode) debugPrint('Técnico ${model.nome} sincronizado.');
      } catch (e) {
        if (kDebugMode) debugPrint('Erro no upload do técnico ${model.id}: $e');
      }
    }
  }

  Future<void> _uploadAgendamentos() async {
    final itens = await _agendamentoSqlite.listarNaoSincronizados();
    for (final model in itens) {
      try {
        await _agendamentoFirebase.adicionar(model);
        await _agendamentoSqlite.marcarComoSincronizado(model.id);
        if (kDebugMode) debugPrint('Agendamento ${model.id} sincronizado.');
      } catch (e) {
        if (kDebugMode) debugPrint('Erro no upload do agendamento ${model.id}: $e');
      }
    }
  }

  Future<void> _uploadOrdensServico() async {
    final itens = await _osSqlite.listarNaoSincronizados();
    for (final model in itens) {
      try {
        await _osFirebase.adicionar(model);
        await _osSqlite.marcarComoSincronizado(model.id);
        if (kDebugMode) debugPrint('OS ${model.id} sincronizada.');
      } catch (e) {
        if (kDebugMode) debugPrint('Erro no upload da OS ${model.id}: $e');
      }
    }
  }

  Future<void> _uploadFormasPagamento() async {
    final itens = await _formaPagamentoSqlite.listarNaoSincronizados();
    for (final model in itens) {
      try {
        await _formaPagamentoFirebase.adicionar(model);
        await _formaPagamentoSqlite.marcarComoSincronizado(model.id);
        if (kDebugMode) debugPrint('Forma de Pagamento ${model.nome} sincronizada.');
      } catch (e) {
        if (kDebugMode) debugPrint('Erro no upload da forma de pagamento ${model.id}: $e');
      }
    }
  }
}
