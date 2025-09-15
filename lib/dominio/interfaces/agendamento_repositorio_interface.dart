// lib/dominio/interfaces/agendamento_repositorio_interface.dart

import '../entidades/agendamento.dart';

abstract class AgendamentoRepositorioInterface {
  // Novo método para verificar se já existe um agendamento
  Future<bool> verificarDisponibilidade(String idTecnico, DateTime dataHora);

  Future<void> adicionar(Agendamento agendamento);
  Future<void> atualizar(Agendamento agendamento);
  Future<void> inativar(String id);
  Future<Agendamento?> buscarPorId(String id);
  Future<List<Agendamento>> listarTodos();
}
