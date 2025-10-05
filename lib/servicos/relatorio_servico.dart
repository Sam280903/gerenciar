// lib/servicos/relatorio_servico.dart

import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/ordem_servico/ordem_servico_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/buscar_cliente_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/buscar_tecnico_por_id.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico_detalhada.dart';
import 'package:gerenciar/dominio/interfaces/ordem_servico_repositorio_interface.dart';

class FiltrosRelatorio {
  final DateTime? dataInicial;
  final DateTime? dataFinal;
  final String? idTecnico;
  final String? idCliente;
  final List<String>? status;

  FiltrosRelatorio({
    this.dataInicial,
    this.dataFinal,
    this.idTecnico,
    this.idCliente,
    this.status,
  });
}

class RelatorioServico {
  final OrdemServicoRepositorioInterface _ordemServicoRepositorio =
      OrdemServicoRepositorioAdaptativo();
  final _clienteRepo = ClienteRepositorioAdaptativo();
  final _tecnicoRepo = TecnicoRepositorioAdaptativo();

  // MÉTODO ALTERADO
  Future<List<OrdemServicoDetalhada>> gerarRelatorioOrdensServico(
      FiltrosRelatorio filtros, String idGestor) async {
    try {
      final ordens =
          await _ordemServicoRepositorio.listarComFiltros(filtros, idGestor);
      final List<OrdemServicoDetalhada> detalhadas = [];

      for (final os in ordens) {
        // Não precisamos filtrar por gestor aqui, pois as OS já vieram filtradas
        final cliente =
            await BuscarClientePorId(_clienteRepo).executar(os.idCliente);
        final tecnico =
            await BuscarTecnicoPorId(_tecnicoRepo).executar(os.idTecnico);
        detalhadas.add(OrdemServicoDetalhada(
          os: os,
          cliente: cliente,
          tecnico: tecnico,
        ));
      }

      return detalhadas;
    } catch (e) {
      throw Exception('Não foi possível gerar o relatório.');
    }
  }
}