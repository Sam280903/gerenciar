import '../../interfaces/agendamento_repositorio_interface.dart';

class InativarAgendamento {
  final AgendamentoRepositorioInterface repositorio;

  InativarAgendamento(this.repositorio);

  Future<void> executar(String id) async {
    await repositorio.inativar(id);
  }
}
