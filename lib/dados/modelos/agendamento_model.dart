import '../../dominio/entidades/agendamento.dart';

class AgendamentoModel {
  final String id;
  final String idTecnico;
  final String idCliente;
  final DateTime dataHora;
  final String? observacao;
  final bool ativo;

  AgendamentoModel({
    required this.id,
    required this.idTecnico,
    required this.idCliente,
    required this.dataHora,
    this.observacao,
    required this.ativo,
  });

  factory AgendamentoModel.fromEntidade(Agendamento ag) {
    return AgendamentoModel(
      id: ag.id,
      idTecnico: ag.idTecnico,
      idCliente: ag.idCliente,
      dataHora: ag.dataHora,
      observacao: ag.observacao,
      ativo: ag.ativo,
    );
  }

  factory AgendamentoModel.fromMap(Map<String, dynamic> map, String id) {
    return AgendamentoModel(
      id: id,
      idTecnico: map['idTecnico'],
      idCliente: map['idCliente'],
      dataHora: DateTime.parse(map['dataHora']),
      observacao: map['observacao'],
      ativo: map['ativo'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'idTecnico': idTecnico,
      'idCliente': idCliente,
      'dataHora': dataHora.toIso8601String(),
      'observacao': observacao,
      'ativo': ativo,
    };
  }

  Agendamento toEntidade() {
    return Agendamento(
      id: id,
      idTecnico: idTecnico,
      idCliente: idCliente,
      dataHora: dataHora,
      observacao: observacao,
      ativo: ativo,
    );
  }
}
