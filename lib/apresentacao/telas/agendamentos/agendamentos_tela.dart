// lib/apresentacao/telas/agendamentos/agendamentos_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/agendamento/agendamento_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/buscar_cliente_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/buscar_tecnico_por_id.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:gerenciar/dominio/entidades/agendamento_detalhado.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'cadastro_agendamento_tela.dart';
import 'detalhes_agendamento_tela.dart';

class AgendamentosTela extends StatefulWidget {
  const AgendamentosTela({super.key});

  @override
  State<AgendamentosTela> createState() => _AgendamentosTelaState();
}

class _AgendamentosTelaState extends State<AgendamentosTela>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _buscaController = TextEditingController();

  // Listas para armazenar todos os dados carregados
  List<AgendamentoDetalhado> _todosProximos = [];
  List<AgendamentoDetalhado> _todosConcluidos = [];
  List<AgendamentoDetalhado> _todosAntigos = [];
  List<AgendamentoDetalhado> _todosInativos = [];

  // Listas para exibir os dados filtrados
  List<AgendamentoDetalhado> _proximosFiltrados = [];
  List<AgendamentoDetalhado> _concluidosFiltrados = [];
  List<AgendamentoDetalhado> _antigosFiltrados = [];
  List<AgendamentoDetalhado> _inativosFiltrados = [];

  bool _carregando = true;
  bool _ordenarCrescente = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    initializeDateFormatting('pt_BR', null);
    _carregarAgendamentos();
    _buscaController.addListener(_filtrarAgendamentos);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  void _filtrarAgendamentos() {
    final query = _buscaController.text.toLowerCase();
    setState(() {
      _proximosFiltrados = _todosProximos.where((item) {
        final nomeCliente = item.cliente?.nome.toLowerCase() ?? '';
        final nomeTecnico = item.tecnico?.nome.toLowerCase() ?? '';
        return nomeCliente.contains(query) || nomeTecnico.contains(query);
      }).toList();
      _concluidosFiltrados = _todosConcluidos.where((item) {
        final nomeCliente = item.cliente?.nome.toLowerCase() ?? '';
        final nomeTecnico = item.tecnico?.nome.toLowerCase() ?? '';
        return nomeCliente.contains(query) || nomeTecnico.contains(query);
      }).toList();
      _antigosFiltrados = _todosAntigos.where((item) {
        final nomeCliente = item.cliente?.nome.toLowerCase() ?? '';
        final nomeTecnico = item.tecnico?.nome.toLowerCase() ?? '';
        return nomeCliente.contains(query) || nomeTecnico.contains(query);
      }).toList();
      _inativosFiltrados = _todosInativos.where((item) {
        final nomeCliente = item.cliente?.nome.toLowerCase() ?? '';
        final nomeTecnico = item.tecnico?.nome.toLowerCase() ?? '';
        return nomeCliente.contains(query) || nomeTecnico.contains(query);
      }).toList();
    });
  }

  Future<void> _carregarAgendamentos() async {
    // ... (código de carregamento existente)
    setState(() => _carregando = true);
    final agendamentoRepo = AgendamentoRepositorioAdaptativo();
    final clienteRepo = ClienteRepositorioAdaptativo();
    final tecnicoRepo = TecnicoRepositorioAdaptativo();
    final agendamentos =
        await agendamentoRepo.listarTodos(incluirInativos: true);
    final hoje = DateUtils.dateOnly(DateTime.now());
    List<AgendamentoDetalhado> proximosTemp = [];
    List<AgendamentoDetalhado> concluidosTemp = [];
    List<AgendamentoDetalhado> antigosTemp = [];
    List<AgendamentoDetalhado> inativosTemp = [];
    for (final ag in agendamentos) {
      if (ag.idCliente.isEmpty || ag.idTecnico.isEmpty) {
        continue;
      }
      final cliente =
          await BuscarClientePorId(clienteRepo).executar(ag.idCliente);
      final tecnico =
          await BuscarTecnicoPorId(tecnicoRepo).executar(ag.idTecnico);
      final itemDetalhado = AgendamentoDetalhado(
        agendamento: ag,
        cliente: cliente,
        tecnico: tecnico,
      );
      if (!ag.ativo) {
        inativosTemp.add(itemDetalhado);
      } else if (ag.status == 'Concluído') {
        concluidosTemp.add(itemDetalhado);
      } else if (DateUtils.dateOnly(ag.dataHora).isBefore(hoje)) {
        antigosTemp.add(itemDetalhado);
      } else {
        proximosTemp.add(itemDetalhado);
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

    ordenar(proximosTemp);
    ordenar(concluidosTemp);
    ordenar(antigosTemp);
    ordenar(inativosTemp);

    if (mounted) {
      setState(() {
        _todosProximos = proximosTemp;
        _todosConcluidos = concluidosTemp;
        _todosAntigos = antigosTemp;
        _todosInativos = inativosTemp;
        _carregando = false;
        _filtrarAgendamentos(); // Aplica o filtro inicial
      });
    }
  }

  void _abrirFormularioCadastro() async {
    final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const CadastroAgendamentoTela()));
    if (resultado == true) {
      _carregarAgendamentos();
    }
  }

  void _abrirDetalhes(Agendamento agendamento) async {
    final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => DetalhesAgendamentoTela(agendamento: agendamento)));
    if (resultado == true) {
      _carregarAgendamentos();
    }
  }

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
            Tab(text: 'PRÓXIMOS'),
            Tab(text: 'CONCLUÍDOS'),
            Tab(text: 'ANTIGOS'),
            Tab(text: 'INATIVOS'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormularioCadastro,
        icon: const Icon(Icons.add),
        label: const Text('NOVO'),
      ),
      body: Column(
        children: [
          // --- CAMPO DE BUSCA ADICIONADO ---
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
          // --- FIM DO CAMPO DE BUSCA ---
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildListaAgendamentos(
                          _proximosFiltrados, 'Nenhum agendamento próximo.'),
                      _buildListaAgendamentos(_concluidosFiltrados,
                          'Nenhum agendamento concluído.'),
                      _buildListaAgendamentos(
                          _antigosFiltrados, 'Nenhum agendamento antigo.'),
                      _buildListaAgendamentos(
                          _inativosFiltrados, 'Nenhum agendamento inativo.'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ... (buildListaAgendamentos, buildAgendamentoCard, getStatusColor, getStatusIcon)
  // O restante do código permanece igual
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
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
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
      color: agendamento.ativo ? null : Colors.grey.shade800.withAlpha(150),
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: agendamento.ativo
                ? TextDecoration.none
                : TextDecoration.lineThrough,
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
      default: // Pendente
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
      default: // Pendente
        return Icons.pending_actions;
    }
  }
}
