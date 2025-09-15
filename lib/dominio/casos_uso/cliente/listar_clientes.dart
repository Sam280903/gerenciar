// lib/dominio/casos_uso/cliente/listar_clientes.dart
import '../../entidades/cliente.dart';
import '../../interfaces/cliente_repositorio_interface.dart';

class ListarClientes {
  final ClienteRepositorioInterface repositorio;
  ListarClientes(this.repositorio);
  Future<List<Cliente>> executar({bool incluirInativos = false}) async {
    return await repositorio.listarTodos(incluirInativos: incluirInativos);
  }
}
