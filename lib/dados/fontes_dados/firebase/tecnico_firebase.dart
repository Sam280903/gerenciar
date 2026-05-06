// lib/dados/fontes_dados/firebase/tecnico_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gerenciar/dados/modelos/tecnico_model.dart';

class TecnicoFirebase {
  final _colecao = FirebaseFirestore.instance.collection('tecnicos');

//METODO ADICIONADO
  Future<List<TecnicoModel>> listarRecentes() async {
    final snapshot = await _colecao.orderBy('nome').limit(500).get();
    return snapshot.docs
        .map((doc) => TecnicoModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> adicionarTecnico(TecnicoModel tecnico) async {
    await _colecao.doc(tecnico.id).set(tecnico.toMap());
  }

  Future<void> atualizarTecnico(TecnicoModel tecnico) async {
    await _colecao.doc(tecnico.id).update(tecnico.toMap());
  }

  Future<void> inativarTecnico(String id) async {
    await _colecao.doc(id).update({'ativo': false});
  }

  Future<void> reativarTecnico(String id) async {
    await _colecao.doc(id).update({'ativo': true});
  }

  Future<TecnicoModel?> buscarPorId(String id) async {
    final doc = await _colecao.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return TecnicoModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // MÉTODO ALTERADO
  Future<List<TecnicoModel>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    Query query = _colecao.where('idGestor', isEqualTo: idGestor);

    if (!incluirInativos) {
      query = query.where('ativo', isEqualTo: true);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) =>
            TecnicoModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  }
}
