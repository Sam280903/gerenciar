// lib/apresentacao/telas/agendamentos/agendamentos_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/agendamento/agendamento_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/listar_agendamentos.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/buscar_cliente_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/buscar_tecnico_por_id.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:gerenciar/dominio/entidades/agendamento_detalhado.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart'; // ADICIONADO
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:url_launcher/url_launcher.dart';
import 'cadastro_agendamento_tela.dart';
import 'detalhes_agendamento_tela.dart';

class AgendamentosTela extends StatefulWidget {
  final AgendamentoRepositorioAdaptativo? agendamentoRepo;
  final ClienteRepositorioAdaptativo? clienteRepo;
  final TecnicoRepositorioAdaptativo? tecnicoRepo;
  final AutenticacaoServico? authServico;

  const AgendamentosTela(
      {super.key, this.agendamentoRepo, this.clienteRepo, this.tecnicoRepo, this.authServico});

  @override
  State<AgendamentosTela> createState() => _AgendamentosTelaState();
}

class _AgendamentosTelaState extends State<AgendamentosTela>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _buscaController = TextEditingController();

  late final AgendamentoRepositorioAdaptativo _agendamentoRepo;
  late final ClienteRepositorioAdaptativo _clienteRepo;
  late final TecnicoRepositorioAdaptativo _tecnicoRepo;

  List<AgendamentoDetalhado> _todosPendentes = [];
  List<AgendamentoDetalhado> _todosConfirmados = [];
  List<AgendamentoDetalhado> _todosConcluidos = [];
  List<AgendamentoDetalhado> _todosAntigos = [];
  List<AgendamentoDetalhado> _todosCancelados = [];

  List<AgendamentoDetalhado> _pendentesFiltrados = [];
  List<AgendamentoDetalhado> _confirmadosFiltrados = [];
  List<AgendamentoDetalhado> _concluidosFiltrados = [];
  List<AgendamentoDetalhado> _antigosFiltrados = [];
  List<AgendamentoDetalhado> _canceladosFiltrados = [];

  late final AutenticacaoServico _authServico;
  String? _idGestor;
  String? _perfilUsuario;
  String? _idUsuarioLogado;

  bool _carregando = true;
  bool _ordenarCrescente = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    _agendamentoRepo =
        widget.agendamentoRepo ?? AgendamentoRepositorioAdaptativo();
    _clienteRepo = widget.clienteRepo ?? ClienteRepositorioAdaptativo();
    _tecnicoRepo = widget.tecnicoRepo ?? TecnicoRepositorioAdaptativo();
    _authServico = widget.authServico ?? AutenticacaoServico();

    initializeDateFormatting('pt_BR', null);
    _carregarDadosIniciais(); // MÉTODO ALTERADO
    _buscaController.addListener(_filtrarAgendamentos);
  }

  // NOVO MÉTODO
  Future<void> _carregarDadosIniciais() async {
    final dadosUsuario = await _authServico.buscarDadosUsuarioLogado();
    if (mounted && dadosUsuario != null) {
      setState(() {
        _idGestor = dadosUsuario['idGestor'];
        _perfilUsuario = dadosUsuario['perfil'];
        _idUsuarioLogado = _authServico.usuarioAtual?.uid;
      });
      _carregarAgendamentos();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  void _filtrarAgendamentos() {
    final query = _buscaController.text.toLowerCase();
    bool casa(AgendamentoDetalhado item) {
      final nomeCliente = item.cliente?.nome.toLowerCase() ?? '';
      final nomeTecnico = item.tecnico?.nome.toLowerCase() ?? '';
      return nomeCliente.contains(query) || nomeTecnico.contains(query);
    }
    setState(() {
      _pendentesFiltrados = _todosPendentes.where(casa).toList();
      _confirmadosFiltrados = _todosConfirmados.where(casa).toList();
      _concluidosFiltrados = _todosConcluidos.where(casa).toList();
      _antigosFiltrados = _todosAntigos.where(casa).toList();
      _canceladosFiltrados = _todosCancelados.where(casa).toList();
    });
  }

  Future<void> _carregarAgendamentos() async {
    if (_idGestor == null) return;

    setState(() => _carregando = true);

    try {
      final agendamentos = await ListarAgendamentos(_agendamentoRepo)
          .executar(idGestor: _idGestor!);

      final agora = DateTime.now();

      // Cache de futures por ID — evita buscar o mesmo cliente/técnico mais de uma vez
      final cacheClientes = <String, Future<dynamic>>{};
      final cacheTecnicos = <String, Future<dynamic>>{};

      Future<dynamic> buscarCliente(String id) =>
          cacheClientes.putIfAbsent(id, () => BuscarClientePorId(_clienteRepo).executar(id));
      Future<dynamic> buscarTecnico(String id) =>
          cacheTecnicos.putIfAbsent(id, () => BuscarTecnicoPorId(_tecnicoRepo).executar(id));

      final agFiltrados = agendamentos.where((ag) {
        if (ag.idCliente.isEmpty || ag.idTecnico.isEmpty) return false;
        if (_perfilUsuario == 'tecnico' && ag.idTecnico != _idUsuarioLogado) return false;
        return true;
      }).toList();

      // Busca cliente e técnico de todos os agendamentos em paralelo
      final detalhados = await Future.wait(
        agFiltrados.map((ag) async {
          final clienteFuture = buscarCliente(ag.idCliente);
          final tecnicoFuture = buscarTecnico(ag.idTecnico);
          return AgendamentoDetalhado(
            agendamento: ag,
            cliente: await clienteFuture,
            tecnico: await tecnicoFuture,
          );
        }),
      );

      List<AgendamentoDetalhado> pendentesTemp = [];
      List<AgendamentoDetalhado> confirmadosTemp = [];
      List<AgendamentoDetalhado> concluidosTemp = [];
      List<AgendamentoDetalhado> antigosTemp = [];
      List<AgendamentoDetalhado> canceladosTemp = [];

      for (final itemDetalhado in detalhados) {
        final ag = itemDetalhado.agendamento;
        if (ag.status == 'Cancelado') {
          canceladosTemp.add(itemDetalhado);
        } else if (ag.status == 'Concluído') {
          concluidosTemp.add(itemDetalhado);
        } else if (ag.status == 'Confirmado') {
          // Confirmado sempre fica na aba Confirmados, independente da data
          confirmadosTemp.add(itemDetalhado);
        } else if (ag.dataHora.isBefore(agora)) {
          // Pendente com data/hora já passada vai para Antigos
          antigosTemp.add(itemDetalhado);
        } else {
          pendentesTemp.add(itemDetalhado);
        }
      }

      void ordenar(List<AgendamentoDetalhado> lista) {
        lista.sort((a, b) {
          if (_ordenarCrescente) {
            return a.agendamento.dataHora.compareTo(b.agendamento.dataHora);
          }
          return b.agendamento.dataHora.compareTo(a.agendamento.dataHora);
        });
      }

      ordenar(pendentesTemp);
      ordenar(confirmadosTemp);
      ordenar(concluidosTemp);
      ordenar(antigosTemp);
      ordenar(canceladosTemp);

      if (mounted) {
        setState(() {
          _todosPendentes = pendentesTemp;
          _todosConfirmados = confirmadosTemp;
          _todosConcluidos = concluidosTemp;
          _todosAntigos = antigosTemp;
          _todosCancelados = canceladosTemp;
          _filtrarAgendamentos();
        });
      }
    } catch (_) {
      // Garante que o spinner não trava em caso de falha no repositório
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _abrirFormularioCadastro() async {
    final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const CadastroAgendamentoTela()));
    if (resultado == true) {
      _carregarAgendamentos();
    }
  }

  Future<void> _abrirDetalhes(Agendamento agendamento) async {
    final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DetalhesAgendamentoTela(agendamento: agendamento)));
    if (resultado == true) {
      _carregarAgendamentos();
    }
  }

  // --- FUNÇÃO CORRIGIDA E FINALIZADA ---
  Future<void> _otimizarRota() async {
    final hoje = DateUtils.dateOnly(DateTime.now());

    final agendamentosDoDia = _todosConfirmados
        .where((item) =>
            DateUtils.dateOnly(item.agendamento.dataHora) == hoje &&
            item.cliente?.endereco.isNotEmpty == true)
        .toList()
      ..sort(
          (a, b) => a.agendamento.dataHora.compareTo(b.agendamento.dataHora));

    if (agendamentosDoDia.length < 2) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'São necessários pelo menos 2 agendamentos confirmados com endereço para otimizar a rota do dia.'),
            backgroundColor: Colors.orangeAccent,
          ),
        );
      }
      return;
    }

    // Constrói a URL para o Google Maps Directions
    // O último endereço na lista cronológica será o destino final.
    // Todos os outros serão pontos de parada (waypoints).
    final enderecos =
        agendamentosDoDia.map((item) => item.cliente!.endereco).toList();
    final destino = Uri.encodeComponent(enderecos.removeLast());
    final waypoints = enderecos.map(Uri.encodeComponent).join('|');

    final url =
        'https://www.google.com/maps/dir/?api=1&destination=$destino&waypoints=$waypoints';
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o mapa para traçar a rota.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
  // --- FIM DA CORREÇÃO ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendamentos'),
        actions: [
          IconButton(
            tooltip: 'Ordenar por data',
            icon: Icon(
                _ordenarCrescente ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: () {
              setState(() => _ordenarCrescente = !_ordenarCrescente);
              _carregarAgendamentos();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'PENDENTES'),
            Tab(text: 'CONFIRMADOS'),
            Tab(text: 'CONCLUÍDOS'),
            Tab(text: 'ANTIGOS'),
            Tab(text: 'CANCELADOS'),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'novoAgendamento',
            onPressed: _abrirFormularioCadastro,
            icon: const Icon(Icons.add),
            label: const Text('NOVO'),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'otimizarRota',
            onPressed: _otimizarRota,
            icon: const Icon(Icons.route_outlined),
            label: const Text('OTIMIZAR ROTA DO DIA'),
            backgroundColor: Colors.blueAccent,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _buscaController,
              decoration: const InputDecoration(
                labelText: 'Buscar por cliente ou técnico...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildListaAgendamentos(
                          _pendentesFiltrados, 'Nenhum agendamento pendente.'),
                      _buildListaAgendamentos(_confirmadosFiltrados,
                          'Nenhum agendamento confirmado.'),
                      _buildListaAgendamentos(_concluidosFiltrados,
                          'Nenhum agendamento concluído.'),
                      _buildListaAgendamentos(
                          _antigosFiltrados, 'Nenhum agendamento antigo.'),
                      _buildListaAgendamentos(
                          _canceladosFiltrados, 'Nenhum agendamento cancelado.'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaAgendamentos(
      List<AgendamentoDetalhado> lista, String mensagemVazia) {
    if (lista.isEmpty) {
      return Center(
          child: Text(
              _buscaController.text.isNotEmpty
                  ? 'Nenhum resultado encontrado.'
                  : mensagemVazia,
              style: const TextStyle(color: Colors.white70)));
    }
    return RefreshIndicator(
      onRefresh: _carregarAgendamentos,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 160),
        itemCount: lista.length,
        itemBuilder: (context, index) {
          final item = lista[index];
          return _buildAgendamentoCard(item);
        },
      ),
    );
  }

  Widget _buildAgendamentoCard(AgendamentoDetalhado item) {
    final agendamento = item.agendamento;
    final statusColor = _getStatusColor(agendamento.status);
    return Card(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: statusColor.withAlpha(80), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Icon(_getStatusIcon(agendamento.status),
            color: statusColor, size: 32),
        title: Text(
          item.cliente?.nome ?? 'Cliente não encontrado',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Técnico: ${item.tecnico?.nome ?? 'Não definido'}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              agendamento.observacao?.isNotEmpty ?? false
                  ? agendamento.observacao!
                  : 'Sem observações',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white70,
                fontStyle: (agendamento.observacao?.isEmpty ?? true)
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat('dd/MM/yyyy \'às\' HH:mm')
                  .format(agendamento.dataHora),
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
        trailing: Text(
          agendamento.status,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
        onTap: () => _abrirDetalhes(agendamento),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Concluído':
        return Colors.greenAccent;
      case 'Confirmado':
        return Colors.blueAccent;
      case 'Cancelado':
        return Colors.redAccent;
      default:
        return Colors.orangeAccent;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Concluído':
        return Icons.task_alt;
      case 'Confirmado':
        return Icons.check_circle_outline;
      case 'Cancelado':
        return Icons.cancel_outlined;
      default:
        return Icons.pending_actions;
    }
  }
}
