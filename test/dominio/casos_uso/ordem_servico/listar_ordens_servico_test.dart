// test/dominio/casos_uso/ordem_servico/listar_ordens_servico_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/listar_ordens_servico.dart';
import 'package:gerenciar/dominio/interfaces/ordem_servico_repositorio_interface.dart';

import 'listar_ordens_servico_test.mocks.dart';

@GenerateMocks([OrdemServicoRepositorioInterface])
void main() {
  late MockOrdemServicoRepositorioInterface mockRepositorio;
  late ListarOrdensServico casoDeUso;

  setUp(() {
    mockRepositorio = MockOrdemServicoRepositorioInterface();
    casoDeUso = ListarOrdensServico(mockRepositorio);
  });

  // AQUI ESTÁ A CORREÇÃO
  final listaDeOSExemplo = [
    OrdemServico(
      id: 'os-1',
      idTecnico: 'tec-1',
      idCliente: 'cli-1',
      idFormaPagamento: 'fp-1',
      idGestor: 'gestor-1', // ADICIONADO
      dataHoraInicio: DateTime.now(),
      descricao: 'Limpeza de filtro',
      valor: 150.0,
      prioridade: 'Baixa',
      status: 'Pendente',
      ativo: true,
    ),
    OrdemServico(
      id: 'os-2',
      idTecnico: 'tec-2',
      idCliente: 'cli-2',
      idFormaPagamento: 'fp-2',
      idGestor: 'gestor-1', // ADICIONADO
      dataHoraInicio: DateTime.now(),
      descricao: 'Troca de compressor',
      valor: 800.0,
      prioridade: 'Alta',
      status: 'Em Andamento',
      ativo: true,
    )
  ];

  test('Deve retornar uma lista de ordens de serviço do repositório', () async {
    // Arrange - CORRIGIDO
    when(mockRepositorio.listarTodos(idGestor: anyNamed('idGestor')))
        .thenAnswer((_) async => listaDeOSExemplo);

    // Act - CORRIGIDO
    final resultado = await casoDeUso.executar(idGestor: 'gestor-1');

    // Assert
    expect(resultado, equals(listaDeOSExemplo));
    verify(mockRepositorio.listarTodos(idGestor: 'gestor-1'));
    verifyNoMoreInteractions(mockRepositorio);
  });
}
