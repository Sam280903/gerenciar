// lib/dados/modelos/cliente_model.dart
import '../../dominio/entidades/cliente.dart';

class ClienteModel {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String endereco;
  final String? cpf;
  final bool ativo;
  final String idGestor; // ADICIONADO

  ClienteModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.endereco,
    this.cpf,
    required this.ativo,
    required this.idGestor, // ADICIONADO
  });

  factory ClienteModel.fromEntidade(Cliente cliente) {
    return ClienteModel(
      id: cliente.id,
      nome: cliente.nome,
      email: cliente.email,
      telefone: cliente.telefone,
      endereco: cliente.endereco,
      cpf: cliente.cpf,
      ativo: cliente.ativo,
      idGestor: cliente.idGestor, // ADICIONADO
    );
  }

  factory ClienteModel.fromMap(Map<String, dynamic> map, String id) {
    return ClienteModel(
      id: id,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone']?.toString() ?? '',
      endereco: map['endereco'] ?? '',
      cpf: map['cpf']?.toString() ?? '',
      ativo: map['ativo'] is bool ? map['ativo'] : (map['ativo'] == 1),
      idGestor: map['idGestor'] ?? '', // ADICIONADO
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'endereco': endereco,
      'cpf': cpf,
      'ativo': ativo,
      'idGestor': idGestor, // ADICIONADO
    };
  }

  Cliente toEntidade() {
    return Cliente(
      id: id,
      nome: nome,
      email: email,
      telefone: telefone,
      endereco: endereco,
      cpf: cpf,
      ativo: ativo,
      idGestor: idGestor, // ADICIONADO
    );
  }
}