// test/apresentacao/telas/tecnicos/editar_tecnico_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/tecnicos/editar_tecnico_tela.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/dominio/interfaces/tecnico_repositorio_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Reutilizamos o mock gerado no teste de detalhes
import 'detalhes_tecnico_tela_test.mocks.dart';

@GenerateMocks([TecnicoRepositorioInterface])
void main() {
  late MockTecnicoRepositorioInterface mockTecnicoRepositorio;

  final tecnicoParaEditar = Tecnico(
    id: 'tec-edit-1',
    nome: 'Nome Antigo',
    email: 'antigo@teste.com',
    telefone: '111111111',
    ativo: true,
    idGestor: 'gestor-1',
  );

  Future<void> pumpTela(WidgetTester tester, Tecnico tecnico) async {
    await tester.pumpWidget(MaterialApp(
      home: EditarTecnicoTela(tecnico: tecnico),
    ));
  }

  setUp(() {
    mockTecnicoRepositorio = MockTecnicoRepositorioInterface();
  });

  testWidgets('Deve preencher os campos com os dados existentes do técnico',
      (WidgetTester tester) async {
    await pumpTela(tester, tecnicoParaEditar);

    expect(find.text('Nome Antigo'), findsOneWidget);
    expect(find.text('antigo@teste.com'), findsOneWidget);
    expect(find.text('111111111'), findsOneWidget);
  });

  testWidgets('Deve chamar o método de atualizar ao salvar as alterações',
      (WidgetTester tester) async {
    when(mockTecnicoRepositorio.atualizar(any)).thenAnswer((_) async => {});
    await pumpTela(tester, tecnicoParaEditar);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome Completo'), 'Nome Modificado');
    await tester.tap(find.text('SALVAR ALTERAÇÕES'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    verify(mockTecnicoRepositorio.atualizar(argThat(
      isA<Tecnico>().having((t) => t.nome, 'nome', 'Nome Modificado'),
    ))).called(1);
  });
}
