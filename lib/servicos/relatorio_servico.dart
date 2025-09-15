// lib/servicos/relatorio_servico.dart

import 'package:gerenciar/dados/repositorios/ordem_servico/ordem_servico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/interfaces/ordem_servico_repositorio_interface.dart';

// Classe que define os parâmetros de filtro para o relatório.
class FiltrosRelatorio {
  final DateTime? dataInicial;
  final DateTime? dataFinal;
  final String? idTecnico;
  final String? idCliente;
  final List<String>?
      status; // Lista para múltiplos status (pendente, concluído, etc.)

  FiltrosRelatorio({
    this.dataInicial,
    this.dataFinal,
    this.idTecnico,
    this.idCliente,
    this.status,
  });
}

class RelatorioServico {
  // O serviço de relatório usa o repositório de ordens de serviço para buscar os dados.
  final OrdemServicoRepositorioInterface _ordemServicoRepositorio =
      OrdemServicoRepositorioAdaptativo();

  // Método principal que gera o relatório com base nos filtros.
  Future<List<OrdemServico>> gerarRelatorioOrdensServico(
      FiltrosRelatorio filtros) async {
    try {
      final ordens = await _ordemServicoRepositorio.listarComFiltros(filtros);
      return ordens;
    } catch (e) {
      //print('Erro ao gerar relatório: $e');
      // Lança a exceção para que a camada de apresentação possa tratá-la.
      throw Exception('Não foi possível gerar o relatório.');
    }
  }
}
