import 'package:flutter/material.dart';

class ComuntemTela extends StatelessWidget {
  const ComuntemTela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comuntem'),
      ),
      body: const Center(
        child: Text(
          'Tela em construção...',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
