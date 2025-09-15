// lib/dominio/casos_uso/cliente/atualizar_cliente.dart
import '../../entidades/cliente.dart';
import '../../interfaces/cliente_repositorio_interface.dart';

class AtualizarCliente {
  final ClienteRepositorioInterface repositorio;
  AtualizarCliente(this.repositorio);
  Future<void> executar(Cliente cliente) async {
    await repositorio.atualizar(cliente);
  }
}
