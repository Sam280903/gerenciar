// lib/dados/repositorios/forma_pagamento/forma_pagamento_repositorio_impl.dart
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:gerenciar/dominio/interfaces/forma_pagamento_repositorio_interface.dart';
import '../../fontes_dados/firebase/forma_pagamento_firebase.dart';
import '../../modelos/forma_pagamento_model.dart';

class FormaPagamentoRepositorioImpl
    implements FormaPagamentoRepositorioInterface {
  final FormaPagamentoFirebase _fonteFirebase = FormaPagamentoFirebase();

  @override
  Future<void> adicionar(FormaPagamento forma) async {
    final model = FormaPagamentoModel.fromEntidade(forma);
    await _fonteFirebase.adicionar(model);
  }

  @override
  Future<void> atualizar(FormaPagamento forma) async {
    final model = FormaPagamentoModel.fromEntidade(forma);
    await _fonteFirebase.atualizar(model);
  }

  @override
  Future<void> inativar(String id) async {
    await _fonteFirebase.inativar(id);
  }

  @override
  Future<void> reativar(String id) async {
    await _fonteFirebase.reativar(id);
  }

  @override
  Future<FormaPagamento?> buscarPorNome(String nome) async {
    final model = await _fonteFirebase.buscarPorNome(nome);
    return model?.toEntidade();
  }

  @override
  Future<FormaPagamento?> buscarPorId(String id) async {
    final model = await _fonteFirebase.buscarPorId(id);
    return model?.toEntidade();
  }

  // MÉTODO ALTERADO
  @override
  Future<List<FormaPagamento>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    final modelos = await _fonteFirebase.listarTodos(
        idGestor: idGestor, incluirInativos: incluirInativos);
    return modelos.map((m) => m.toEntidade()).toList();
  }
}