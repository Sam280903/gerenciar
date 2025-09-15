// lib/dados/repositorios/tecnico/tecnico_repositorio_impl.dart

import 'package:gerenciar/dominio/interfaces/tecnico_repositorio_interface.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import '../../modelos/tecnico_model.dart';
import '../../fontes_dados/firebase/tecnico_firebase.dart';

class TecnicoRepositorioImpl implements TecnicoRepositorioInterface {
  final TecnicoFirebase _fonteFirebase = TecnicoFirebase();

  @override
  Future<void> adicionar(Tecnico tecnico) async {
    final model = TecnicoModel.fromEntidade(tecnico);
    await _fonteFirebase.adicionarTecnico(model);
  }

  @override
  Future<void> atualizar(Tecnico tecnico) async {
    final model = TecnicoModel.fromEntidade(tecnico);
    await _fonteFirebase.atualizarTecnico(model);
  }

  @override
  Future<void> inativar(String id) async {
    await _fonteFirebase.inativarTecnico(id);
  }

  // CORREÇÃO: Implementação do método 'reativar'
  @override
  Future<void> reativar(String id) async {
    await _fonteFirebase.reativarTecnico(id);
  }

  @override
  Future<Tecnico?> buscarPorId(String id) async {
    final model = await _fonteFirebase.buscarPorId(id);
    return model?.toEntidade();
  }

  // CORREÇÃO: Assinatura do método 'listarTodos' corrigida
  @override
  Future<List<Tecnico>> listarTodos({bool incluirInativos = false}) async {
    final modelos =
        await _fonteFirebase.listarTodos(incluirInativos: incluirInativos);
    return modelos.map((m) => m.toEntidade()).toList();
  }
}
