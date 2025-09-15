import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/servicos/relatorio_servico.dart';
import 'package:gerenciar/dominio/interfaces/ordem_servico_repositorio_interface.dart';
import '../../fontes_dados/sqlite/ordem_servico_sqlite.dart';
import '../../modelos/ordem_servico_model.dart';

class OrdemServicoRepositorioImplSQLite
    implements OrdemServicoRepositorioInterface {
  final OrdemServicoSQLite _fonteSQLite = OrdemServicoSQLite();

  @override
  Future<void> reabrir({required String id, required String justificativa}) {
    return _fonteSQLite.reabrir(id: id, justificativa: justificativa);
  }

  @override
  Future<void> adicionar(OrdemServico ordem) async {
    final model = OrdemServicoModel.fromEntidade(ordem);
    await _fonteSQLite.adicionar(model);
  }

  @override
  Future<void> atualizar(OrdemServico ordem) async {
    final model = OrdemServicoModel.fromEntidade(ordem);
    await _fonteSQLite.atualizar(model);
  }

  @override
  Future<void> inativar(String id) async {
    await _fonteSQLite.inativar(id);
  }

  @override
  Future<OrdemServico?> buscarPorId(String id) async {
    final model = await _fonteSQLite.buscarPorId(id);
    return model?.toEntidade();
  }

  @override
  Future<List<OrdemServico>> listarTodos() async {
    final modelos = await _fonteSQLite.listarTodos();
    return modelos.map((m) => m.toEntidade()).toList();
  }

  @override
  Future<List<OrdemServico>> listarComFiltros(FiltrosRelatorio filtros) async {
    // Implementação simplificada para offline: retorna todos e a tela filtra.
    //print("Modo offline: retornando todas as OS para filtragem na UI.");
    return listarTodos();
  }
}
