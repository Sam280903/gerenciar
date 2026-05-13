import '../../entidades/ordem_servico.dart';
import '../../interfaces/ordem_servico_repositorio_interface.dart';

class ListarOrdensServico {
  final OrdemServicoRepositorioInterface repositorio;

  ListarOrdensServico(this.repositorio);

  Future<List<OrdemServico>> executar({required String idGestor}) async {
    final ordens = await repositorio.listarTodos(idGestor: idGestor);
    ordens.sort((a, b) => a.descricao.compareTo(b.descricao));
    return ordens;
  }
}
