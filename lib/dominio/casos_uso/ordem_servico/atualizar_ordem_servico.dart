import '../../entidades/ordem_servico.dart';
import '../../interfaces/ordem_servico_repositorio_interface.dart';

class AtualizarOrdemServico {
  final OrdemServicoRepositorioInterface repositorio;

  AtualizarOrdemServico(this.repositorio);

  Future<void> executar(OrdemServico ordem) async {
    await repositorio.atualizar(ordem);
  }
}
