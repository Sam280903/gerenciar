import '../../entidades/agendamento.dart';
import '../../interfaces/agendamento_repositorio_interface.dart';

class ListarAgendamentos {
  final AgendamentoRepositorioInterface repositorio;

  ListarAgendamentos(this.repositorio);

  Future<List<Agendamento>> executar(
      {required String idGestor, bool incluirInativos = false}) async {
    return await repositorio.listarTodos(
        idGestor: idGestor, incluirInativos: incluirInativos);
  }
}
