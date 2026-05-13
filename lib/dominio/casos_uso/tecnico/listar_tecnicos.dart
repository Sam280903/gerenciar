// lib/dominio/casos_uso/tecnico/listar_tecnicos.dart
import '../../entidades/tecnico.dart';
import '../../interfaces/tecnico_repositorio_interface.dart';

class ListarTecnicos {
  final TecnicoRepositorioInterface repositorio;
  ListarTecnicos(this.repositorio);

  Future<List<Tecnico>> executar(
      {required String idGestor, bool incluirInativos = false}) async {
    final tecnicos = await repositorio.listarTodos(
        idGestor: idGestor, incluirInativos: incluirInativos);
    tecnicos.sort((a, b) => a.nome.compareTo(b.nome));
    return tecnicos;
  }
}
