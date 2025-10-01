// lib/servicos/sincronizacao_servico.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

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

  // Singleton para garantir uma única instância do serviço
  static final SincronizacaoServico _instance = SincronizacaoServico._internal();
  factory SincronizacaoServico() => _instance;
  SincronizacaoServico._internal();

  Timer? _timer;

  void iniciarSincronizacaoPeriodica() {
    // Cancela qualquer timer anterior para evitar múltiplos timers
    _timer?.cancel();
    
    // Executa a sincronização imediatamente na inicialização
    sincronizarDados();

    // E depois a cada 5 minutos
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await sincronizarDados();
    });
  }

  void pararSincronizacao() {
    _timer?.cancel();
  }

  Future<bool> _temConexao() async {
    final status = await Connectivity().checkConnectivity();
    return !status.contains(ConnectivityResult.none);
  }

  Future<void> sincronizarDados() async {
    if (await _temConexao()) {
      print("--- INICIANDO SINCRONIZAÇÃO ---");
      await _sincronizarClientes();
      await _sincronizarTecnicos();
      await _sincronizarAgendamentos();
      await _sincronizarOrdensServico();
      await _sincronizarFormasPagamento();
      print("--- SINCRONIZAÇÃO CONCLUÍDA ---");
    } else {
      print("Sem conexão para sincronizar.");
    }
  }

  // Métodos de sincronização para cada entidade

  Future<void> _sincronizarClientes() async {
    final itens = await _clienteSqlite.listarNaoSincronizados();
    for (final model in itens) {
      try {
        await _clienteFirebase.adicionarCliente(model); // ou atualizar se já existir
        await _clienteSqlite.marcarComoSincronizado(model.id);
        print('Cliente ${model.nome} sincronizado.');
      } catch (e) {
        print('Erro ao sincronizar cliente ${model.id}: $e');
      }
    }
  }

  Future<void> _sincronizarTecnicos() async {
    final itens = await _tecnicoSqlite.listarNaoSincronizados();
    for (final model in itens) {
      try {
        await _tecnicoFirebase.adicionarTecnico(model);
        await _tecnicoSqlite.marcarComoSincronizado(model.id);
        print('Técnico ${model.nome} sincronizado.');
      } catch (e) {
        print('Erro ao sincronizar técnico ${model.id}: $e');
      }
    }
  }

  Future<void> _sincronizarAgendamentos() async {
    final itens = await _agendamentoSqlite.listarNaoSincronizados();
    for (final model in itens) {
      try {
        await _agendamentoFirebase.adicionar(model);
        await _agendamentoSqlite.marcarComoSincronizado(model.id);
        print('Agendamento ${model.id} sincronizado.');
      } catch (e) {
        print('Erro ao sincronizar agendamento ${model.id}: $e');
      }
    }
  }

  Future<void> _sincronizarOrdensServico() async {
    final itens = await _osSqlite.listarNaoSincronizados();
    for (final model in itens) {
      try {
        await _osFirebase.adicionar(model);
        await _osSqlite.marcarComoSincronizado(model.id);
        print('OS ${model.id} sincronizada.');
      } catch (e) {
        print('Erro ao sincronizar OS ${model.id}: $e');
      }
    }
  }

  Future<void> _sincronizarFormasPagamento() async {
    final itens = await _formaPagamentoSqlite.listarNaoSincronizados();
    for (final model in itens) {
      try {
        await _formaPagamentoFirebase.adicionar(model);
        await _formaPagamentoSqlite.marcarComoSincronizado(model.id);
        print('Forma de Pagamento ${model.nome} sincronizada.');
      } catch (e) {
        print('Erro ao sincronizar forma de pagamento ${model.id}: $e');
      }
    }
  }
}