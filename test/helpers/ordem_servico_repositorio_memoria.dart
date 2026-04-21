import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/interfaces/ordem_servico_repositorio_interface.dart';
import 'package:gerenciar/servicos/relatorio_servico.dart';

class OrdemServicoRepositorioMemoria
    implements OrdemServicoRepositorioInterface {
  final _dados = <String, OrdemServico>{};

  @override
  Future<void> adicionar(OrdemServico ordem) async {
    _dados[ordem.id] = ordem;
  }

  @override
  Future<void> atualizar(OrdemServico ordem) async {
    _dados[ordem.id] = ordem;
  }

  @override
  Future<void> inativar(String id) async {
    final os = _dados[id];
    if (os == null) return;
    _dados[id] = OrdemServico(
      id: os.id,
      idTecnico: os.idTecnico,
      idCliente: os.idCliente,
      idFormaPagamento: os.idFormaPagamento,
      idGestor: os.idGestor,
      dataHoraInicio: os.dataHoraInicio,
      dataHoraFim: os.dataHoraFim,
      descricao: os.descricao,
      valor: os.valor,
      prioridade: os.prioridade,
      status: os.status,
      justificativaReabertura: os.justificativaReabertura,
      ativo: false,
    );
  }

  @override
  Future<void> reabrir(
      {required String id, required String justificativa}) async {
    final os = _dados[id];
    if (os == null) return;
    _dados[id] = OrdemServico(
      id: os.id,
      idTecnico: os.idTecnico,
      idCliente: os.idCliente,
      idFormaPagamento: os.idFormaPagamento,
      idGestor: os.idGestor,
      dataHoraInicio: os.dataHoraInicio,
      dataHoraFim: null,
      descricao: os.descricao,
      valor: os.valor,
      prioridade: os.prioridade,
      status: 'Reaberta',
      justificativaReabertura: justificativa,
      ativo: os.ativo,
    );
  }

  @override
  Future<OrdemServico?> buscarPorId(String id) async {
    return _dados[id];
  }

  @override
  Future<List<OrdemServico>> listarTodos({required String idGestor}) async {
    return _dados.values
        .where((os) => os.idGestor == idGestor && os.ativo)
        .toList();
  }

  @override
  Future<List<OrdemServico>> listarComFiltros(
      FiltrosRelatorio filtros, String idGestor) async {
    return _dados.values.where((os) {
      if (os.idGestor != idGestor) return false;
      if (filtros.idTecnico != null && os.idTecnico != filtros.idTecnico) {
        return false;
      }
      if (filtros.idCliente != null && os.idCliente != filtros.idCliente) {
        return false;
      }
      if (filtros.status != null &&
          filtros.status!.isNotEmpty &&
          !filtros.status!.contains(os.status)) {
        return false;
      }
      if (filtros.dataInicial != null &&
          os.dataHoraInicio.isBefore(filtros.dataInicial!)) {
        return false;
      }
      if (filtros.dataFinal != null &&
          os.dataHoraInicio.isAfter(filtros.dataFinal!)) {
        return false;
      }
      return true;
    }).toList();
  }
}
