// lib/dados/fontes_dados/firebase/tecnico_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gerenciar/dados/modelos/tecnico_model.dart';

class TecnicoFirebase {
  final _colecao = FirebaseFirestore.instance.collection('tecnicos');

  Future<void> adicionarTecnico(TecnicoModel tecnico) async {
    await _colecao.doc(tecnico.id).set(tecnico.toMap());
  }

  Future<void> atualizarTecnico(TecnicoModel tecnico) async {
    await _colecao.doc(tecnico.id).update(tecnico.toMap());
  }

  Future<void> inativarTecnico(String id) async {
    await _colecao.doc(id).update({'ativo': false});
  }

  // MÉTODO FALTANTE ADICIONADO
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

  // MÉTODO ATUALIZADO
  Future<List<TecnicoModel>> listarTodos({bool incluirInativos = false}) async {
    Query query = _colecao;
    // Se não for para incluir inativos, adiciona o filtro.
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
