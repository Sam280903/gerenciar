// lib/dados/repositorios/cliente/cliente_repositorio_impl.dart
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/interfaces/cliente_repositorio_interface.dart';
import '../../fontes_dados/firebase/cliente_firebase.dart';
import '../../modelos/cliente_model.dart';

class ClienteRepositorioImpl implements ClienteRepositorioInterface {
  final ClienteFirebase _fonteFirebase = ClienteFirebase();

  @override
  Future<void> adicionar(Cliente cliente) async {
    final model = ClienteModel.fromEntidade(cliente);
    await _fonteFirebase.adicionarCliente(model);
  }

  @override
  Future<void> atualizar(Cliente cliente) async {
    final model = ClienteModel.fromEntidade(cliente);
    await _fonteFirebase.atualizarCliente(model);
  }

  @override
  Future<void> inativar(String id) async {
    await _fonteFirebase.inativarCliente(id);
  }

  @override
  Future<void> reativar(String id) async {
    await _fonteFirebase.reativarCliente(id);
  }

  @override
  Future<Cliente?> buscarPorId(String id) async {
    final model = await _fonteFirebase.buscarPorId(id);
    return model?.toEntidade();
  }

  // MÉTODO ALTERADO
  @override
  Future<List<Cliente>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    final modelos = await _fonteFirebase.listarTodos(
        idGestor: idGestor, incluirInativos: incluirInativos);
    return modelos.map((m) => m.toEntidade()).toList();
  }
}