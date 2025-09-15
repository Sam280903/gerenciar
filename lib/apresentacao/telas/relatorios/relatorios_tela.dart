// lib/apresentacao/telas/relatorios/relatorios_tela.dart
import 'package:flutter/material.dart';

class RelatoriosTela extends StatelessWidget {
  const RelatoriosTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
      ),
      body: const Center(
        child: Text(
          'Geração de relatórios de serviços e financeiros.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
