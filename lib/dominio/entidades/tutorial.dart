// lib/dominio/entidades/tutorial.dart

class Tutorial {
  final String titulo;
  final String conteudo;
  final String categoria; // Novo campo
  final String? videoUrl;

  Tutorial({
    required this.titulo,
    required this.conteudo,
    required this.categoria,
    this.videoUrl,
  });
}
