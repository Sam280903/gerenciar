import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/dominio/interfaces/cliente_repositorio_interface.dart';
import 'package:gerenciar/dominio/interfaces/ordem_servico_repositorio_interface.dart';
import 'package:gerenciar/dominio/interfaces/tecnico_repositorio_interface.dart';
import 'package:gerenciar/servicos/relatorio_servico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'relatorio_servico_test.mocks.dart';

@GenerateMocks([
  OrdemServicoRepositorioInterface,
  ClienteRepositorioInterface,
  TecnicoRepositorioInterface,
])
void main() {
  late MockOrdemServicoRepositorioInterface mockOSRepo;
  late MockClienteRepositorioInterface mockClienteRepo;
  late MockTecnicoRepositorioInterface mockTecnicoRepo;
  late RelatorioServico relatorioServico;

  setUp(() {
    mockOSRepo = MockOrdemServicoRepositorioInterface();
    mockClienteRepo = MockClienteRepositorioInterface();
    mockTecnicoRepo = MockTecnicoRepositorioInterface();

    relatorioServico = RelatorioServico(
      ordemServicoRepositorio: mockOSRepo,
      clienteRepo: mockClienteRepo,
      tecnicoRepo: mockTecnicoRepo,
    );
  });

  final dataAtual = DateTime.now();

  final osExemplo = OrdemServico(
    id: 'os-1',
    idCliente: 'cliente-1',
    idTecnico: 'tec-1',
    idFormaPagamento: 'fp-1',
    idGestor: 'gestor-1',
    dataHoraInicio: dataAtual,
    descricao: 'Teste',
    valor: 100,
    prioridade: 'Baixa',
    status: 'Pendente',
    ativo: true,
  );

  final clienteExemplo = Cliente(
    id: 'cliente-1',
    nome: 'Cliente Teste',
    email: '',
    telefone: '',
    endereco: '',
    ativo: true,
    idGestor: 'gestor-1',
  );

  final tecnicoExemplo = Tecnico(
    id: 'tec-1',
    nome: 'Técnico Teste',
    email: '',
    telefone: '',
    ativo: true,
    idGestor: 'gestor-1',
  );

  test('Deve gerar relatório de ordens de serviço detalhadas com sucesso', () async {
    final filtros = FiltrosRelatorio(status: ['Pendente']);

    when(mockOSRepo.listarComFiltros(filtros, 'gestor-1'))
        .thenAnswer((_) async => [osExemplo]);
    when(mockClienteRepo.listarTodos(idGestor: 'gestor-1', incluirInativos: false))
        .thenAnswer((_) async => [clienteExemplo]);
    when(mockTecnicoRepo.listarTodos(idGestor: 'gestor-1', incluirInativos: false))
        .thenAnswer((_) async => [tecnicoExemplo]);

    final resultado = await relatorioServico.gerarRelatorioOrdensServico(filtros, 'gestor-1');

    expect(resultado.length, 1);
    expect(resultado[0].os.id, 'os-1');
    expect(resultado[0].cliente?.nome, 'Cliente Teste');
    expect(resultado[0].tecnico?.nome, 'Técnico Teste');
  });

  test('Deve lançar Exception caso o repositório falhe', () async {
    final filtros = FiltrosRelatorio();

    when(mockOSRepo.listarComFiltros(any, any))
        .thenThrow(Exception('Erro de conexão'));

    expect(
      () => relatorioServico.gerarRelatorioOrdensServico(filtros, 'gestor-1'),
      throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Não foi possível gerar o relatório'))),
    );
  });
}
