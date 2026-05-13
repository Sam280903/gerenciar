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
  Timer? _debounceTimer;

  void iniciarSincronizacao() {
    // 1. Inicia o Timer Periódico (Fallback)
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await sincronizarDados();
    });

    // 2. Escuta mudanças de conectividade (Sincronização imediata ao voltar online)
    _connectivitySubscription?.cancel();
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(seconds: 3), () {
          if (kDebugMode) debugPrint("--- CONEXÃO RESTABELECIDA: Sincronizando agora ---");
          sincronizarDados();
          _debounceTimer = null;
        });
      }
    });

    sincronizarDados(); // Executa uma vez ao iniciar o app
  }

  void pararSincronizacao() {
    _timer?.cancel();
    _connectivitySubscription?.cancel();
    _debounceTimer?.cancel();
    _timer = null;
    _connectivitySubscription = null;
    _debounceTimer = null;
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
    await Future.wait([
      _uploadClientes().catchError((e) {
        if (kDebugMode) debugPrint('Falha geral no upload de clientes: $e');
      }),
      _uploadTecnicos().catchError((e) {
        if (kDebugMode) debugPrint('Falha geral no upload de técnicos: $e');
      }),
      _uploadAgendamentos().catchError((e) {
        if (kDebugMode) debugPrint('Falha geral no upload de agendamentos: $e');
      }),
      _uploadOrdensServico().catchError((e) {
        if (kDebugMode) debugPrint('Falha geral no upload de OS: $e');
      }),
      _uploadFormasPagamento().catchError((e) {
        if (kDebugMode) debugPrint('Falha geral no upload de formas de pagamento: $e');
      }),
    ]);
  }

  Future<void> _sincronizarDaNuvem() async {
    if (kDebugMode) debugPrint("--- Atualizando banco local com dados da nuvem... ---");
    try {
      // 1. Coleta os IDs de registros pendentes de upload (edições locais)
      //    para não sobrescrevê-los com dados mais antigos da nuvem
      final pendentesAg = await _agendamentoSqlite.listarNaoSincronizados();
      final pendentesClientes = await _clienteSqlite.listarNaoSincronizados();
      final pendentesFormas = await _formaPagamentoSqlite.listarNaoSincronizados();
      final pendentesOS = await _osSqlite.listarNaoSincronizados();
      final pendentesTecnicos = await _tecnicoSqlite.listarNaoSincronizados();

      final idsAgPendentes = pendentesAg.map((e) => e.id).toSet();
      final idsClientesPendentes = pendentesClientes.map((e) => e.id).toSet();
      final idsFormasPendentes = pendentesFormas.map((e) => e.id).toSet();
      final idsOSPendentes = pendentesOS.map((e) => e.id).toSet();
      final idsTecnicosPendentes = pendentesTecnicos.map((e) => e.id).toSet();

      // 2. Busca todas as entidades da nuvem em paralelo
      final agendamentosNuvem = await _agendamentoFirebase.listarRecentes();
      final clientesNuvem = await _clienteFirebase.listarRecentes();
      final formasNuvem = await _formaPagamentoFirebase.listarRecentes();
      final osNuvem = await _osFirebase.listarRecentes();
      final tecnicosNuvem = await _tecnicoFirebase.listarRecentes();

      // 3. Persiste apenas os registros que NÃO estão pendentes de upload
      await Future.wait([
        Future.forEach(
          agendamentosNuvem.where((a) => !idsAgPendentes.contains(a.id)),
          (a) => _agendamentoSqlite.adicionar(a),
        ),
        Future.forEach(
          clientesNuvem.where((c) => !idsClientesPendentes.contains(c.id)),
          (c) => _clienteSqlite.adicionarCliente(c),
        ),
        Future.forEach(
          formasNuvem.where((f) => !idsFormasPendentes.contains(f.id)),
          (f) => _formaPagamentoSqlite.adicionar(f),
        ),
        Future.forEach(
          osNuvem.where((os) => !idsOSPendentes.contains(os.id)),
          (os) => _osSqlite.adicionar(os),
        ),
        Future.forEach(
          tecnicosNuvem.where((t) => !idsTecnicosPendentes.contains(t.id)),
          (t) => _tecnicoSqlite.adicionarTecnico(t),
        ),
      ]);
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
        await _agendamentoFirebase.atualizar(model);
        await _agendamentoSqlite.marcarComoSincronizado(model.id);
        if (kDebugMode) debugPrint('Agendamento ${model.id} sincronizado.');
      } catch (e) {
        // Documento ainda não existe na nuvem — faz insert
        try {
          await _agendamentoFirebase.adicionar(model);
          await _agendamentoSqlite.marcarComoSincronizado(model.id);
          if (kDebugMode) debugPrint('Agendamento ${model.id} criado na nuvem.');
        } catch (e2) {
          if (kDebugMode) debugPrint('Erro no upload do agendamento ${model.id}: $e2');
        }
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
