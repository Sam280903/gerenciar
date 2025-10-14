// lib/dominio/entidades/agendamento.dart
class Agendamento {
  final String id;
  final String idTecnico;
  final String idCliente;
  final String idGestor;
  final DateTime dataHora;
  final String? observacao;
  final String status;
  final bool ativo;
  final String? lembreteNotificacao; // NOVO CAMPO
  final bool notificacaoEnviada; // NOVO CAMPO

  Agendamento({
    required this.id,
    required this.idTecnico,
    required this.idCliente,
    required this.idGestor,
    required this.dataHora,
    this.observacao,
    this.status = 'Pendente',
    required this.ativo,
    this.lembreteNotificacao, // NOVO CAMPO
    this.notificacaoEnviada = false, // NOVO CAMPO
  });
}
