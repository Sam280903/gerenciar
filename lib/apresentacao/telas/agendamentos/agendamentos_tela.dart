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

  List<AgendamentoDetalhado> _proximos = [];
  List<AgendamentoDetalhado> _concluidos = [];
  List<AgendamentoDetalhado> _antigos = [];
  List<AgendamentoDetalhado> _inativos = []; // Nova lista para inativos

  bool _carregando = true;
  bool _ordenarCrescente = true;

  @override
  void initState() {
    super.initState();
    // Controlador com 4 abas
    _tabController = TabController(length: 4, vsync: this);
    initializeDateFormatting('pt_BR', null);
    _carregarAgendamentos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarAgendamentos() async {
    setState(() => _carregando = true);

    final agendamentoRepo = AgendamentoRepositorioAdaptativo();
    final clienteRepo = ClienteRepositorioAdaptativo();
    final tecnicoRepo = TecnicoRepositorioAdaptativo();

    // Busca todos, incluindo inativos
    final agendamentos =
        await agendamentoRepo.listarTodos(incluirInativos: true);

    final hoje = DateUtils.dateOnly(DateTime.now());

    List<AgendamentoDetalhado> proximosTemp = [];
    List<AgendamentoDetalhado> concluidosTemp = [];
    List<AgendamentoDetalhado> antigosTemp = [];
    List<AgendamentoDetalhado> inativosTemp = [];

    for (final ag in agendamentos) {
      // --- CORREÇÃO DE SEGURANÇA CONTRA DADOS CORROMPIDOS ---
      // Se o ID do cliente ou técnico for nulo/vazio, pula para o próximo para não quebrar a tela.
      if (ag.idCliente.isEmpty || ag.idTecnico.isEmpty) {
        // print('Agendamento ${ag.id} ignorado por falta de ID de cliente ou técnico.');
        continue;
      }
      // --- FIM DA CORREÇÃO ---

      final cliente =
          await BuscarClientePorId(clienteRepo).executar(ag.idCliente);
      final tecnico =
          await BuscarTecnicoPorId(tecnicoRepo).executar(ag.idTecnico);
      final itemDetalhado = AgendamentoDetalhado(
        agendamento: ag,
        cliente: cliente,
        tecnico: tecnico,
      );

      // Nova lógica de separação com 4 listas
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

    // Ordenação
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
        _proximos = proximosTemp;
        _concluidos = concluidosTemp;
        _antigos = antigosTemp;
        _inativos = inativosTemp;
        _carregando = false;
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
          isScrollable: true, // Permite rolar as abas se não couberem na tela
          tabs: const [
            Tab(text: 'PRÓXIMOS'),
            Tab(text: 'CONCLUÍDOS'),
            Tab(text: 'ANTIGOS'),
            Tab(text: 'INATIVOS'), // Nova aba
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormularioCadastro,
        icon: const Icon(Icons.add),
        label: const Text('NOVO'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildListaAgendamentos(
                    _proximos, 'Nenhum agendamento próximo.'),
                _buildListaAgendamentos(
                    _concluidos, 'Nenhum agendamento concluído.'),
                _buildListaAgendamentos(_antigos, 'Nenhum agendamento antigo.'),
                _buildListaAgendamentos(
                    _inativos, 'Nenhum agendamento inativo.'), // Nova lista
              ],
            ),
    );
  }

  Widget _buildListaAgendamentos(
      List<AgendamentoDetalhado> lista, String mensagemVazia) {
    if (lista.isEmpty) {
      return Center(
          child: Text(mensagemVazia,
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
