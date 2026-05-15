import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gerenciar/dados/fontes_dados/sqlite/agendamento_sqlite.dart';
import 'package:gerenciar/dados/modelos/agendamento_model.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:gerenciar/dominio/interfaces/agendamento_repositorio_interface.dart';
import 'agendamento_repositorio_impl.dart';
import 'agendamento_repositorio_impl_sqlite.dart';

class AgendamentoRepositorioAdaptativo
    implements AgendamentoRepositorioInterface {
  final _firebase = AgendamentoRepositorioImpl();
  final _sqlite = AgendamentoRepositorioImplSQLite();
  final _sqliteFonte = AgendamentoSQLite();

  Future<bool> _temConexao() async {
    final List<ConnectivityResult> status =
        await Connectivity().checkConnectivity();
    return !status.contains(ConnectivityResult.none);
  }

  Future<AgendamentoRepositorioInterface> _escolherRepositorio() async {
    return await _temConexao() ? _firebase : _sqlite;
  }

  @override
  Future<bool> verificarDisponibilidade(String idTecnico, DateTime dataHora, {String? idExcluir}) async {
    final repo = await _escolherRepositorio();
    return repo.verificarDisponibilidade(idTecnico, dataHora, idExcluir: idExcluir);
  }

  @override
  Future<void> adicionar(Agendamento agendamento) async {
    if (await _temConexao()) {
      // Online: salva no Firebase e espelha no SQLite
      await _firebase.adicionar(agendamento);
      final model = AgendamentoModel.fromEntidade(agendamento);
      final sqlite = _sqliteFonte;
      await sqlite.adicionar(model);
      await sqlite.marcarComoSincronizado(agendamento.id);
    } else {
      // Offline: salva só no SQLite (será sincronizado depois)
      await _sqlite.adicionar(agendamento);
    }
  }

  @override
  Future<void> atualizar(Agendamento agendamento) async {
    if (await _temConexao()) {
      await _firebase.atualizar(agendamento);
      // Espelha no SQLite já marcado como sincronizado para evitar
      // que a sincronização suba o dado antigo de volta ao Firebase
      final model = AgendamentoModel.fromEntidade(agendamento);
      final sqlite = _sqliteFonte;
      await sqlite.atualizar(model);
      await sqlite.marcarComoSincronizado(agendamento.id);
    } else {
      await _sqlite.atualizar(agendamento);
    }
  }

  @override
  Future<Agendamento?> buscarPorId(String id) async {
    final repo = await _escolherRepositorio();
    return await repo.buscarPorId(id);
  }

  @override
  Future<List<Agendamento>> listarTodos({required String idGestor}) async {
    final repo = await _escolherRepositorio();
    return await repo.listarTodos(idGestor: idGestor);
  }
}