// test/dominio/casos_uso/agendamento/reativar_agendamento_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/reativar_agendamento.dart';

// Usa o mock que já criamos para o agendamento
import 'cadastrar_agendamento_test.mocks.dart';

void main() {
  late MockAgendamentoRepositorioInterface mockRepositorio;
  late ReativarAgendamento casoDeUso;

  setUp(() {
    mockRepositorio = MockAgendamentoRepositorioInterface();
    casoDeUso = ReativarAgendamento(mockRepositorio);
  });

  const agendamentoId = 'ag-1';

  test('Deve chamar o método reativar do repositório', () async {
    // Arrange
    when(mockRepositorio.reativar(any)).thenAnswer((_) async => {});

    // Act
    await casoDeUso.executar(agendamentoId);

    // Assert
    verify(mockRepositorio.reativar(agendamentoId));
    verifyNoMoreInteractions(mockRepositorio);
  });
}
