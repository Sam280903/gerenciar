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
  Future<void> cancelar({required String id, required String justificativa}) {
    return _fonteSQLite.cancelar(id: id, justificativa: justificativa);
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

  // MÉTODO ALTERADO
  @override
  Future<List<OrdemServico>> listarTodos({required String idGestor}) async {
    final modelos = await _fonteSQLite.listarTodos(idGestor: idGestor);
    return modelos.map((m) => m.toEntidade()).toList();
  }

  // MÉTODO ALTERADO
  @override
  Future<List<OrdemServico>> listarComFiltros(
      FiltrosRelatorio filtros, String idGestor) async {
    var resultado = await listarTodos(idGestor: idGestor);

    // Aplicar filtros em código (modo offline)
    if (filtros.idTecnico != null && filtros.idTecnico!.isNotEmpty) {
      resultado = resultado.where((os) => os.idTecnico == filtros.idTecnico).toList();
    }
    if (filtros.idCliente != null && filtros.idCliente!.isNotEmpty) {
      resultado = resultado.where((os) => os.idCliente == filtros.idCliente).toList();
    }
    if (filtros.status != null && filtros.status!.isNotEmpty) {
      resultado = resultado.where((os) => filtros.status!.contains(os.status)).toList();
    }
    if (filtros.dataInicial != null) {
      resultado = resultado
          .where((os) => os.dataHoraInicio.isAfter(filtros.dataInicial!))
          .toList();
    }
    if (filtros.dataFinal != null) {
      final dataFinalAjustada = filtros.dataFinal!.add(const Duration(hours: 23, minutes: 59, seconds: 59));
      resultado = resultado
          .where((os) => os.dataHoraInicio.isBefore(dataFinalAjustada))
          .toList();
    }

    return resultado;
  }
}