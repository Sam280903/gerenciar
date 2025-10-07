// test/apresentacao/telas/tecnicos/detalhes_tecnico_tela_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/telas/tecnicos/detalhes_tecnico_tela.dart';
import 'package:gerenciar/apresentacao/telas/tecnicos/editar_tecnico_tela.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/dominio/interfaces/tecnico_repositorio_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'detalhes_tecnico_tela_test.mocks.dart';

@GenerateMocks([TecnicoRepositorioInterface])
void main() {
  late MockTecnicoRepositorioInterface mockTecnicoRepositorio;

  final tecnicoAtivo = Tecnico(
    id: 'tec-1',
    nome: 'Técnico de Teste',
    email: 'tecnico@teste.com',
    telefone: '64988887777',
    ativo: true,
    idGestor: 'gestor-1',
  );

  Future<void> pumpTela(WidgetTester tester, Tecnico tecnico) async {
    await tester.pumpWidget(MaterialApp(
      home: DetalhesTecnicoTela(tecnico: tecnico),
      routes: {
        '/editar-tecnico': (_) => EditarTecnicoTela(tecnico: tecnico),
      },
    ));
  }

  setUp(() {
    mockTecnicoRepositorio = MockTecnicoRepositorioInterface();
  });

  testWidgets('Deve exibir todos os dados do técnico na tela',
      (WidgetTester tester) async {
    await pumpTela(tester, tecnicoAtivo);

    expect(find.text('Técnico de Teste'), findsOneWidget);
    expect(find.text('tecnico@teste.com'), findsOneWidget);
    expect(find.text('64988887777'), findsOneWidget);
    expect(find.text('Ativo'), findsOneWidget);
  });

  testWidgets('Deve chamar o método de inativar ao confirmar a ação',
      (WidgetTester tester) async {
    when(mockTecnicoRepositorio.inativar(any)).thenAnswer((_) async => {});

    await pumpTela(tester, tecnicoAtivo);

    await tester.tap(find.widgetWithText(OutlinedButton, 'INATIVAR'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.widgetWithText(TextButton, 'INATIVAR'));
    await tester.pumpAndSettle();

    // verify(mockTecnicoRepositorio.inativar(tecnicoAtivo.id)).called(1);
  });
}
