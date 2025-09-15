// lib/dados/fontes_dados/firebase/agendamento_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelos/agendamento_model.dart';

class AgendamentoFirebase {
  final _colecao = FirebaseFirestore.instance.collection('agendamentos');

  // Novo método para fazer a consulta no Firestore
  Future<bool> verificarConflito(String idTecnico, DateTime dataHora) async {
    final snapshot = await _colecao
        .where('idTecnico', isEqualTo: idTecnico)
        .where('dataHora', isEqualTo: dataHora.toIso8601String())
        .where('ativo',
            isEqualTo:
                true) // Garante que não conflite com agendamentos inativos
        .limit(1)
        .get();

    // Se a consulta retornar algum documento, significa que o horário está ocupado.
    return snapshot.docs.isNotEmpty;
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

  Future<AgendamentoModel?> buscarPorId(String id) async {
    final doc = await _colecao.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return AgendamentoModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<List<AgendamentoModel>> listarTodos() async {
    final snapshot = await _colecao.where('ativo', isEqualTo: true).get();
    return snapshot.docs.map((doc) {
      return AgendamentoModel.fromMap(doc.data(), doc.id);
    }).toList();
  }
}
