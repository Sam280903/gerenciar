import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/interfaces/cliente_repositorio_interface.dart';

class ClienteRepositorioMemoria implements ClienteRepositorioInterface {
  final _dados = <String, Cliente>{};

  @override
  Future<void> adicionar(Cliente cliente) async {
    _dados[cliente.id] = cliente;
  }

  @override
  Future<void> atualizar(Cliente cliente) async {
    _dados[cliente.id] = cliente;
  }

  @override
  Future<void> inativar(String id) async {
    final c = _dados[id];
    if (c == null) return;
    _dados[id] = Cliente(
      id: c.id,
      nome: c.nome,
      email: c.email,
      telefone: c.telefone,
      endereco: c.endereco,
      cpf: c.cpf,
      ativo: false,
      idGestor: c.idGestor,
    );
  }

  @override
  Future<void> reativar(String id) async {
    final c = _dados[id];
    if (c == null) return;
    _dados[id] = Cliente(
      id: c.id,
      nome: c.nome,
      email: c.email,
      telefone: c.telefone,
      endereco: c.endereco,
      cpf: c.cpf,
      ativo: true,
      idGestor: c.idGestor,
    );
  }

  @override
  Future<Cliente?> buscarPorId(String id) async {
    return _dados[id];
  }

  @override
  Future<List<Cliente>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    return _dados.values
        .where((c) =>
            c.idGestor == idGestor && (incluirInativos || c.ativo))
        .toList();
  }
}
