// lib/dados/modelos/agendamento_model.dart
import '../../dominio/entidades/agendamento.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgendamentoModel {
  final String id;
  final String idTecnico;
  final String idCliente;
  final String idGestor;
  final DateTime dataHora;
  final String? observacao;
  final String status;
  final bool ativo;
  final String? lembreteNotificacao;
  final bool notificacaoEnviada;

  AgendamentoModel({
    required this.id,
    required this.idTecnico,
    required this.idCliente,
    required this.idGestor,
    required this.dataHora,
    this.observacao,
    required this.status,
    required this.ativo,
    this.lembreteNotificacao,
    required this.notificacaoEnviada,
  });

  factory AgendamentoModel.fromEntidade(Agendamento ag) {
    return AgendamentoModel(
      id: ag.id,
      idTecnico: ag.idTecnico,
      idCliente: ag.idCliente,
      idGestor: ag.idGestor,
      dataHora: ag.dataHora,
      observacao: ag.observacao,
      status: ag.status,
      ativo: ag.ativo,
      lembreteNotificacao: ag.lembreteNotificacao,
      notificacaoEnviada: ag.notificacaoEnviada,
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
      idGestor: map['idGestor'] ?? '',
      dataHora: parsedDate,
      observacao: map['observacao'],
      status: map['status'] ?? 'Pendente',
      ativo: map['ativo'] is bool ? map['ativo'] : (map['ativo'] == 1),
      lembreteNotificacao: map['lembreteNotificacao'],
      notificacaoEnviada: map['notificacaoEnviada'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idTecnico': idTecnico,
      'idCliente': idCliente,
      'idGestor': idGestor,
      'dataHora': Timestamp.fromDate(dataHora),
      'observacao': observacao,
      'status': status,
      'ativo': ativo,
      'lembreteNotificacao': lembreteNotificacao,
      'notificacaoEnviada': notificacaoEnviada,
    };
  }

  Map<String, dynamic> toMapForDb() {
    return {
      'id': id,
      'idTecnico': idTecnico,
      'idCliente': idCliente,
      'idGestor': idGestor,
      'dataHora': dataHora.toIso8601String(),
      'observacao': observacao,
      'status': status,
      'ativo': ativo ? 1 : 0,
      'lembreteNotificacao': lembreteNotificacao,
      'notificacaoEnviada': notificacaoEnviada ? 1 : 0,
    };
  }

  Agendamento toEntidade() {
    return Agendamento(
      id: id,
      idTecnico: idTecnico,
      idCliente: idCliente,
      idGestor: idGestor,
      dataHora: dataHora,
      observacao: observacao,
      status: status,
      ativo: ativo,
      lembreteNotificacao: lembreteNotificacao,
      notificacaoEnviada: notificacaoEnviada,
    );
  }
}
