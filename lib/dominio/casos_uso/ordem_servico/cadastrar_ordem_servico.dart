import '../../entidades/ordem_servico.dart';
import '../../interfaces/ordem_servico_repositorio_interface.dart';

class CadastrarOrdemServico {
  final OrdemServicoRepositorioInterface repositorio;

  CadastrarOrdemServico(this.repositorio);

  Future<void> executar(OrdemServico ordem) async {
    await repositorio.adicionar(ordem);
  }
}
