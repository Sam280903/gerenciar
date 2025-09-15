// lib/dominio/entidades/forma_pagamento.dart
class FormaPagamento {
  final String id;
  final String nome;
  final String? descricao;
  final bool ativo;

  FormaPagamento({
    required this.id,
    required this.nome,
    this.descricao,
    required this.ativo,
  });
}
