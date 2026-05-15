// lib/dados/fontes_dados/firebase/cliente_firebase.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelos/cliente_model.dart';

class ClienteFirebase {
  final CollectionReference _colecao =
      FirebaseFirestore.instance.collection('clientes');

  Future<List<ClienteModel>> listarRecentes() async {
    final snapshot = await _colecao.orderBy('nome').limit(500).get();
    return snapshot.docs
        .map((doc) =>
            ClienteModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }

  Future<void> adicionarCliente(ClienteModel cliente) async {
    await _colecao.doc(cliente.id).set(cliente.toMap());
  }

  Future<void> atualizarCliente(ClienteModel cliente) async {
    await _colecao.doc(cliente.id).update(cliente.toMap());
  }

  Future<void> inativarCliente(String id) async {
    await _colecao.doc(id).update({'ativo': false});
  }

  Future<void> reativarCliente(String id) async {
    await _colecao.doc(id).update({'ativo': true});
  }

  Future<ClienteModel?> buscarPorId(String id) async {
    final doc = await _colecao.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return ClienteModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  Future<List<ClienteModel>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    Query query = _colecao.where('idGestor', isEqualTo: idGestor);

    if (!incluirInativos) {
      query = query.where('ativo', isEqualTo: true);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) =>
            ClienteModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
