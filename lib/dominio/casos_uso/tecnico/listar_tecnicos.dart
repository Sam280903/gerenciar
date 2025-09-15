// lib/dominio/casos_uso/tecnico/listar_tecnicos.dart
import '../../entidades/tecnico.dart';
import '../../interfaces/tecnico_repositorio_interface.dart';

class ListarTecnicos {
  final TecnicoRepositorioInterface repositorio;
  ListarTecnicos(this.repositorio);
  Future<List<Tecnico>> executar({bool incluirInativos = false}) async {
    return await repositorio.listarTodos(incluirInativos: incluirInativos);
  }
}
