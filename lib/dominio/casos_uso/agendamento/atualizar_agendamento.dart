import '../../entidades/agendamento.dart';
import '../../interfaces/agendamento_repositorio_interface.dart';

class AtualizarAgendamento {
  final AgendamentoRepositorioInterface repositorio;

  AtualizarAgendamento(this.repositorio);

  Future<void> executar(Agendamento agendamento) async {
    await repositorio.atualizar(agendamento);
  }
}
