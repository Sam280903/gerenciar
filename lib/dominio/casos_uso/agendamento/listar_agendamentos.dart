import '../../entidades/agendamento.dart';
import '../../interfaces/agendamento_repositorio_interface.dart';

class ListarAgendamentos {
  final AgendamentoRepositorioInterface repositorio;

  ListarAgendamentos(this.repositorio);

  Future<List<Agendamento>> executar() async {
    return await repositorio.listarTodos();
  }
}
