// lib/dominio/entidades/forma_pagamento.dart
class FormaPagamento {
  final String id;
  final String nome;
  final String? descricao;
  final bool ativo;
  final String idGestor; // ADICIONADO

  FormaPagamento({
    required this.id,
    required this.nome,
    this.descricao,
    required this.ativo,
    required this.idGestor, // ADICIONADO
  });
}