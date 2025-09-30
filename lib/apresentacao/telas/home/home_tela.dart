// lib/apresentacao/telas/home/home_tela.dart

import 'package:flutter/material.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import '../../../constantes/cores.dart';
import '../../../app/rotas.dart';
import 'dart:ui'; // Para o efeito de vidro

class HomeTela extends StatefulWidget {
  // Adicionando o serviço como um parâmetro opcional
  final AutenticacaoServico? authServico;

  const HomeTela({super.key, this.authServico});

  @override
  State<HomeTela> createState() => _HomeTelaState();
}

class _HomeTelaState extends State<HomeTela>
    with SingleTickerProviderStateMixin {
  // A dependência será inicializada no initState
  late final AutenticacaoServico _authServico;

  String _nomeUsuario = "Usuário";
  String _perfilUsuario = "";
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Usa o serviço injetado ou cria uma nova instância
    _authServico = widget.authServico ?? AutenticacaoServico();

    _carregarDadosUsuario();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _carregarDadosUsuario() async {
    final dados = await _authServico.buscarDadosUsuarioLogado();
    if (dados != null && mounted) {
      setState(() {
        _nomeUsuario = dados['nome'] ?? 'Usuário';
        _perfilUsuario = dados['perfil'] ?? '';
      });
    }
  }

  void _fazerLogout() async {
    await _authServico.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          Rotas.login, (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Cores.azulFundo,
      appBar: AppBar(
        backgroundColor: Cores.azulFundo,
        elevation: 0,
        title: Image.asset(
          'assets/imagens/logo_gerenciar.png',
          height: 100,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Sair',
            onPressed: _fazerLogout,
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            const SizedBox(height: 16),
            _buildCartaoDestaque(),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
              child: Text(
                'Menu Principal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.95,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildItem(Icons.assignment_outlined, 'Ordens de Serviço',
                    Rotas.ordensServico, context),
                if (_perfilUsuario == 'gestor')
                  _buildItem(Icons.engineering_outlined, 'Técnicos',
                      Rotas.tecnicos, context),
                _buildItem(Icons.calendar_today_outlined, 'Agendamentos',
                    Rotas.agendamentos, context),
                _buildItem(Icons.people_alt_outlined, 'Clientes',
                    Rotas.clientes, context),
                _buildItem(Icons.bar_chart_outlined, 'Relatórios',
                    Rotas.relatorios, context),
                _buildItem(Icons.menu_book_outlined, 'Tutoriais',
                    Rotas.tutoriais, context),
                _buildItem(Icons.payment_outlined, 'Pagamentos',
                    Rotas.formasPagamento, context),
                _buildItem(Icons.support_agent_outlined, 'Suporte',
                    Rotas.suporte, context),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCartaoDestaque() {
    return Card(
      elevation: 8,
      shadowColor: Colors.black.withAlpha(102),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Cores.azulCard, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, $_nomeUsuario',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _perfilUsuario.isNotEmpty
                  ? 'Perfil: $_perfilUsuario'
                  : 'Selecione uma opção para começar.',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
      IconData icone, String titulo, String rota, BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, rota),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Cores.azulCard.withAlpha(128),
              border: Border.all(color: Colors.white.withAlpha(51)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icone, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}