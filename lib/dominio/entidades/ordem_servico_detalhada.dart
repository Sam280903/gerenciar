import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';

// Classe auxiliar para agrupar os dados para a tela
class OrdemServicoDetalhada {
  final OrdemServico os;
  final Cliente? cliente;
  final Tecnico? tecnico;

  OrdemServicoDetalhada({
    required this.os,
    this.cliente,
    this.tecnico,
  });
}
