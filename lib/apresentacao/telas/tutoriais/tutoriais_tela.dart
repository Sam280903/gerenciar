// lib/apresentacao/telas/tutoriais/tutoriais_tela.dart
import 'package:flutter/material.dart';

class TutoriaisTela extends StatelessWidget {
  const TutoriaisTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutoriais'),
      ),
      body: const Center(
        child: Text(
          'Exibição de tutoriais e guias de uso.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
