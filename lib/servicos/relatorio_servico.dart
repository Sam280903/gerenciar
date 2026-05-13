// lib/servicos/relatorio_servico.dart

import 'package:flutter/foundation.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/ordem_servico/ordem_servico_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico_detalhada.dart';
import 'package:gerenciar/dominio/interfaces/cliente_repositorio_interface.dart';
import 'package:gerenciar/dominio/interfaces/ordem_servico_repositorio_interface.dart';
import 'package:gerenciar/dominio/interfaces/tecnico_repositorio_interface.dart';

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
  final OrdemServicoRepositorioInterface _ordemServicoRepositorio;
  final ClienteRepositorioInterface _clienteRepo;
  final TecnicoRepositorioInterface _tecnicoRepo;

  RelatorioServico({
    OrdemServicoRepositorioInterface? ordemServicoRepositorio,
    ClienteRepositorioInterface? clienteRepo,
    TecnicoRepositorioInterface? tecnicoRepo,
  })  : _ordemServicoRepositorio = ordemServicoRepositorio ?? OrdemServicoRepositorioAdaptativo(),
        _clienteRepo = clienteRepo ?? ClienteRepositorioAdaptativo(),
        _tecnicoRepo = tecnicoRepo ?? TecnicoRepositorioAdaptativo();

  Future<List<OrdemServicoDetalhada>> gerarRelatorioOrdensServico(
      FiltrosRelatorio filtros, String idGestor) async {
    try {
      final ordens =
          await _ordemServicoRepositorio.listarComFiltros(filtros, idGestor);

      // Busca TODOS os clientes e técnicos uma única vez (não N+1)
      final clientes = await _clienteRepo.listarTodos(idGestor: idGestor);
      final tecnicos = await _tecnicoRepo.listarTodos(idGestor: idGestor);

      // Cria mapas para lookup rápido em memória
      final clientesMap = {for (var c in clientes) c.id: c};
      final tecnicosMap = {for (var t in tecnicos) t.id: t};

      // Monta a lista detalhada usando os mapas
      final detalhadas = ordens.map((os) {
        return OrdemServicoDetalhada(
          os: os,
          cliente: clientesMap[os.idCliente],
          tecnico: tecnicosMap[os.idTecnico],
        );
      }).toList();

      return detalhadas;
    } catch (e) {
      debugPrint('Erro ao gerar relatório: $e');
      throw Exception('Não foi possível gerar o relatório.');
    }
  }
}