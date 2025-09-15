// lib/apresentacao/telas/verificador_inicial_tela.dart

import 'package:flutter/material.dart';
import 'package:gerenciar/apresentacao/telas/cadastro_gestor/cadastro_gestor_tela.dart';
import 'package:gerenciar/apresentacao/telas/login/login_tela.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';

class VerificadorInicialTela extends StatefulWidget {
  const VerificadorInicialTela({super.key});

  @override
  State<VerificadorInicialTela> createState() => _VerificadorInicialTelaState();
}

class _VerificadorInicialTelaState extends State<VerificadorInicialTela> {
  final AutenticacaoServico _authServico = AutenticacaoServico();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authServico.primeiroGestorJaCadastrado(),
      builder: (context, snapshot) {
        // Enquanto verifica, mostra uma tela de carregamento
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se a verificação for concluída
        if (snapshot.hasData) {
          final gestorCadastrado = snapshot.data!;
          // Se o gestor já foi cadastrado, mostra a tela de Login
          if (gestorCadastrado) {
            return const LoginTela();
          } else {
            // Senão, mostra a tela de Cadastro do Gestor
            return const CadastroGestorTela();
          }
        }

        // Em caso de erro ou se não houver dados, por segurança, vai para o login
        return const LoginTela();
      },
    );
  }
}
