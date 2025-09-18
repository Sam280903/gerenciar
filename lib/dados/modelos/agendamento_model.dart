// lib/dados/modelos/agendamento_model.dart
import '../../dominio/entidades/agendamento.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgendamentoModel {
  final String id;
  final String idTecnico;
  final String idCliente;
  final DateTime dataHora;
  final String? observacao;
  final String status;
  final bool ativo;

  AgendamentoModel({
    required this.id,
    required this.idTecnico,
    required this.idCliente,
    required this.dataHora,
    this.observacao,
    required this.status,
    required this.ativo,
  });

  factory AgendamentoModel.fromEntidade(Agendamento ag) {
    return AgendamentoModel(
      id: ag.id,
      idTecnico: ag.idTecnico,
      idCliente: ag.idCliente,
      dataHora: ag.dataHora,
      observacao: ag.observacao,
      status: ag.status,
      ativo: ag.ativo,
    );
  }

  factory AgendamentoModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate;
    // --- CORREÇÃO DEFINITIVA APLICADA AQUI ---
    // Verifica se o campo 'dataHora' não é nulo antes de tentar processá-lo.
    if (map['dataHora'] != null) {
      if (map['dataHora'] is Timestamp) {
        parsedDate = (map['dataHora'] as Timestamp).toDate();
      } else if (map['dataHora'] is String) {
        parsedDate = DateTime.tryParse(map['dataHora']) ?? DateTime.now();
      } else {
        parsedDate = DateTime.now(); // Valor padrão em caso de tipo inesperado
      }
    } else {
      parsedDate = DateTime.now(); // Valor padrão se o campo for nulo
    }
    // --- FIM DA CORREÇÃO ---

    return AgendamentoModel(
      id: id,
      idTecnico: map['idTecnico'] ?? '',
      idCliente: map['idCliente'] ?? '',
      dataHora: parsedDate,
      observacao: map['observacao'],
      status: map['status'] ?? 'Pendente',
      ativo: map['ativo'] is bool ? map['ativo'] : (map['ativo'] == 1),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idTecnico': idTecnico,
      'idCliente': idCliente,
      'dataHora': Timestamp.fromDate(dataHora),
      'observacao': observacao,
      'status': status,
      'ativo': ativo,
    };
  }

  Map<String, dynamic> toMapForDb() {
    return {
      'id': id,
      'idTecnico': idTecnico,
      'idCliente': idCliente,
      'dataHora': dataHora.toIso8601String(),
      'observacao': observacao,
      'status': status,
      'ativo': ativo ? 1 : 0,
    };
  }

  Agendamento toEntidade() {
    return Agendamento(
      id: id,
      idTecnico: idTecnico,
      idCliente: idCliente,
      dataHora: dataHora,
      observacao: observacao,
      status: status,
      ativo: ativo,
    );
  }
}
