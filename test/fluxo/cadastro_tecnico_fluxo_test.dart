// test/fluxos/cadastro_tecnico_fluxo_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/tecnicos/tecnicos_tela.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/listar_tecnicos.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'cadastro_tecnico_fluxo_test.mocks.dart';

@GenerateMocks([ListarTecnicos, AutenticacaoServico])
void main() {
  late MockListarTecnicos mockListarTecnicos;
  late MockAutenticacaoServico mockAuthServico;

  final novoTecnico = Tecnico(
      id: 'tec-novo-1',
      nome: 'Técnico de Integração',
      email: 'integracao@teste.com',
      telefone: '64987654321',
      ativo: true,
      idGestor: 'gestor-1');

  setUp(() {
    mockListarTecnicos = MockListarTecnicos();
    mockAuthServico = MockAutenticacaoServico();

    when(mockAuthServico.buscarDadosUsuarioLogado())
        .thenAnswer((_) async => {'idGestor': 'gestor-1', 'perfil': 'gestor'});
  });

  testWidgets('Deve cadastrar um novo técnico e exibi-lo na lista',
      (WidgetTester tester) async {
    // --- CORREÇÃO PRINCIPAL AQUI ---
    // Variável para contar as chamadas ao método
    var callCount = 0;
    // Configura o mock para usar a variável e decidir o que retornar
    when(mockListarTecnicos.executar(
      idGestor: anyNamed('idGestor'),
      incluirInativos: anyNamed('incluirInativos'),
    )).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) {
        return []; // Na primeira chamada, retorna a lista vazia
      } else {
        return [novoTecnico]; // Nas chamadas seguintes, retorna o novo técnico
      }
    });
    // --- FIM DA CORREÇÃO ---

    when(mockAuthServico.cadastrarTecnico(
      nome: anyNamed('nome'),
      email: anyNamed('email'),
      senha: anyNamed('senha'),
      telefone: anyNamed('telefone'),
    )).thenAnswer((_) async => null);

    await tester.pumpWidget(MaterialApp(
      home: TecnicosTela(
        listarTecnicos: mockListarTecnicos,
        authServico: mockAuthServico,
      ),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Nenhum técnico ativo cadastrado.'), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Novo Técnico'), findsOneWidget);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome Completo'), novoTecnico.nome);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail (para login)'),
        novoTecnico.email);
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha de Acesso'), '123456');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Telefone'), novoTecnico.telefone);

    await tester.tap(find.text('SALVAR'));

    // Aguarda a navegação e o recarregamento da lista
    await tester.pumpAndSettle();

    // ASSERT Final
    expect(find.byType(TecnicosTela), findsOneWidget);
    expect(find.text('Técnico de Integração'), findsOneWidget);
  });
}
