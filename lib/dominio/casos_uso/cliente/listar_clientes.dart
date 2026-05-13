// lib/dominio/casos_uso/cliente/listar_clientes.dart
import '../../entidades/cliente.dart';
import '../../interfaces/cliente_repositorio_interface.dart';

class ListarClientes {
  final ClienteRepositorioInterface repositorio;
  ListarClientes(this.repositorio);

  // A mudança principal está aqui: a função agora exige 'idGestor'
  Future<List<Cliente>> executar(
      {required String idGestor, bool incluirInativos = false}) async {
    final clientes = await repositorio.listarTodos(
        idGestor: idGestor, incluirInativos: incluirInativos);
    clientes.sort((a, b) => a.nome.compareTo(b.nome));
    return clientes;
  }
}
