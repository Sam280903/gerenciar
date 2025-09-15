// NOVO ARQUIVO: lib/dominio/casos_uso/cliente/reativar_cliente.dart
import '../../interfaces/cliente_repositorio_interface.dart';

class ReativarCliente {
  final ClienteRepositorioInterface repositorio;
  ReativarCliente(this.repositorio);
  Future<void> executar(String id) async {
    if (id.isEmpty) {
      throw Exception('ID do cliente é obrigatório.');
    }
    await repositorio.reativar(id);
  }
}
