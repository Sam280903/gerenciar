import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gerenciar/servicos/relatorio_servico.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/interfaces/ordem_servico_repositorio_interface.dart';
import 'ordem_servico_repositorio_impl.dart';
import 'ordem_servico_repositorio_impl_sqlite.dart';

class OrdemServicoRepositorioAdaptativo
    implements OrdemServicoRepositorioInterface {
  final _repositorioOnline = OrdemServicoRepositorioImpl();
  final _repositorioOffline = OrdemServicoRepositorioImplSQLite();

  Future<bool> _temConexao() async {
    final List<ConnectivityResult> status =
        await Connectivity().checkConnectivity();
    return !status.contains(ConnectivityResult.none);
  }

  Future<OrdemServicoRepositorioInterface> _escolherRepositorio() async {
    return await _temConexao() ? _repositorioOnline : _repositorioOffline;
  }

  @override
  Future<void> reabrir(
      {required String id, required String justificativa}) async {
    final repo = await _escolherRepositorio();
    await repo.reabrir(id: id, justificativa: justificativa);
  }

  @override
  Future<void> adicionar(OrdemServico ordem) async {
    final repo = await _escolherRepositorio();
    await repo.adicionar(ordem);
  }

  @override
  Future<void> atualizar(OrdemServico ordem) async {
    final repo = await _escolherRepositorio();
    await repo.atualizar(ordem);
  }

  @override
  Future<void> inativar(String id) async {
    final repo = await _escolherRepositorio();
    await repo.inativar(id);
  }

  @override
  Future<OrdemServico?> buscarPorId(String id) async {
    final repo = await _escolherRepositorio();
    return await repo.buscarPorId(id);
  }

  // MÉTODO ALTERADO
  @override
  Future<List<OrdemServico>> listarTodos({required String idGestor}) async {
    final repo = await _escolherRepositorio();
    return await repo.listarTodos(idGestor: idGestor);
  }

  // MÉTODO ALTERADO
  @override
  Future<List<OrdemServico>> listarComFiltros(
      FiltrosRelatorio filtros, String idGestor) async {
    final repo = await _escolherRepositorio();
    return repo.listarComFiltros(filtros, idGestor);
  }
}