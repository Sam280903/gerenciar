import '../entidades/agendamento.dart';

abstract class AgendamentoRepositorioInterface {
  Future<bool> verificarDisponibilidade(String idTecnico, DateTime dataHora);
  Future<void> adicionar(Agendamento agendamento);
  Future<void> atualizar(Agendamento agendamento);
  Future<Agendamento?> buscarPorId(String id);
  Future<List<Agendamento>> listarTodos({required String idGestor});
}