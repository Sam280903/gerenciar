// lib/dominio/interfaces/ordem_servico_repositorio_interface.dart
import 'package:gerenciar/servicos/relatorio_servico.dart';
import '../entidades/ordem_servico.dart';

abstract class OrdemServicoRepositorioInterface {
  // MÉTODO ALTERADO
  Future<List<OrdemServico>> listarComFiltros(
      FiltrosRelatorio filtros, String idGestor);
  Future<void> reabrir({required String id, required String justificativa});
  Future<void> cancelar({required String id, required String justificativa});
  Future<void> adicionar(OrdemServico ordem);
  Future<void> atualizar(OrdemServico ordem);
  Future<void> inativar(String id);
  Future<OrdemServico?> buscarPorId(String id);
  // MÉTODO ALTERADO
  Future<List<OrdemServico>> listarTodos({required String idGestor});
}
