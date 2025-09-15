// lib/apresentacao/telas/boas_vindas/boas_vindas_tela.dart

import 'package:flutter/material.dart';
import 'package:gerenciar/app/rotas.dart';
import 'package:gerenciar/constantes/cores.dart';

class BoasVindasTela extends StatefulWidget {
  const BoasVindasTela({super.key});

  @override
  State<BoasVindasTela> createState() => _BoasVindasTelaState();
}

class _BoasVindasTelaState extends State<BoasVindasTela>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.azulFundo,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // Logo com animação de fade-in
              FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  'assets/imagens/logo_gerenciar.png',
                  height: 200,
                ),
              ),
              const SizedBox(height: 24),
              // Textos com animação de deslize e fade-in
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: const Column(
                    children: [
                      Text(
                        'Bem-vindo ao GerenciAR',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Seu assistente para gestão de serviços de climatização.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 3),
              // Botões com animação
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, Rotas.cadastroGestor),
                        child: const Text('PRIMEIRO ACESSO'),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, Rotas.login),
                        child: const Text('JÁ TENHO CADASTRO'),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
