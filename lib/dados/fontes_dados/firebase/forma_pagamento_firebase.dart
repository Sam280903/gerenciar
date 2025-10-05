// lib/dados/fontes_dados/firebase/forma_pagamento_firebase.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelos/forma_pagamento_model.dart';

class FormaPagamentoFirebase {
  final CollectionReference _colecao =
      FirebaseFirestore.instance.collection('formas_pagamento');

  Future<void> adicionar(FormaPagamentoModel forma) async {
    await _colecao.doc(forma.id).set(forma.toMap());
  }

  Future<void> atualizar(FormaPagamentoModel forma) async {
    await _colecao.doc(forma.id).update(forma.toMap());
  }

  Future<void> inativar(String id) async {
    await _colecao.doc(id).update({'ativo': false});
  }

  Future<void> reativar(String id) async {
    await _colecao.doc(id).update({'ativo': true});
  }

  Future<FormaPagamentoModel?> buscarPorId(String id) async {
    final doc = await _colecao.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return FormaPagamentoModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }
    return null;
  }

  Future<FormaPagamentoModel?> buscarPorNome(String nome) async {
    final snapshot =
        await _colecao.where('nome', isEqualTo: nome).limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      return FormaPagamentoModel.fromMap(
          doc.data() as Map<String, dynamic>, doc.id);
    }
    return null;
  }

  // MÉTODO ALTERADO
  Future<List<FormaPagamentoModel>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    Query query = _colecao.where('idGestor', isEqualTo: idGestor);

    if (!incluirInativos) {
      query = query.where('ativo', isEqualTo: true);
    }
    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => FormaPagamentoModel.fromMap(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ))
        .toList();
  }
}