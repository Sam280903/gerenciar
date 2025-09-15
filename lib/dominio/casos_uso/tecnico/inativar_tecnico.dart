// lib/dominio/casos_uso/tecnico/inativar_tecnico.dart
import '../../interfaces/tecnico_repositorio_interface.dart';

class InativarTecnico {
  final TecnicoRepositorioInterface repositorio;
  InativarTecnico(this.repositorio);
  Future<void> executar(String id) async {
    if (id.isEmpty) {
      throw Exception('ID do técnico é obrigatório.');
    }
    await repositorio.inativar(id);
  }
}
