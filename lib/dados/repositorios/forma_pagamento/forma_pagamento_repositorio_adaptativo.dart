// lib/dados/repositorios/forma_pagamento/forma_pagamento_repositorio_adaptativo.dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:gerenciar/dominio/interfaces/forma_pagamento_repositorio_interface.dart';
import 'forma_pagamento_repositorio_impl.dart';
import 'forma_pagamento_repositorio_impl_sqlite.dart';

class FormaPagamentoRepositorioAdaptativo
    implements FormaPagamentoRepositorioInterface {
  final _repositorioOnline = FormaPagamentoRepositorioImpl();
  final _repositorioOffline = FormaPagamentoRepositorioImplSQLite();

  Future<bool> _temConexao() async {
    final status = await Connectivity().checkConnectivity();
    return !status.contains(ConnectivityResult.none);
  }

  Future<FormaPagamentoRepositorioInterface> _escolherRepositorio() async {
    return await _temConexao() ? _repositorioOnline : _repositorioOffline;
  }

  @override
  Future<void> adicionar(FormaPagamento forma) async {
    final repo = await _escolherRepositorio();
    await repo.adicionar(forma);
  }

  @override
  Future<void> atualizar(FormaPagamento forma) async {
    final repo = await _escolherRepositorio();
    await repo.atualizar(forma);
  }

  @override
  Future<void> inativar(String id) async {
    final repo = await _escolherRepositorio();
    await repo.inativar(id);
  }

  @override
  Future<void> reativar(String id) async {
    final repo = await _escolherRepositorio();
    await repo.reativar(id);
  }

  @override
  Future<FormaPagamento?> buscarPorNome(String nome) async {
    final repo = await _escolherRepositorio();
    return await repo.buscarPorNome(nome);
  }

  @override
  Future<FormaPagamento?> buscarPorId(String id) async {
    final repo = await _escolherRepositorio();
    return await repo.buscarPorId(id);
  }

  @override
  Future<List<FormaPagamento>> listarTodos(
      {bool incluirInativos = false}) async {
    final repo = await _escolherRepositorio();
    return await repo.listarTodos(incluirInativos: incluirInativos);
  }
}
