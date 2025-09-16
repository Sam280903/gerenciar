// test/dominio/casos_uso/agendamento/busca_agendamento_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/buscar_agendamento_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/listar_agendamentos.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';

// Usa o mock que já criamos para o agendamento
import 'cadastrar_agendamento_test.mocks.dart';

void main() {
  late MockAgendamentoRepositorioInterface mockRepositorio;
  late BuscarAgendamentoPorId buscarPorId;
  late ListarAgendamentos listar;

  setUp(() {
    mockRepositorio = MockAgendamentoRepositorioInterface();
    buscarPorId = BuscarAgendamentoPorId(mockRepositorio);
    listar = ListarAgendamentos(mockRepositorio);
  });

  final agendamentoExemplo = Agendamento(
    id: 'ag-1',
    idTecnico: 'tec-1',
    idCliente: 'cli-1',
    dataHora: DateTime.now(),
    ativo: true,
  );

  group('Busca de Agendamentos', () {
    test('Deve retornar um agendamento ao buscar por id', () async {
      // Arrange
      when(mockRepositorio.buscarPorId(any))
          .thenAnswer((_) async => agendamentoExemplo);

      // Act
      final resultado = await buscarPorId.executar('ag-1');

      // Assert
      expect(resultado, agendamentoExemplo);
      verify(mockRepositorio.buscarPorId('ag-1'));
    });

    test('Deve retornar uma lista de agendamentos', () async {
      // Arrange
      final lista = [agendamentoExemplo];
      when(mockRepositorio.listarTodos()).thenAnswer((_) async => lista);

      // Act
      final resultado = await listar.executar();

      // Assert
      expect(resultado, lista);
      verify(mockRepositorio.listarTodos());
    });
  });
}
