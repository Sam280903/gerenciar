// lib/dominio/casos_uso/ordem_servico/reabrir_ordem_servico.dart

import '../../interfaces/ordem_servico_repositorio_interface.dart';

class ReabrirOrdemServico {
  final OrdemServicoRepositorioInterface repositorio;

  ReabrirOrdemServico(this.repositorio);

  Future<void> executar(
      {required String id, required String justificativa}) async {
    // Validações de negócio
    if (id.isEmpty) {
      throw Exception('O ID da Ordem de Serviço é obrigatório.');
    }
    if (justificativa.isEmpty) {
      throw Exception('A justificativa para a reabertura é obrigatória.');
    }

    // Chama o método do repositório para efetuar a reabertura
    await repositorio.reabrir(id: id, justificativa: justificativa);
  }
}
