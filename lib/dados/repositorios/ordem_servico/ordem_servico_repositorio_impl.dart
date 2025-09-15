import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/servicos/relatorio_servico.dart';
import 'package:gerenciar/dominio/interfaces/ordem_servico_repositorio_interface.dart';
import '../../fontes_dados/firebase/ordem_servico_firebase.dart';
import '../../modelos/ordem_servico_model.dart';

class OrdemServicoRepositorioImpl implements OrdemServicoRepositorioInterface {
  final OrdemServicoFirebase _fonteFirebase = OrdemServicoFirebase();

  @override
  Future<void> reabrir({required String id, required String justificativa}) {
    return _fonteFirebase.reabrir(id: id, justificativa: justificativa);
  }

  @override
  Future<void> adicionar(OrdemServico ordem) async {
    final model = OrdemServicoModel.fromEntidade(ordem);
    await _fonteFirebase.adicionar(model);
  }

  @override
  Future<void> atualizar(OrdemServico ordem) async {
    final model = OrdemServicoModel.fromEntidade(ordem);
    await _fonteFirebase.atualizar(model);
  }

  @override
  Future<void> inativar(String id) async {
    await _fonteFirebase.inativar(id);
  }

  @override
  Future<OrdemServico?> buscarPorId(String id) async {
    final model = await _fonteFirebase.buscarPorId(id);
    return model?.toEntidade();
  }

  @override
  Future<List<OrdemServico>> listarTodos() async {
    final modelos = await _fonteFirebase.listarTodos();
    return modelos.map((m) => m.toEntidade()).toList();
  }

  @override
  Future<List<OrdemServico>> listarComFiltros(FiltrosRelatorio filtros) async {
    final modelos = await _fonteFirebase.listarComFiltros(filtros);
    return modelos.map((m) => m.toEntidade()).toList();
  }
}
