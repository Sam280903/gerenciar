// lib/dominio/interfaces/tecnico_repositorio_interface.dart
import '../entidades/tecnico.dart';

abstract class TecnicoRepositorioInterface {
  Future<void> adicionar(Tecnico tecnico);
  Future<void> atualizar(Tecnico tecnico);
  Future<void> inativar(String id);
  Future<void> reativar(String id);
  Future<Tecnico?> buscarPorId(String id);
  // MÉTODO ALTERADO
  Future<List<Tecnico>> listarTodos(
      {required String idGestor, bool incluirInativos = false});
}