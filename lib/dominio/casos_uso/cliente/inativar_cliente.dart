// lib/dominio/casos_uso/cliente/inativar_cliente.dart
import '../../interfaces/cliente_repositorio_interface.dart';

class InativarCliente {
  final ClienteRepositorioInterface repositorio;
  InativarCliente(this.repositorio);
  Future<void> executar(String id) async {
    await repositorio.inativar(id);
  }
}
