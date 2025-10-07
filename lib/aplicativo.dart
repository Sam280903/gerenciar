// lib/aplicativo.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gerenciar/apresentacao/telas/boas_vindas/boas_vindas_tela.dart';
import 'package:gerenciar/apresentacao/telas/home/home_tela.dart';
import 'package:gerenciar/apresentacao/telas/verificador_inicial_tela.dart';
import 'package:gerenciar/apresentacao/telas/login/login_tela.dart';
import 'package:gerenciar/apresentacao/telas/cadastro_gestor/cadastro_gestor_tela.dart';
import 'package:gerenciar/apresentacao/telas/ordens_servico/ordens_servico_tela.dart';
import 'package:gerenciar/apresentacao/telas/tecnicos/tecnicos_tela.dart';
import 'package:gerenciar/apresentacao/telas/agendamentos/agendamentos_tela.dart';
import 'package:gerenciar/apresentacao/telas/clientes/clientes_tela.dart';
import 'package:gerenciar/apresentacao/telas/relatorios/relatorios_tela.dart';
import 'package:gerenciar/apresentacao/telas/tutoriais/tutoriais_tela.dart';
// --- IMPORT ADICIONADO AQUI ---
import 'package:gerenciar/apresentacao/telas/formas_pagamento/formas_pagamento_tela.dart';
// ---------------------------------
import 'package:gerenciar/apresentacao/telas/suporte/suporte_tela.dart';
import 'package:gerenciar/apresentacao/telas/redefinir_senha/redefinir_senha_tela.dart';
import 'app/rotas.dart';
import 'app/tema.dart';

class GerenciarApp extends StatelessWidget {
  const GerenciarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GerenciAR',
      debugShowCheckedModeBanner: false,
      theme: temaProfissional,
      // O home agora verifica o estado de autenticação
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Enquanto verifica, mostra uma tela de carregamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Se já tem um usuário logado (mesmo offline), vai para a Home
          if (snapshot.hasData) {
            return const HomeTela();
          }
          // Se não tem usuário, vai para a tela de boas-vindas
          return const BoasVindasTela();
        },
      ),
      // Suas rotas nomeadas continuam funcionando normalmente
      routes: {
        Rotas.verificador: (context) => const VerificadorInicialTela(),
        Rotas.login: (context) => const LoginTela(),
        Rotas.cadastroGestor: (context) => const CadastroGestorTela(),
        Rotas.redefinirSenha: (context) => const RedefinirSenhaTela(),
        Rotas.home: (context) => const HomeTela(),
        Rotas.ordensServico: (_) => const OrdensServicoTela(),
        Rotas.tecnicos: (_) => const TecnicosTela(),
        Rotas.agendamentos: (_) => const AgendamentosTela(),
        Rotas.clientes: (_) => const ClientesTela(),
        Rotas.relatorios: (_) => const RelatoriosTela(),
        Rotas.tutoriais: (_) => TutoriaisTela(),
        Rotas.formasPagamento: (_) => const FormasPagamentoTela(),
        Rotas.suporte: (_) => const SuporteTela(),
      },
    );
  }
}
