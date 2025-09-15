import '../../entidades/tecnico.dart';
import '../../interfaces/tecnico_repositorio_interface.dart';

class BuscarTecnicoPorId {
  final TecnicoRepositorioInterface repositorio;

  BuscarTecnicoPorId(this.repositorio);

  Future<Tecnico?> executar(String id) async {
    if (id.isEmpty) {
      throw Exception('ID do técnico é obrigatório.');
    }

    return await repositorio.buscarPorId(id);
  }
}
