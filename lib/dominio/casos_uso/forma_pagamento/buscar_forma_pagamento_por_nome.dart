// lib/dominio/casos_uso/forma_pagamento/buscar_forma_pagamento_por_nome.dart
import '../../entidades/forma_pagamento.dart';
import '../../interfaces/forma_pagamento_repositorio_interface.dart';

class BuscarFormaPagamentoPorNome {
  final FormaPagamentoRepositorioInterface repositorio;
  BuscarFormaPagamentoPorNome(this.repositorio);
  Future<FormaPagamento?> executar(String nome) async {
    return await repositorio.buscarPorNome(nome);
  }
}
