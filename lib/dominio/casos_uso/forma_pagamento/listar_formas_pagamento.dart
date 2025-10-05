// lib/dominio/casos_uso/forma_pagamento/listar_formas_pagamento.dart
import '../../entidades/forma_pagamento.dart';
import '../../interfaces/forma_pagamento_repositorio_interface.dart';

class ListarFormasPagamento {
  final FormaPagamentoRepositorioInterface repositorio;
  ListarFormasPagamento(this.repositorio);
  Future<List<FormaPagamento>> executar(
      {required String idGestor, bool incluirInativos = false}) async {
    return await repositorio.listarTodos(
        idGestor: idGestor, incluirInativos: incluirInativos);
  }
}
