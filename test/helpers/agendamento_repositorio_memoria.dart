import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:gerenciar/dominio/interfaces/agendamento_repositorio_interface.dart';

class AgendamentoRepositorioMemoria implements AgendamentoRepositorioInterface {
  final _dados = <String, Agendamento>{};

  @override
  Future<bool> verificarDisponibilidade(
      String idTecnico, DateTime dataHora, {String? idExcluir}) async {
    return _dados.values.any((a) =>
        a.idTecnico == idTecnico &&
        a.dataHora == dataHora &&
        a.id != idExcluir);
  }

  @override
  Future<void> adicionar(Agendamento agendamento) async {
    _dados[agendamento.id] = agendamento;
  }

  @override
  Future<void> atualizar(Agendamento agendamento) async {
    _dados[agendamento.id] = agendamento;
  }

  @override
  Future<Agendamento?> buscarPorId(String id) async {
    return _dados[id];
  }

  @override
  Future<List<Agendamento>> listarTodos(
      {required String idGestor}) async {
    return _dados.values
        .where((a) => a.idGestor == idGestor)
        .toList();
  }
}
