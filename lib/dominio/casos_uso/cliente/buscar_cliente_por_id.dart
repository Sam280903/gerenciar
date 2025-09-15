import '../../entidades/cliente.dart';
import '../../interfaces/cliente_repositorio_interface.dart';

class BuscarClientePorId {
  final ClienteRepositorioInterface repositorio;

  BuscarClientePorId(this.repositorio);

  Future<Cliente?> executar(String id) async {
    return await repositorio.buscarPorId(id);
  }
}
