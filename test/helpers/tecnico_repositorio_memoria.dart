import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/dominio/interfaces/tecnico_repositorio_interface.dart';

class TecnicoRepositorioMemoria implements TecnicoRepositorioInterface {
  final _dados = <String, Tecnico>{};

  @override
  Future<void> adicionar(Tecnico tecnico) async {
    _dados[tecnico.id] = tecnico;
  }

  @override
  Future<void> atualizar(Tecnico tecnico) async {
    _dados[tecnico.id] = tecnico;
  }

  @override
  Future<void> inativar(String id) async {
    final t = _dados[id];
    if (t == null) return;
    _dados[id] = Tecnico(
      id: t.id,
      nome: t.nome,
      email: t.email,
      telefone: t.telefone,
      ativo: false,
      idGestor: t.idGestor,
    );
  }

  @override
  Future<void> reativar(String id) async {
    final t = _dados[id];
    if (t == null) return;
    _dados[id] = Tecnico(
      id: t.id,
      nome: t.nome,
      email: t.email,
      telefone: t.telefone,
      ativo: true,
      idGestor: t.idGestor,
    );
  }

  @override
  Future<Tecnico?> buscarPorId(String id) async {
    return _dados[id];
  }

  @override
  Future<List<Tecnico>> listarTodos(
      {required String idGestor, bool incluirInativos = false}) async {
    return _dados.values
        .where((t) =>
            t.idGestor == idGestor && (incluirInativos || t.ativo))
        .toList();
  }
}
