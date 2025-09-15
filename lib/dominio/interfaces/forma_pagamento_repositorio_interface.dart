// lib/dominio/interfaces/forma_pagamento_repositorio_interface.dart
import '../entidades/forma_pagamento.dart';

abstract class FormaPagamentoRepositorioInterface {
  Future<void> adicionar(FormaPagamento forma);
  Future<void> atualizar(FormaPagamento forma);
  Future<void> inativar(String id);
  Future<void> reativar(String id);
  Future<FormaPagamento?> buscarPorId(String id);
  Future<FormaPagamento?> buscarPorNome(String nome);
  Future<List<FormaPagamento>> listarTodos({bool incluirInativos = false});
}
