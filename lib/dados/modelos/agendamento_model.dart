// lib/dados/modelos/agendamento_model.dart
import '../../dominio/entidades/agendamento.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgendamentoModel {
  final String id;
  final String idTecnico;
  final String idCliente;
  final String idGestor; // ADICIONADO
  final DateTime dataHora;
  final String? observacao;
  final String status;
  final bool ativo;

  AgendamentoModel({
    required this.id,
    required this.idTecnico,
    required this.idCliente,
    required this.idGestor, // ADICIONADO
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
      idGestor: ag.idGestor, // ADICIONADO
      dataHora: ag.dataHora,
      observacao: ag.observacao,
      status: ag.status,
      ativo: ag.ativo,
    );
  }

  factory AgendamentoModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedDate;
    if (map['dataHora'] != null) {
      if (map['dataHora'] is Timestamp) {
        parsedDate = (map['dataHora'] as Timestamp).toDate();
      } else if (map['dataHora'] is String) {
        parsedDate = DateTime.tryParse(map['dataHora']) ?? DateTime.now();
      } else {
        parsedDate = DateTime.now();
      }
    } else {
      parsedDate = DateTime.now();
    }

    return AgendamentoModel(
      id: id,
      idTecnico: map['idTecnico'] ?? '',
      idCliente: map['idCliente'] ?? '',
      idGestor: map['idGestor'] ?? '', // ADICIONADO
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
      'idGestor': idGestor, // ADICIONADO
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
      'idGestor': idGestor, // ADICIONADO
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
      idGestor: idGestor, // ADICIONADO
      dataHora: dataHora,
      observacao: observacao,
      status: status,
      ativo: ativo,
    );
  }
}