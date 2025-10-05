// lib/dados/modelos/ordem_servico_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../dominio/entidades/ordem_servico.dart';

class OrdemServicoModel {
  final String id;
  final String idTecnico;
  final String idCliente;
  final String idFormaPagamento;
  final String idGestor; // ADICIONADO
  final DateTime dataHoraInicio;
  final DateTime? dataHoraFim;
  final String descricao;
  final double valor;
  final String prioridade;
  final String status;
  final String? justificativaReabertura;
  final bool ativo;

  OrdemServicoModel({
    required this.id,
    required this.idTecnico,
    required this.idCliente,
    required this.idFormaPagamento,
    required this.idGestor, // ADICIONADO
    required this.dataHoraInicio,
    this.dataHoraFim,
    required this.descricao,
    required this.valor,
    required this.prioridade,
    required this.status,
    this.justificativaReabertura,
    required this.ativo,
  });

  factory OrdemServicoModel.fromEntidade(OrdemServico os) {
    return OrdemServicoModel(
      id: os.id,
      idTecnico: os.idTecnico,
      idCliente: os.idCliente,
      idFormaPagamento: os.idFormaPagamento,
      idGestor: os.idGestor, // ADICIONADO
      dataHoraInicio: os.dataHoraInicio,
      dataHoraFim: os.dataHoraFim,
      descricao: os.descricao,
      valor: os.valor,
      prioridade: os.prioridade,
      status: os.status,
      justificativaReabertura: os.justificativaReabertura,
      ativo: os.ativo,
    );
  }

  factory OrdemServicoModel.fromMap(Map<String, dynamic> map, String id) {
    return OrdemServicoModel(
      id: id,
      idTecnico: map['idTecnico'] ?? '',
      idCliente: map['idCliente'] ?? '',
      idFormaPagamento: map['idFormaPagamento'] ?? '',
      idGestor: map['idGestor'] ?? '', // ADICIONADO
      dataHoraInicio: (map['dataHoraInicio'] as Timestamp).toDate(),
      dataHoraFim: map['dataHoraFim'] != null
          ? (map['dataHoraFim'] as Timestamp).toDate()
          : null,
      descricao: map['descricao'] ?? '',
      valor: (map['valor'] ?? 0.0).toDouble(),
      prioridade: map['prioridade'] ?? 'Baixa',
      status: map['status'] ?? 'Pendente',
      justificativaReabertura: map['justificativaReabertura'],
      ativo: map['ativo'] ?? true,
    );
  }

  factory OrdemServicoModel.fromDbMap(Map<String, dynamic> map) {
    return OrdemServicoModel(
      id: map['id'],
      idTecnico: map['idTecnico'],
      idCliente: map['idCliente'],
      idFormaPagamento: map['idFormaPagamento'],
      idGestor: map['idGestor'], // ADICIONADO
      dataHoraInicio: DateTime.parse(map['dataHoraInicio']),
      dataHoraFim: map['dataHoraFim'] != null
          ? DateTime.parse(map['dataHoraFim'])
          : null,
      descricao: map['descricao'],
      valor: map['valor'],
      prioridade: map['prioridade'],
      status: map['status'],
      ativo: map['ativo'] == 1,
      justificativaReabertura: map['justificativaReabertura'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idTecnico': idTecnico,
      'idCliente': idCliente,
      'idFormaPagamento': idFormaPagamento,
      'idGestor': idGestor, // ADICIONADO
      'dataHoraInicio': Timestamp.fromDate(dataHoraInicio),
      'dataHoraFim':
          dataHoraFim != null ? Timestamp.fromDate(dataHoraFim!) : null,
      'descricao': descricao,
      'valor': valor,
      'prioridade': prioridade,
      'status': status,
      'justificativaReabertura': justificativaReabertura,
      'ativo': ativo,
    };
  }

  Map<String, dynamic> toMapForDb() {
    return {
      'id': id,
      'idTecnico': idTecnico,
      'idCliente': idCliente,
      'idFormaPagamento': idFormaPagamento,
      'idGestor': idGestor, // ADICIONADO
      'dataHoraInicio': dataHoraInicio.toIso8601String(),
      'dataHoraFim': dataHoraFim?.toIso8601String(),
      'descricao': descricao,
      'valor': valor,
      'prioridade': prioridade,
      'status': status,
      'justificativaReabertura': justificativaReabertura,
      'ativo': ativo ? 1 : 0,
    };
  }

  OrdemServico toEntidade() {
    return OrdemServico(
      id: id,
      idTecnico: idTecnico,
      idCliente: idCliente,
      idFormaPagamento: idFormaPagamento,
      idGestor: idGestor, // ADICIONADO
      dataHoraInicio: dataHoraInicio,
      dataHoraFim: dataHoraFim,
      descricao: descricao,
      valor: valor,
      prioridade: prioridade,
      status: status,
      justificativaReabertura: justificativaReabertura,
      ativo: ativo,
    );
  }
}
