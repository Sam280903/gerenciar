import '../../entidades/agendamento.dart';
import '../../interfaces/agendamento_repositorio_interface.dart';

class BuscarAgendamentoPorId {
  final AgendamentoRepositorioInterface repositorio;

  BuscarAgendamentoPorId(this.repositorio);

  Future<Agendamento?> executar(String id) async {
    return await repositorio.buscarPorId(id);
  }
}
