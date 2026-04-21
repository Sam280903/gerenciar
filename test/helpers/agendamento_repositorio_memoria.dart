import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:gerenciar/dominio/interfaces/agendamento_repositorio_interface.dart';

class AgendamentoRepositorioMemoria implements AgendamentoRepositorioInterface {
  final _dados = <String, Agendamento>{};

  @override
  Future<bool> verificarDisponibilidade(
      String idTecnico, DateTime dataHora) async {
    return _dados.values.any((a) =>
        a.ativo && a.idTecnico == idTecnico && a.dataHora == dataHora);
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
  Future<void> inativar(String id) async {
    final a = _dados[id];
    if (a == null) return;
    _dados[id] = Agendamento(
      id: a.id,
      idTecnico: a.idTecnico,
      idCliente: a.idCliente,
      idGestor: a.idGestor,
      dataHora: a.dataHora,
      observacao: a.observacao,
      status: a.status,
      ativo: false,
      lembreteNotificacao: a.lembreteNotificacao,
      notificacaoEnviada: a.notificacaoEnviada,
    );
  }

  @override
  Future<void> reativar(String id) async {
    final a = _dados[id];
    if (a == null) return;
    _dados[id] = Agendamento(
      id: a.id,
      idTecnico: a.idTecnico,
      idCliente: a.idCliente,
      idGestor: a.idGestor,
      dataHora: a.dataHora,
      observacao: a.observacao,
      status: a.status,
      ativo: true,
      lembreteNotificacao: a.lembreteNotificacao,
      notificacaoEnviada: a.notificacaoEnviada,
    );
  }

  @override
  Future<Agendamento?> buscarPorId(String id) async {
    return _dados[id];
  }

  @override
  Future<List<Agendamento>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    return _dados.values
        .where((a) =>
            a.idGestor == idGestor && (incluirInativos || a.ativo))
        .toList();
  }
}
