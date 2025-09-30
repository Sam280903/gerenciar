// lib/apresentacao/telas/tutoriais/tutoriais_tela.dart
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:gerenciar/dominio/entidades/tutorial.dart';
import 'detalhes_tutorial_tela.dart';

class TutoriaisTela extends StatefulWidget {
  TutoriaisTela({super.key});

  @override
  State<TutoriaisTela> createState() => _TutoriaisTelaState();
}

class _TutoriaisTelaState extends State<TutoriaisTela> {
  final _buscaController = TextEditingController();
  List<Tutorial> _tutoriaisFiltrados = [];

  // Lista completa de todos os tutoriais
  final List<Tutorial> _todosTutoriais = [
    // Categoria: Cadastros
    Tutorial(
      categoria: 'Cadastros',
      titulo: 'Como cadastrar um novo Cliente?',
      conteudo:
          'Para cadastrar um novo cliente, vá até a tela "Clientes" no menu principal e toque no botão "+ NOVO CLIENTE".\n\nPreencha os campos obrigatórios como Nome, CPF e Telefone. Se desejar, você pode usar o "Cadastro Rápido" para adicionar apenas as informações essenciais.',
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    ),
    Tutorial(
      categoria: 'Cadastros',
      titulo: 'Como cadastrar um novo Técnico?',
      conteudo:
          'O cadastro de técnicos é uma função exclusiva do Gestor.\n\nAcesse a tela "Técnicos" e toque em "+ NOVO TÉCNICO". Preencha o nome, e-mail e a senha que ele usará para acessar o aplicativo.',
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    ),
    // Categoria: Agendamentos
    Tutorial(
      categoria: 'Agendamentos',
      titulo: 'Como criar um novo agendamento?',
      conteudo:
          'Na tela "Agendamentos", toque no botão "+ NOVO".\n\nSelecione o cliente, o técnico, a data e a hora. O sistema irá verificar automaticamente se o técnico está livre naquele horário para evitar conflitos.',
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    ),
    Tutorial(
      categoria: 'Agendamentos',
      titulo: 'Como concluir ou inativar um agendamento?',
      conteudo:
          'Toque em um agendamento na lista para ver seus detalhes. Na tela de detalhes, você encontrará os botões para "Concluir", "Cancelar" ou "Inativar" o agendamento.',
      // --- CORREÇÃO APLICADA AQUI ---
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    ),
    // Categoria: Ordens de Serviço
    Tutorial(
      categoria: 'Ordens de Serviço',
      titulo: 'Como gerar uma Ordem de Serviço?',
      conteudo:
          'Acesse a tela "Ordens de Serviço" e toque em "+ NOVA OS".\n\nSelecione o cliente, o técnico, a data e descreva o problema. Você também pode definir a prioridade e a forma de pagamento.',
      // --- CORREÇÃO APLICADA AQUI ---
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    ),
    Tutorial(
      categoria: 'Ordens de Serviço',
      titulo: 'Como reabrir uma OS concluída?',
      conteudo:
          'Apenas gestores podem reabrir uma OS.\n\nNa tela de detalhes de uma OS concluída, o gestor encontrará o botão para reabrir, onde deverá informar uma justificativa. Isso é útil para casos de garantia do serviço.',
      // --- CORREÇÃO APLICADA AQUI ---
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    ),
    // Categoria: Relatórios
    Tutorial(
      categoria: 'Relatórios',
      titulo: 'Como gerar um relatório?',
      conteudo:
          'Acesse a tela "Relatórios" no menu.\n\nVocê pode filtrar as Ordens de Serviço por período, técnico, cliente ou status. Após selecionar os filtros desejados, toque em "GERAR RELATÓRIO".',
      // --- CORREÇÃO APLICADA AQUI ---
      videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tutoriaisFiltrados = _todosTutoriais;
    _buscaController.addListener(_filtrarTutoriais);
  }

  void _filtrarTutoriais() {
    final query = _buscaController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _tutoriaisFiltrados = _todosTutoriais;
      } else {
        _tutoriaisFiltrados = _todosTutoriais
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
    return ListTile(
      leading: const Icon(Icons.help_outline, color: Colors.white70),
      title: Text(tutorial.titulo),
      trailing: tutorial.videoUrl != null
          ? const Icon(Icons.play_circle_outline, color: Colors.white38)
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetalhesTutorialTela(tutorial: tutorial),
          ),
        );
      },
    );
  }
}
