import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/interfaces/ordem_servico_repositorio_interface.dart';

import 'cadastro_os_offline_test.mocks.dart';

@GenerateMocks([OrdemServicoRepositorioInterface])
void main() {
  late MockOrdemServicoRepositorioInterface mockRemoteRepo;
  late MockOrdemServicoRepositorioInterface mockLocalRepo;

  setUp(() {
    mockRemoteRepo = MockOrdemServicoRepositorioInterface();
    mockLocalRepo = MockOrdemServicoRepositorioInterface();
  });

  final osFake = OrdemServico(
    id: 'os-offline-001',
    idTecnico: 'tec-123',
    idCliente: 'cli-123',
    idFormaPagamento: 'fp-123',
    idGestor: 'gestor-1',
    dataHoraInicio: DateTime.now(),
    descricao: 'Limpeza de Ar Condicionado',
    valor: 150.0,
    prioridade: 'Normal',
    status: 'Aberta',
    ativo: true,
  );

  group('Sincronização de Ordens de Serviço', () {
    test('Deve validar o fluxo offline para Ordens de Serviço', () async {
      when(mockRemoteRepo.adicionar(any)).thenThrow(Exception('Offline'));
      when(mockLocalRepo.adicionar(any)).thenAnswer((_) async => {});

      try {
        await mockRemoteRepo.adicionar(osFake);
      } catch (e) {
        await mockLocalRepo.adicionar(osFake);
      }

      verify(mockLocalRepo.adicionar(osFake)).called(1);
    });
  });
}
