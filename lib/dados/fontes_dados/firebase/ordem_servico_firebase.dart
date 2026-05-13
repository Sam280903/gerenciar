// lib/dados/fontes_dados/firebase/ordem_servico_firebase.dart
import 'package:gerenciar/servicos/relatorio_servico.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelos/ordem_servico_model.dart';

class OrdemServicoFirebase {
  final _colecao = FirebaseFirestore.instance.collection('ordens_servico');

  Future<List<OrdemServicoModel>> listarComFiltros(
      FiltrosRelatorio filtros, String idGestor) async {
    Query query = _colecao.where('idGestor', isEqualTo: idGestor);

    if (filtros.idTecnico != null && filtros.idTecnico!.isNotEmpty) {
      query = query.where('idTecnico', isEqualTo: filtros.idTecnico);
    }
    if (filtros.idCliente != null && filtros.idCliente!.isNotEmpty) {
      query = query.where('idCliente', isEqualTo: filtros.idCliente);
    }
    if (filtros.dataInicial != null) {
      query = query.where('dataHoraInicio',
          isGreaterThanOrEqualTo: Timestamp.fromDate(filtros.dataInicial!));
    }

    final snapshot = await query.get();
    var resultado = snapshot.docs.map((doc) {
      return OrdemServicoModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();

    if (filtros.status != null && filtros.status!.isNotEmpty) {
      resultado = resultado
          .where((os) => filtros.status!.contains(os.status))
          .toList();
    }
    if (filtros.dataFinal != null) {
      final dataFinalAjustada = filtros.dataFinal!
          .add(const Duration(hours: 23, minutes: 59, seconds: 59));
      resultado = resultado
          .where((os) => os.dataHoraInicio.isBefore(dataFinalAjustada))
          .toList();
    }

    return resultado;
  }

//METODO ADICIONADO
  Future<List<OrdemServicoModel>> listarRecentes() async {
    final snapshot = await _colecao
        .orderBy('dataHoraInicio', descending: true)
        .limit(500)
        .get();
    return snapshot.docs
        .map((doc) => OrdemServicoModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> reabrir(
      {required String id, required String justificativa}) async {
    await _colecao.doc(id).update({
      'status': 'Reaberta',
      'justificativaReabertura': justificativa,
      'dataReabertura': Timestamp.now(),
    });
  }

  Future<void> cancelar(
      {required String id, required String justificativa}) async {
    await _colecao.doc(id).update({
      'status': 'Cancelada',
      'justificativaCancelamento': justificativa,
      'dataCancelamento': Timestamp.now(),
    });
  }

  Future<void> adicionar(OrdemServicoModel os) async {
    await _colecao.doc(os.id).set(os.toMap());
  }

  Future<void> atualizar(OrdemServicoModel os) async {
    await _colecao.doc(os.id).update(os.toMap());
  }

  Future<void> inativar(String id) async {
    await _colecao.doc(id).update({'ativo': false});
  }

  Future<OrdemServicoModel?> buscarPorId(String id) async {
    final doc = await _colecao.doc(id).get();
    if (doc.exists && doc.data() != null) {
      return OrdemServicoModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }
    return null;
  }

  Future<List<OrdemServicoModel>> listarTodos(
      {required String idGestor}) async {
    final snapshot = await _colecao
        .where('ativo', isEqualTo: true)
        .where('idGestor', isEqualTo: idGestor)
        .get();
    return snapshot.docs.map((doc) {
      return OrdemServicoModel.fromMap(
        doc.data(),
        doc.id,
      );
    }).toList();
  }
}
