// NOVO ARQUIVO: lib/dominio/casos_uso/tecnico/reativar_tecnico.dart
import '../../interfaces/tecnico_repositorio_interface.dart';

class ReativarTecnico {
  final TecnicoRepositorioInterface repositorio;
  ReativarTecnico(this.repositorio);
  Future<void> executar(String id) async {
    if (id.isEmpty) {
      throw Exception('ID do técnico é obrigatório.');
    }
    await repositorio.reativar(id);
  }
}
