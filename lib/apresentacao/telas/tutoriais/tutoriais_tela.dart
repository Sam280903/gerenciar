// lib/apresentacao/telas/tutoriais/tutoriais_tela.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gerenciar/dominio/entidades/tutorial.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'detalhes_tutorial_tela.dart';

class TutoriaisTela extends StatefulWidget {
  final AutenticacaoServico? authServico;

  TutoriaisTela({super.key, this.authServico});

  @override
  State<TutoriaisTela> createState() => _TutoriaisTelaState();
}

class _TutoriaisTelaState extends State<TutoriaisTela> {
  late final AutenticacaoServico _authServico;
  final _buscaController = TextEditingController();
  List<Tutorial> _tutoriaisFiltrados = [];
  String _perfil = '';

  final List<Tutorial> _todosTutoriais = [
    // Categoria: Cadastros
    Tutorial(
      categoria: 'Cadastros',
      titulo: 'Como cadastrar um novo Cliente?',
      conteudo:
          'Para cadastrar um novo cliente, siga estes passos:\n\n'
          '1. No menu lateral ou na tela inicial, acesse a opção **"Clientes"**.\n'
          '2. Toque no botão circular flutuante **"+ NOVO CLIENTE"** no canto inferior direito.\n'
          '3. Preencha os dados do cliente: Nome Completo, CPF/CNPJ, Telefone e Endereço.\n'
          '4. Se estiver com pressa, você pode usar o **"Cadastro Rápido"** no topo da tela, que exige apenas o nome e telefone.\n'
          '5. Após preencher, toque em **"SALVAR"**.\n\n'
          '**Dica:** O sistema valida o CPF automaticamente para garantir que os dados estejam corretos.',
      videoUrlGestor: null,
      videoUrlTecnico: null,
    ),
    Tutorial(
      categoria: 'Cadastros',
      titulo: 'Como cadastrar um novo Técnico?',
      conteudo:
          'O gerenciamento de equipe é restrito a usuários com perfil de **Gestor**:\n\n'
          '1. Acesse o menu **"Técnicos"**.\n'
          '2. Toque em **"+ NOVO TÉCNICO"**.\n'
          '3. Informe o Nome, E-mail profissional e defina uma senha inicial.\n'
          '4. Selecione se o técnico terá permissões administrativas ou apenas operacionais.\n'
          '5. Clique em **"CADASTRAR"**.\n\n'
          '**Importante:** O técnico cadastrado receberá as notificações de agendamentos diretamente no celular dele assim que fizer o login.',
      videoUrlGestor: null,
      perfisPermitidos: ['gestor'],
    ),
    // Categoria: Agendamentos
    Tutorial(
      categoria: 'Agendamentos',
      titulo: 'Como criar um novo agendamento?',
      conteudo:
          'O agendamento inteligente ajuda a organizar sua rotina:\n\n'
          '1. Vá para a tela **"Agendamentos"**.\n'
          '2. Clique no botão **"+ NOVO"**.\n'
          '3. Selecione o **Cliente** (você pode buscar por nome).\n'
          '4. Escolha o **Técnico** responsável pelo atendimento.\n'
          '5. Defina a **Data** e o **Horário** de início.\n'
          '6. O sistema fará uma verificação em tempo real: se o técnico já possuir um compromisso nesse horário, um aviso de conflito aparecerá.\n'
          '7. Toque em **"CONFIRMAR"**.\n\n'
          '**Nota:** Agendamentos criados offline serão sincronizados automaticamente assim que você recuperar o sinal de internet.',
      videoUrlGestor: null,
      videoUrlTecnico: null,
    ),
    Tutorial(
      categoria: 'Agendamentos',
      titulo: 'Como concluir ou inativar um agendamento?',
      conteudo:
          'Para gerenciar o status de um atendimento:\n\n'
          '1. Na lista de **Agendamentos**, localize o item desejado (você pode usar os filtros de "Hoje", "Semana" ou "Mês").\n'
          '2. Toque sobre o agendamento para abrir os detalhes.\n'
          '3. Para finalizar: Toque em **"CONCLUIR"**. Isso abrirá automaticamente a tela para gerar a Ordem de Serviço.\n'
          '4. Para cancelar: Toque em **"INATIVAR"** e informe o motivo do cancelamento.\n\n'
          'Agendamentos inativados não aparecem mais na agenda principal, mas podem ser consultados no histórico do cliente.',
      videoUrlGestor: null,
      videoUrlTecnico: null,
    ),
    // Categoria: Ordens de Serviço
    Tutorial(
      categoria: 'Ordens de Serviço',
      titulo: 'Como gerar uma Ordem de Serviço?',
      conteudo:
          'A Ordem de Serviço (OS) é o documento principal do atendimento:\n\n'
          '1. Acesse a tela **"Ordens de Serviço"**.\n'
          '2. Clique em **"+ NOVA OS"**.\n'
          '3. Vincule a um **Cliente** e a um **Agendamento** prévio (opcional).\n'
          '4. Descreva detalhadamente o **Problema Relatado** e o **Serviço Realizado**.\n'
          '5. Adicione itens ou peças utilizadas, se houver.\n'
          '6. Defina o **Valor Total** e a **Forma de Pagamento**.\n'
          '7. Ao finalizar, você pode gerar um **PDF** para enviar ao cliente via WhatsApp ou E-mail.\n\n'
          '**Dica:** Você pode tirar fotos do serviço e anexar à OS para maior transparência.',
      videoUrlGestor: null,
      videoUrlTecnico: null,
    ),
    Tutorial(
      categoria: 'Ordens de Serviço',
      titulo: 'Como reabrir uma OS concluída?',
      conteudo:
          'Caso surja um problema no serviço realizado (Garantia):\n\n'
          '1. Localize a OS nas **"Concluídas"**.\n'
          '2. Somente um **Gestor** visualiza o botão **"REABRIR OS"**.\n'
          '3. Ao clicar, o sistema solicitará uma **Justificativa**.\n'
          '4. A OS voltará para o status "Em Aberto", permitindo novas edições e atualizações pelo técnico.',
      videoUrlGestor: null,
      perfisPermitidos: ['gestor'],
    ),
    // Categoria: Relatórios
    Tutorial(
      categoria: 'Relatórios',
      titulo: 'Como gerar um relatório?',
      conteudo:
          'Analise o desempenho da sua empresa:\n\n'
          '1. Entre na seção **"Relatórios"**.\n'
          '2. Escolha o tipo de relatório: **Financeiro** (lucros e despesas) ou **Produtividade** (atendimentos por técnico).\n'
          '3. Selecione o **Período** desejado (Início e Fim).\n'
          '4. Use os filtros adicionais para refinar por cliente ou status de OS.\n'
          '5. Toque em **"GERAR"**.\n\n'
          'Os relatórios podem ser visualizados em gráficos interativos ou exportados em formato de planilha.',
      videoUrlGestor: null,
      perfisPermitidos: ['gestor'],
    ),
  ];

