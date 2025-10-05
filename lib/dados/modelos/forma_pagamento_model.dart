// lib/dados/modelos/forma_pagamento_model.dart
import '../../dominio/entidades/forma_pagamento.dart';

class FormaPagamentoModel {
  final String id;
  final String nome;
  final String? descricao;
  final bool ativo;
  final String idGestor; // ADICIONADO

  FormaPagamentoModel({
    required this.id,
    required this.nome,
    this.descricao,
    required this.ativo,
    required this.idGestor, // ADICIONADO
  });

  factory FormaPagamentoModel.fromEntidade(FormaPagamento entidade) {
    return FormaPagamentoModel(
      id: entidade.id,
      nome: entidade.nome,
      descricao: entidade.descricao,
      ativo: entidade.ativo,
      idGestor: entidade.idGestor, // ADICIONADO
    );
  }

  factory FormaPagamentoModel.fromMap(Map<String, dynamic> map, String id) {
    return FormaPagamentoModel(
      id: id,
      nome: map['nome'] ?? '',
      descricao: map['descricao'],
      ativo: map['ativo'] is bool ? map['ativo'] : (map['ativo'] == 1),
      idGestor: map['idGestor'] ?? '', // ADICIONADO
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'ativo': ativo,
      'idGestor': idGestor, // ADICIONADO
    };
  }

  FormaPagamento toEntidade() {
    return FormaPagamento(
      id: id,
      nome: nome,
      descricao: descricao,
      ativo: ativo,
      idGestor: idGestor, // ADICIONADO
    );
  }
}