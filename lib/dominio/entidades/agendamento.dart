class Agendamento {
  final String id;
  final String idTecnico;
  final String idCliente;
  final DateTime dataHora;
  final String? observacao;
  final bool ativo;

  Agendamento({
    required this.id,
    required this.idTecnico,
    required this.idCliente,
    required this.dataHora,
    this.observacao,
    required this.ativo,
  });
}
