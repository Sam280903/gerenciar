// lib/dominio/casos_uso/ordem_servico/cancelar_ordem_servico.dart

import '../../interfaces/ordem_servico_repositorio_interface.dart';

class CancelarOrdemServico {
  final OrdemServicoRepositorioInterface repositorio;

  CancelarOrdemServico(this.repositorio);

  Future<void> executar(
      {required String id, required String justificativa}) async {
    if (id.isEmpty) {
      throw Exception('O ID da Ordem de Serviço é obrigatório.');
    }
    if (justificativa.isEmpty) {
      throw Exception('A justificativa para o cancelamento é obrigatória.');
    }

    await repositorio.cancelar(id: id, justificativa: justificativa);
  }
}
