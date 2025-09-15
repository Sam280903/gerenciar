// lib/dominio/entidades/tecnico.dart
class Tecnico {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final bool ativo;

  Tecnico({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.ativo,
  });
}
