import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:gerenciar/dominio/interfaces/forma_pagamento_repositorio_interface.dart';

class FormaPagamentoRepositorioMemoria
    implements FormaPagamentoRepositorioInterface {
  final _dados = <String, FormaPagamento>{};

  @override
  Future<void> adicionar(FormaPagamento forma) async {
    _dados[forma.id] = forma;
  }

  @override
  Future<void> atualizar(FormaPagamento forma) async {
    _dados[forma.id] = forma;
  }

  @override
  Future<void> inativar(String id) async {
    final fp = _dados[id];
    if (fp == null) return;
    _dados[id] = FormaPagamento(
      id: fp.id,
      nome: fp.nome,
      descricao: fp.descricao,
      ativo: false,
      idGestor: fp.idGestor,
    );
  }

  @override
  Future<void> reativar(String id) async {
    final fp = _dados[id];
    if (fp == null) return;
    _dados[id] = FormaPagamento(
      id: fp.id,
      nome: fp.nome,
      descricao: fp.descricao,
      ativo: true,
      idGestor: fp.idGestor,
    );
  }

  @override
  Future<FormaPagamento?> buscarPorId(String id) async {
    return _dados[id];
  }

  @override
  Future<FormaPagamento?> buscarPorNome(String nome) async {
    try {
      return _dados.values.firstWhere((fp) => fp.nome == nome);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<FormaPagamento>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    return _dados.values
        .where((fp) =>
            fp.idGestor == idGestor && (incluirInativos || fp.ativo))
        .toList();
  }
}
