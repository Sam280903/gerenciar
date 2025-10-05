// lib/dados/repositorios/forma_pagamento/forma_pagamento_repositorio_impl_sqlite.dart
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:gerenciar/dominio/interfaces/forma_pagamento_repositorio_interface.dart';
import '../../fontes_dados/sqlite/forma_pagamento_sqlite.dart';
import '../../modelos/forma_pagamento_model.dart';

class FormaPagamentoRepositorioImplSQLite
    implements FormaPagamentoRepositorioInterface {
  final FormaPagamentoSQLite _fonteSQLite = FormaPagamentoSQLite();

  @override
  Future<void> adicionar(FormaPagamento forma) async {
    final model = FormaPagamentoModel.fromEntidade(forma);
    await _fonteSQLite.adicionar(model);
  }

  @override
  Future<void> atualizar(FormaPagamento forma) async {
    final model = FormaPagamentoModel.fromEntidade(forma);
    await _fonteSQLite.atualizar(model);
  }

  @override
  Future<void> inativar(String id) async {
    await _fonteSQLite.inativar(id);
  }

  @override
  Future<void> reativar(String id) async {
    await _fonteSQLite.reativar(id);
  }

  @override
  Future<FormaPagamento?> buscarPorNome(String nome) async {
    final model = await _fonteSQLite.buscarPorNome(nome);
    return model?.toEntidade();
  }

  @override
  Future<FormaPagamento?> buscarPorId(String id) async {
    final model = await _fonteSQLite.buscarPorId(id);
    return model?.toEntidade();
  }

  // MÉTODO ALTERADO
  @override
  Future<List<FormaPagamento>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    final modelos = await _fonteSQLite.listarTodos(
        idGestor: idGestor, incluirInativos: incluirInativos);
    return modelos.map((m) => m.toEntidade()).toList();
  }
}