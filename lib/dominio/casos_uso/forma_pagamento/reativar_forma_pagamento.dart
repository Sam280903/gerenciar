// lib/dominio/casos_uso/forma_pagamento/reativar_forma_pagamento.dart
import '../../interfaces/forma_pagamento_repositorio_interface.dart';

class ReativarFormaPagamento {
  final FormaPagamentoRepositorioInterface repositorio;
  ReativarFormaPagamento(this.repositorio);
  Future<void> executar(String id) async {
    if (id.isEmpty) {
      throw Exception('ID da forma de pagamento é obrigatório.');
    }
    await repositorio.reativar(id);
  }
}
