import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';

// Classe auxiliar para agrupar dados para a tela de listagem
class AgendamentoDetalhado {
  final Agendamento agendamento;
  final Cliente? cliente;
  final Tecnico? tecnico;

  AgendamentoDetalhado({
    required this.agendamento,
    this.cliente,
    this.tecnico,
  });
}
