import '../entidades/agendamento.dart';

abstract class AgendamentoRepositorioInterface {
  Future<bool> verificarDisponibilidade(String idTecnico, DateTime dataHora);
  Future<void> adicionar(Agendamento agendamento);
  Future<void> atualizar(Agendamento agendamento);
  Future<void> inativar(String id);
  Future<void> reativar(String id);
  Future<Agendamento?> buscarPorId(String id);
  // MÉTODO ALTERADO
  Future<List<Agendamento>> listarTodos(
      {required String idGestor, bool incluirInativos = false});
}