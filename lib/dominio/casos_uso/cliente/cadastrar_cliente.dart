// lib/dominio/casos_uso/cliente/cadastrar_cliente.dart
import '../../entidades/cliente.dart';
import '../../interfaces/cliente_repositorio_interface.dart';

class CadastrarCliente {
  final ClienteRepositorioInterface repositorio;
  CadastrarCliente(this.repositorio);
  Future<void> executar(Cliente cliente) async {
    await repositorio.adicionar(cliente);
  }
}
