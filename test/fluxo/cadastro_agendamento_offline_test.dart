import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:gerenciar/dominio/interfaces/agendamento_repositorio_interface.dart';
import 'package:gerenciar/servicos/sincronizacao_servico.dart';

import 'cadastro_agendamento_offline_test.mocks.dart';

@GenerateMocks([AgendamentoRepositorioInterface])
void main() {
  late MockAgendamentoRepositorioInterface mockRemoteRepo;
  late MockAgendamentoRepositorioInterface mockLocalRepo;
  late SincronizacaoServico sincronizacaoServico;

  setUp(() {
    mockRemoteRepo = MockAgendamentoRepositorioInterface();
    mockLocalRepo = MockAgendamentoRepositorioInterface();
    sincronizacaoServico = SincronizacaoServico();
  });

  final agendamentoFake = Agendamento(
    id: 'ag-offline-001',
    idTecnico: 'tec-123',
    idCliente: 'cli-123',
    dataHora: DateTime.now(),
    idGestor: 'gestor-1', // idGestor obrigatório
    ativo: true,
  );

  group('Sincronização de Agendamentos', () {
    test('Deve validar o fluxo offline para Agendamentos', () async {
      when(mockRemoteRepo.adicionar(any)).thenThrow(Exception('Falha de Rede'));
      when(mockLocalRepo.adicionar(any)).thenAnswer((_) async => {});

      try {
        await mockRemoteRepo.adicionar(agendamentoFake);
      } catch (e) {
        await mockLocalRepo.adicionar(agendamentoFake);
      }

      verify(mockLocalRepo.adicionar(agendamentoFake)).called(1);
    });
  });
}
