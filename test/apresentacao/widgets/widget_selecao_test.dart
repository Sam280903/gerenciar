import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gerenciar/apresentacao/widgets/_widget_selecao.dart';

void main() {
  testWidgets('Deve renderizar WidgetSelecao corretamente', (WidgetTester tester) async {
    bool foiTocado = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WidgetSelecao(
            label: 'Selecione um Cliente',
            valor: 'Cliente Teste',
            onTap: () {
              foiTocado = true;
            },
          ),
        ),
      ),
    );

    // Verifica se renderizou o label e o valor
    expect(find.text('Selecione um Cliente'), findsOneWidget);
    expect(find.text('Cliente Teste'), findsOneWidget);
    
    // Verifica o ícone
    expect(find.byIcon(Icons.search), findsOneWidget);

    // Verifica a interação (tap)
    await tester.tap(find.byType(TextFormField));
    expect(foiTocado, isTrue);
  });

  testWidgets('Deve exibir erro ao falhar na validação', (WidgetTester tester) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: WidgetSelecao(
              label: 'Selecione um Cliente',
              valor: '',
              onTap: () {},
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
          ),
        ),
      ),
    );

    // Aciona a validação
    formKey.currentState!.validate();
    await tester.pump();

    // Verifica se a mensagem de erro apareceu
    expect(find.text('Campo obrigatório'), findsOneWidget);
  });
}
