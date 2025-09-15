// lib/dados/fontes_dados/firebase/ordem_servico_firebase.dart
import 'package:gerenciar/servicos/relatorio_servico.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../modelos/ordem_servico_model.dart';

class OrdemServicoFirebase {
  final _colecao = FirebaseFirestore.instance.collection('ordens_servico');

  // Novo método para listar com filtros
  Future<List<OrdemServicoModel>> listarComFiltros(
      FiltrosRelatorio filtros) async {
    // Começamos com a consulta base
    Query query = _colecao;

    // Aplicamos os filtros dinamicamente
    if (filtros.idTecnico != null && filtros.idTecnico!.isNotEmpty) {
      query = query.where('idTecnico', isEqualTo: filtros.idTecnico);
    }
    if (filtros.idCliente != null && filtros.idCliente!.isNotEmpty) {
      query = query.where('idCliente', isEqualTo: filtros.idCliente);
    }
    if (filtros.status != null && filtros.status!.isNotEmpty) {
      query = query.where('status', whereIn: filtros.status);
    }
    if (filtros.dataInicial != null) {
      query = query.where('dataHoraInicio',
          isGreaterThanOrEqualTo: Timestamp.fromDate(filtros.dataInicial!));
    }
    if (filtros.dataFinal != null) {
      // Adiciona 23:59:59 para incluir o dia inteiro
      final dataFinalAjustada = filtros.dataFinal!
          .add(const Duration(hours: 23, minutes: 59, seconds: 59));
      query = query.where('dataHoraInicio',
          isLessThanOrEqualTo: Timestamp.fromDate(dataFinalAjustada));
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      return OrdemServicoModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }).toList();
  }

  //Método para reabrir
  Future<void> reabrir(
      {required String id, required String justificativa}) async {
    await _colecao.doc(id).update({
      'status': 'Reaberto',
      'justificativaReabertura': justificativa, // Campo para auditoria
      'dataReabertura': Timestamp.now(), // Campo para auditoria
    });
  }

  Future<void> adicionar(OrdemServicoModel os) async {
    // O método set sobrescreve o documento inteiro. Para adicionar, é melhor usar .add ou .doc(id).set
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

  Future<List<OrdemServicoModel>> listarTodos() async {
    final snapshot = await _colecao.where('ativo', isEqualTo: true).get();
    return snapshot.docs.map((doc) {
      return OrdemServicoModel.fromMap(
        doc.data(),
        doc.id,
      );
    }).toList();
  }
}
