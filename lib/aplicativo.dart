// lib/

// CORREÇÃO: Corrigido o erro de digitação no import.
import 'package:flutter/material.dart';

// Import das telas
import 'package:gerenciar/apresentacao/telas/boas_vindas/boas_vindas_tela.dart';
import 'package:gerenciar/apresentacao/telas/verificador_inicial_tela.dart';
import 'package:gerenciar/apresentacao/telas/login/login_tela.dart';
import 'package:gerenciar/apresentacao/telas/cadastro_gestor/cadastro_gestor_tela.dart';
import 'package:gerenciar/apresentacao/telas/home/home_tela.dart';
import 'package:gerenciar/apresentacao/telas/ordens_servico/ordens_servico_tela.dart';
import 'package:gerenciar/apresentacao/telas/tecnicos/tecnicos_tela.dart';
import 'package:gerenciar/apresentacao/telas/agendamentos/agendamentos_tela.dart';
import 'package:gerenciar/apresentacao/telas/clientes/clientes_tela.dart';
import 'package:gerenciar/apresentacao/telas/relatorios/relatorios_tela.dart';
import 'package:gerenciar/apresentacao/telas/tutoriais/tutoriais_tela.dart';
import 'package:gerenciar/apresentacao/telas/formas_pagamento/formas_pagamento_tela.dart';
import 'package:gerenciar/apresentacao/telas/comuntem/comuntem_tela.dart';
import 'package:gerenciar/apresentacao/telas/redefinir_senha/redefinir_senha_tela.dart';

// Import das configurações do app
import 'app/rotas.dart';
import 'app/tema.dart';

class GerenciarApp extends StatelessWidget {
  const GerenciarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GerenciAR',
      debugShowCheckedModeBanner: false,
      // CORREÇÃO: Usando o nome correto da variável do tema
      theme: temaProfissional,
      initialRoute: Rotas.boasVindas,
      routes: {
        Rotas.boasVindas: (context) => const BoasVindasTela(),
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
        Rotas.tutoriais: (_) => const TutoriaisTela(),
        Rotas.formasPagamento: (_) => const FormasPagamentoTela(),
        Rotas.comuntem: (_) => const ComuntemTela(),
      },
    );
  }
}
