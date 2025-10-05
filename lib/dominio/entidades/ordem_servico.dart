// lib/dominio/entidades/ordem_servico.dart
class OrdemServico {
  final String id;
  final String idTecnico;
  final String idCliente;
  final String idFormaPagamento;
  final String idGestor; // ADICIONADO
  final DateTime dataHoraInicio;
  final DateTime? dataHoraFim;
  final String descricao;
  final double valor;
  final String prioridade; // "Baixa", "Média", "Alta"
  final String status; // "Pendente", "Em Andamento", "Concluída", "Reaberta"
  final String? justificativaReabertura;
  final bool ativo;

  OrdemServico({
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
}