  List<Tutorial> get _tutoriaisPermitidos => _perfil.isEmpty
      ? _todosTutoriais
      : _todosTutoriais
          .where((t) => t.perfisPermitidos.contains(_perfil))
          .toList();

  @override
  void initState() {
    super.initState();
    _authServico = widget.authServico ?? AutenticacaoServico();
    _tutoriaisFiltrados = _todosTutoriais;
    _buscaController.addListener(_filtrarTutoriais);
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final dados = await _authServico.buscarDadosUsuarioLogado();
    if (dados != null && mounted) {
      setState(() {
        _perfil = dados['perfil'] ?? '';
        _filtrarTutoriais();
      });
    }
  }

  void _filtrarTutoriais() {
    final query = _buscaController.text.toLowerCase();
    setState(() {
      final base = _tutoriaisPermitidos;
      if (query.isEmpty) {
        _tutoriaisFiltrados = base;
      } else {
        _tutoriaisFiltrados = base
            .where((t) =>
                t.titulo.toLowerCase().contains(query) ||
                t.conteudo.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Map<String, List<Tutorial>> get _tutoriaisAgrupados {
    final map = <String, List<Tutorial>>{};
    for (final tutorial in _tutoriaisFiltrados) {
      (map[tutorial.categoria] ??= []).add(tutorial);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutoriais e Ajuda'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _buscaController,
              decoration: const InputDecoration(
                labelText: 'Buscar tutorial...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _tutoriaisFiltrados.isEmpty
                ? _buildNenhumResultado()
                : AnimationLimiter(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _tutoriaisAgrupados.length,
                      itemBuilder: (context, index) {
                        final categoria =
                            _tutoriaisAgrupados.keys.elementAt(index);
                        final tutoriais = _tutoriaisAgrupados[categoria]!;
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: _buildCategoria(
                                context: context,
                                titulo: categoria,
                                icone: _getIconeCategoria(categoria),
                                cor: _getCorCategoria(categoria),
                                tutoriais: tutoriais,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNenhumResultado() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.white24),
          SizedBox(height: 16),
          Text(
            'Nenhum tutorial encontrado',
            style: TextStyle(fontSize: 18, color: Colors.white54),
          ),
          Text(
            'Tente buscar por outras palavras.',
            style: TextStyle(color: Colors.white38),
          ),
        ],
      ),
    );
  }

  IconData _getIconeCategoria(String categoria) {
    switch (categoria) {
      case 'Cadastros':
        return Icons.person_add_alt_1_outlined;
      case 'Agendamentos':
        return Icons.calendar_today_outlined;
      case 'Ordens de Serviço':
        return Icons.assignment_outlined;
      case 'Relatórios':
        return Icons.bar_chart_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _getCorCategoria(String categoria) {
    switch (categoria) {
      case 'Cadastros':
        return Colors.cyan;
      case 'Agendamentos':
        return Colors.amber;
      case 'Ordens de Serviço':
        return Colors.lightGreen;
      case 'Relatórios':
        return Colors.pinkAccent;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCategoria({
    required BuildContext context,
    required String titulo,
    required IconData icone,
    required Color cor,
    required List<Tutorial> tutoriais,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: _buscaController.text.isNotEmpty,
        leading: CircleAvatar(
          backgroundColor: cor.withAlpha(40),
          child: Icon(icone, color: cor),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
        children: tutoriais
            .map((tutorial) => _buildTopico(context, tutorial))
            .toList(),
      ),
    );
  }

  Widget _buildTopico(BuildContext context, Tutorial tutorial) {
    final temVideo = tutorial.videoUrlParaPerfil(_perfil) != null;
    return ListTile(
      leading: const Icon(Icons.help_outline, color: Colors.white70),
      title: Text(tutorial.titulo),
      trailing: temVideo
          ? const Icon(Icons.play_circle_outline, color: Colors.white38)
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalhesTutorialTela(
              tutorial: tutorial,
              perfil: _perfil,
            ),
          ),
        );
      },
    );
  }
}
