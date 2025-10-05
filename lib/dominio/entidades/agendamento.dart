class Agendamento {
  final String id;
  final String idTecnico;
  final String idCliente;
  final String idGestor; // ADICIONADO
  final DateTime dataHora;
  final String? observacao;
  final String status;
  final bool ativo;

  Agendamento({
    required this.id,
    required this.idTecnico,
    required this.idCliente,
    required this.idGestor, // ADICIONADO
    required this.dataHora,
    this.observacao,
    this.status = 'Pendente',
    required this.ativo,
  });
}