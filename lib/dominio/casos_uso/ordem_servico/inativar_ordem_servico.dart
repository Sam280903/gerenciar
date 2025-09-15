import '../../interfaces/ordem_servico_repositorio_interface.dart';

class InativarOrdemServico {
  final OrdemServicoRepositorioInterface repositorio;

  InativarOrdemServico(this.repositorio);

  Future<void> executar(String id) async {
    await repositorio.inativar(id);
  }
}
