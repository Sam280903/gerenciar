// test/dominio/casos_uso/tecnico/ativacao_tecnico_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/inativar_tecnico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/reativar_tecnico.dart';
// ignore: unused_import
import 'package:gerenciar/dominio/interfaces/tecnico_repositorio_interface.dart';

// Usa o mock já gerado em cadastrar_tecnico_test.dart
import 'cadastrar_tecnico_test.mocks.dart';

void main() {
  late MockTecnicoRepositorioInterface mockRepositorio;
  late InativarTecnico inativarCasoDeUso;
  late ReativarTecnico reativarCasoDeUso;

  setUp(() {
    mockRepositorio = MockTecnicoRepositorioInterface();
    inativarCasoDeUso = InativarTecnico(mockRepositorio);
    reativarCasoDeUso = ReativarTecnico(mockRepositorio);
  });

  const tecnicoId = 'tec-1';

  group('InativarTecnico', () {
    test('Deve chamar o método inativar do repositório', () async {
      // Arrange
      when(mockRepositorio.inativar(any)).thenAnswer((_) async => {});

      // Act
      await inativarCasoDeUso.executar(tecnicoId);

      // Assert
      verify(mockRepositorio.inativar(tecnicoId));
      verifyNoMoreInteractions(mockRepositorio);
    });
  });

  group('ReativarTecnico', () {
    test('Deve chamar o método reativar do repositório', () async {
      // Arrange
      when(mockRepositorio.reativar(any)).thenAnswer((_) async => {});

      // Act
      await reativarCasoDeUso.executar(tecnicoId);

      // Assert
      verify(mockRepositorio.reativar(tecnicoId));
      verifyNoMoreInteractions(mockRepositorio);
    });
  });
}
