// lib/dados/repositorios/agendamento/agendamento_repositorio_adaptativo.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:gerenciar/dominio/interfaces/agendamento_repositorio_interface.dart';
import 'agendamento_repositorio_impl.dart';
import 'agendamento_repositorio_impl_sqlite.dart';

class AgendamentoRepositorioAdaptativo
    implements AgendamentoRepositorioInterface {
  final _firebase = AgendamentoRepositorioImpl();
  final _sqlite = AgendamentoRepositorioImplSQLite();

  Future<bool> _temConexao() async {
    final List<ConnectivityResult> status =
        await Connectivity().checkConnectivity();
    // Verifica se a lista de conexões NÃO contém o status 'none'.
    return !status.contains(ConnectivityResult.none); // <-- CORREÇÃO AQUI
  }

  // O método _escolherRepositorio agora é privado, pois só é usado aqui dentro.
  Future<AgendamentoRepositorioInterface> _escolherRepositorio() async {
    return await _temConexao() ? _firebase : _sqlite;
  }

  // MÉTODO NOVO IMPLEMENTADO
  @override
  Future<bool> verificarDisponibilidade(
      String idTecnico, DateTime dataHora) async {
    // A lógica é a mesma: escolhe o repositório correto (online/offline)
    // e repassa a chamada para ele.
    final repo = await _escolherRepositorio();
    return repo.verificarDisponibilidade(idTecnico, dataHora);
  }

  @override
  Future<void> adicionar(Agendamento agendamento) async {
    final repo = await _escolherRepositorio();
    await repo.adicionar(agendamento);
  }

  @override
  Future<void> atualizar(Agendamento agendamento) async {
    final repo = await _escolherRepositorio();
    await repo.atualizar(agendamento);
  }

  @override
  Future<void> inativar(String id) async {
    final repo = await _escolherRepositorio();
    await repo.inativar(id);
  }

  @override
  Future<Agendamento?> buscarPorId(String id) async {
    final repo = await _escolherRepositorio();
    return await repo.buscarPorId(id);
  }

  @override
  Future<List<Agendamento>> listarTodos() async {
    final repo = await _escolherRepositorio();
    return await repo.listarTodos();
  }
}
