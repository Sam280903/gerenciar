// lib/dados/modelos/tecnico_model.dart
import '../../dominio/entidades/tecnico.dart';

class TecnicoModel {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final bool ativo;

  TecnicoModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.ativo,
  });

  factory TecnicoModel.fromEntidade(Tecnico tecnico) {
    return TecnicoModel(
      id: tecnico.id,
      nome: tecnico.nome,
      email: tecnico.email,
      telefone: tecnico.telefone,
      ativo: tecnico.ativo,
    );
  }

  factory TecnicoModel.fromMap(Map<String, dynamic> map, String id) {
    return TecnicoModel(
      id: id,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      // CORREÇÃO DEFINITIVA DO ERRO:
      telefone: map['telefone']?.toString() ?? '',
      ativo: map['ativo'] is bool ? map['ativo'] : (map['ativo'] == 1),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Importante para o SQLite
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'ativo': ativo,
    };
  }

  Tecnico toEntidade() {
    return Tecnico(
      id: id,
      nome: nome,
      email: email,
      telefone: telefone,
      ativo: ativo,
    );
  }
}
