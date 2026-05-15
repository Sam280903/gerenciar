// lib/dominio/entidades/tutorial.dart

class Tutorial {
  final String titulo;
  final String conteudo;
  final String categoria;
  final String? videoUrlGestor;
  final String? videoUrlTecnico;
  final List<String> perfisPermitidos;

  Tutorial({
    required this.titulo,
    required this.conteudo,
    required this.categoria,
    this.videoUrlGestor,
    this.videoUrlTecnico,
    this.perfisPermitidos = const ['gestor', 'tecnico'],
  });

  String? videoUrlParaPerfil(String perfil) {
    if (perfil == 'gestor') return videoUrlGestor;
    if (perfil == 'tecnico') return videoUrlTecnico;
    return videoUrlGestor ?? videoUrlTecnico;
  }
}
