// lib/dominio/entidades/cliente.dart
class Cliente {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final String endereco;
  final String? cpf;
  final bool ativo;
  final String idGestor; // ADICIONADO

  Cliente({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.endereco,
    this.cpf,
    required this.ativo,
    required this.idGestor, // ADICIONADO
  });
}