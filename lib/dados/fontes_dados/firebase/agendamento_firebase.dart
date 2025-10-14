import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelos/agendamento_model.dart';

class AgendamentoFirebase {
  final _colecao = FirebaseFirestore.instance.collection('agendamentos');

  Future<bool> verificarConflito(String idTecnico, DateTime dataHora) async {
    final snapshot = await _colecao
        .where('idTecnico', isEqualTo: idTecnico)
        .where('dataHora', isEqualTo: Timestamp.fromDate(dataHora))
        .where('ativo', isEqualTo: true)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

//METODO ADICIONADO
  Future<List<AgendamentoModel>> listarRecentes() async {
    final snapshot =
        await _colecao.orderBy('dataHora', descending: true).limit(20).get();
    return snapshot.docs
        .map((doc) => AgendamentoModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> adicionar(AgendamentoModel agendamento) async {
    await _colecao.doc(agendamento.id).set(agendamento.toMap());
  }

  Future<void> atualizar(AgendamentoModel agendamento) async {
    await _colecao.doc(agendamento.id).update(agendamento.toMap());
  }

  Future<void> inativar(String id) async {
    await _colecao.doc(id).update({'ativo': false});
  }

  Future<void> reativar(String id) async {
    await _colecao.doc(id).update({'ativo': true});
  }

  Future<AgendamentoModel?> buscarPorId(String id) async {
    final doc = await _colecao.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return AgendamentoModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<AgendamentoModel>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    Query query = _colecao.where('idGestor', isEqualTo: idGestor);

    if (!incluirInativos) {
      query = query.where('ativo', isEqualTo: true);
    }
    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      return AgendamentoModel.fromMap(
          doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }
}
