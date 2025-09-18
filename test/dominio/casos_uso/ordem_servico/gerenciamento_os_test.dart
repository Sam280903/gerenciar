// test/dominio/casos_uso/ordem_servico/gerenciamento_os_test.dart//
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/cadastrar_ordem_servico.dart'; // ADICIONADO
import 'package:gerenciar/dominio/casos_uso/ordem_servico/atualizar_ordem_servico.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/inativar_ordem_servico.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/reabrir_ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';

import 'listar_ordens_servico_test.mocks.dart';

void main() {
  late MockOrdemServicoRepositorioInterface mockRepositorio;

  setUp(() {
    mockRepositorio = MockOrdemServicoRepositorioInterface();
  });

  final ordemServico = OrdemServico(
    id: 'os-1',
    idTecnico: 'tec-1',
    idCliente: 'cli-1',
    idFormaPagamento: 'fp-1',
    dataHoraInicio: DateTime.now(),
    descricao: 'Teste',
    valor: 100.0,
    prioridade: 'Média',
    status: 'Concluída',
    ativo: true,
  );

  group('Gerenciamento de Ordens de Serviço', () {
    // TESTE ADICIONADO AQUI
    test('Deve chamar o método ADICIONAR do repositório', () async {
      final casoDeUso = CadastrarOrdemServico(mockRepositorio);
      when(mockRepositorio.adicionar(any)).thenAnswer((_) async => {});
      await casoDeUso.executar(ordemServico);
      verify(mockRepositorio.adicionar(ordemServico));
    });

    test('Deve chamar o método ATUALIZAR do repositório', () async {
      final casoDeUso = AtualizarOrdemServico(mockRepositorio);
      when(mockRepositorio.atualizar(any)).thenAnswer((_) async => {});
      await casoDeUso.executar(ordemServico);
      verify(mockRepositorio.atualizar(ordemServico));
    });

    test('Deve chamar o método INATIVAR do repositório', () async {
      final casoDeUso = InativarOrdemServico(mockRepositorio);
      when(mockRepositorio.inativar(any)).thenAnswer((_) async => {});
      await casoDeUso.executar(ordemServico.id);
      verify(mockRepositorio.inativar(ordemServico.id));
    });

    test('Deve chamar o método REABRIR do repositório', () async {
      final casoDeUso = ReabrirOrdemServico(mockRepositorio);
      when(mockRepositorio.reabrir(
              id: anyNamed('id'), justificativa: anyNamed('justificativa')))
          .thenAnswer((_) async => {});
      await casoDeUso.executar(id: ordemServico.id, justificativa: 'Garantia');
      verify(mockRepositorio.reabrir(
          id: ordemServico.id, justificativa: 'Garantia'));
    });
  });
}
