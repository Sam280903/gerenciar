// lib/apresentacao/telas/agendamentos/agendamentos_tela.dart
import 'package:flutter/material.dart';

class AgendamentosTela extends StatelessWidget {
  const AgendamentosTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
      ),
      body: const Center(
        child: Text(
          'Visualização e criação de agendamentos.',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Lógica para novo agendamento
        },
        icon: const Icon(Icons.add),
        label: const Text('NOVO AGENDAMENTO'),
      ),
    );
  }
}
