// lib/dominio/entidades/agendamento.dart
class Agendamento {
  final String id;
  final String idTecnico;
  final String idCliente;
  final String idGestor;
  final DateTime dataHora;
  final String? observacao;
  final String status;
  final String? lembreteNotificacao;
  final bool notificacaoEnviada;

  Agendamento({
    required this.id,
    required this.idTecnico,
    required this.idCliente,
    required this.idGestor,
    required this.dataHora,
    this.observacao,
    this.status = 'Pendente',
    this.lembreteNotificacao,
    this.notificacaoEnviada = false,
  });
}
