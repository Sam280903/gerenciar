// test/dominio/casos_uso/tecnico/atualizar_tecnico_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/atualizar_tecnico.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';

import 'cadastrar_tecnico_test.mocks.dart';

void main() {
  late MockTecnicoRepositorioInterface mockRepositorio;
  late AtualizarTecnico casoDeUso;

  setUp(() {
    mockRepositorio = MockTecnicoRepositorioInterface();
    casoDeUso = AtualizarTecnico(mockRepositorio);
  });

  // AQUI ESTÁ A CORREÇÃO
  final tecnico = Tecnico(
    id: 'tec-1',
    nome: 'Flávio',
    email: 'f@teste.com',
    telefone: '123',
    ativo: true,
    idGestor: 'gestor-1', // ADICIONADO
  );

  test('Deve chamar o método ATUALIZAR do repositório', () async {
    when(mockRepositorio.atualizar(any)).thenAnswer((_) async => {});
    await casoDeUso.executar(tecnico);
    verify(mockRepositorio.atualizar(tecnico));
    verifyNoMoreInteractions(mockRepositorio);
  });
}
