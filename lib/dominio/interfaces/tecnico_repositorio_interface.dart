// lib/dominio/interfaces/tecnico_repositorio_interface.dart
import '../entidades/tecnico.dart';

abstract class TecnicoRepositorioInterface {
  Future<void> adicionar(Tecnico tecnico);
  Future<void> atualizar(Tecnico tecnico);
  Future<void> inativar(String id);
  Future<void> reativar(String id); // Novo método
  Future<Tecnico?> buscarPorId(String id);
  // Parâmetro para incluir inativos na busca
  Future<List<Tecnico>> listarTodos({bool incluirInativos = false});
}
