import '../../entidades/ordem_servico.dart';
import '../../interfaces/ordem_servico_repositorio_interface.dart';

class ListarOrdensServico {
  final OrdemServicoRepositorioInterface repositorio;

  ListarOrdensServico(this.repositorio);

  Future<List<OrdemServico>> executar() async {
    return await repositorio.listarTodos();
  }
}
