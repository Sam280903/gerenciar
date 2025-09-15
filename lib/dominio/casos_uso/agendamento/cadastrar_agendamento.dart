// lib/dominio/casos_uso/agendamento/cadastrar_agendamento.dart

import '../../entidades/agendamento.dart';
import '../../interfaces/agendamento_repositorio_interface.dart';

class CadastrarAgendamento {
  final AgendamentoRepositorioInterface repositorio;

  CadastrarAgendamento(this.repositorio);

  Future<void> executar(Agendamento agendamento) async {
    // 1. Verifica se o horário está disponível ANTES de tentar salvar.
    final bool ocupado = await repositorio.verificarDisponibilidade(
      agendamento.idTecnico,
      agendamento.dataHora,
    );

    // 2. Se estiver ocupado, lança uma exceção com uma mensagem clara.
    if (ocupado) {
      throw Exception('Este técnico já possui um atendimento neste horário.');
    }

    // 3. Se estiver livre, prossegue com a operação de adicionar.
    await repositorio.adicionar(agendamento);
  }
}
