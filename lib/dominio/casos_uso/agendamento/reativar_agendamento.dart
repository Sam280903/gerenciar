import '../../interfaces/agendamento_repositorio_interface.dart';

class ReativarAgendamento {
  final AgendamentoRepositorioInterface repositorio;
  ReativarAgendamento(this.repositorio);

  Future<void> executar(String id) async {
    if (id.isEmpty) {
      throw Exception('ID do agendamento é obrigatório.');
    }
    await repositorio.reativar(id);
  }
}
