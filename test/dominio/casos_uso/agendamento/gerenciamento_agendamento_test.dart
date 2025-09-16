// test/dominio/casos_uso/agendamento/gerenciamento_agendamento_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/atualizar_agendamento.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/inativar_agendamento.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';

// Usa o mock que já criamos para o agendamento
import 'cadastrar_agendamento_test.mocks.dart';

void main() {
  late MockAgendamentoRepositorioInterface mockRepositorio;

  setUp(() {
    mockRepositorio = MockAgendamentoRepositorioInterface();
  });

  final agendamento = Agendamento(
    id: 'ag-1',
    idTecnico: 'tec-1',
    idCliente: 'cli-1',
    dataHora: DateTime.now(),
    ativo: true,
  );
//
  group('Gerenciamento de Agendamento', () {
    test('Deve chamar o método ATUALIZAR do repositório', () async {
      final casoDeUso = AtualizarAgendamento(mockRepositorio);
      when(mockRepositorio.atualizar(any)).thenAnswer((_) async => {});

      await casoDeUso.executar(agendamento);

      verify(mockRepositorio.atualizar(agendamento));
      verifyNoMoreInteractions(mockRepositorio);
    });

    test('Deve chamar o método INATIVAR do repositório', () async {
      final casoDeUso = InativarAgendamento(mockRepositorio);
      when(mockRepositorio.inativar(any)).thenAnswer((_) async => {});

      await casoDeUso.executar(agendamento.id);

      verify(mockRepositorio.inativar(agendamento.id));
      verifyNoMoreInteractions(mockRepositorio);
    });
  });
}
