// lib/apresentacao/telas/ordens_servico/ordens_servico_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/ordem_servico/ordem_servico_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/buscar_cliente_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/buscar_tecnico_por_id.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico_detalhada.dart';
import 'package:intl/intl.dart';
import 'cadastro_os_tela.dart';
import 'detalhes_os_tela.dart';

class OrdensServicoTela extends StatefulWidget {
  const OrdensServicoTela({super.key});

  @override
  State<OrdensServicoTela> createState() => _OrdensServicoTelaState();
}

class _OrdensServicoTelaState extends State<OrdensServicoTela>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<OrdemServicoDetalhada> _pendentes = [];
  List<OrdemServicoDetalhada> _emAndamento = [];
  List<OrdemServicoDetalhada> _concluidas = [];
  List<OrdemServicoDetalhada> _reabertas = [];

  bool _carregando = true;
  bool _ordenarCrescente = false; // false = Decrescente (padrão)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _carregarOS();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _carregarOS() async {
    setState(() => _carregando = true);

    final osRepo = OrdemServicoRepositorioAdaptativo();
    final clienteRepo = ClienteRepositorioAdaptativo();
    final tecnicoRepo = TecnicoRepositorioAdaptativo();

    final ordensDeServico = await osRepo.listarTodos();

    List<OrdemServicoDetalhada> pendentesTemp = [];
    List<OrdemServicoDetalhada> emAndamentoTemp = [];
    List<OrdemServicoDetalhada> concluidasTemp = [];
    List<OrdemServicoDetalhada> reabertasTemp = [];

    for (final os in ordensDeServico) {
      final cliente =
          await BuscarClientePorId(clienteRepo).executar(os.idCliente);
      final tecnico =
          await BuscarTecnicoPorId(tecnicoRepo).executar(os.idTecnico);
      final itemDetalhado = OrdemServicoDetalhada(
        os: os,
        cliente: cliente,
        tecnico: tecnico,
      );

      switch (os.status) {
        case 'Pendente':
          pendentesTemp.add(itemDetalhado);
          break;
        case 'Em Andamento':
          emAndamentoTemp.add(itemDetalhado);
          break;
        case 'Concluída':
          concluidasTemp.add(itemDetalhado);
          break;
        case 'Reaberta':
          reabertasTemp.add(itemDetalhado);
          break;
      }
    }

    // Função para ordenar as listas
    void ordenar(List<OrdemServicoDetalhada> lista) {
      lista.sort((a, b) {
        if (_ordenarCrescente) {
          return a.os.dataHoraInicio.compareTo(b.os.dataHoraInicio);
        }
        return b.os.dataHoraInicio.compareTo(a.os.dataHoraInicio);
      });
    }

    ordenar(pendentesTemp);
    ordenar(emAndamentoTemp);
    ordenar(concluidasTemp);
    ordenar(reabertasTemp);

    if (mounted) {
      setState(() {
        _pendentes = pendentesTemp;
        _emAndamento = emAndamentoTemp;
        _concluidas = concluidasTemp;
        _reabertas = reabertasTemp;
        _carregando = false;
      });
    }
  }

  void _abrirFormularioCadastro() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CadastroOSTela()),
    );
    if (resultado == true) {
      _carregarOS();
    }
  }

  void _abrirDetalhes(OrdemServico os) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetalhesOSTela(ordemServico: os)),
    );
    if (resultado == true) {
      _carregarOS();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),
        actions: [
          IconButton(
            icon: Icon(
                _ordenarCrescente ? Icons.arrow_downward : Icons.arrow_upward),
            tooltip: 'Ordenar por data',
            onPressed: () {
              setState(() {
                _ordenarCrescente = !_ordenarCrescente;
                _carregarOS(); // Recarrega e reordena
              });
            },
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'PENDENTES'),
            Tab(text: 'EM ANDAMENTO'),
            Tab(text: 'CONCLUÍDAS'),
            Tab(text: 'REABERTAS'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormularioCadastro,
        icon: const Icon(Icons.add),
        label: const Text('NOVA OS'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildListaOS(_pendentes, 'Nenhuma OS pendente.'),
                _buildListaOS(_emAndamento, 'Nenhuma OS em andamento.'),
                _buildListaOS(_concluidas, 'Nenhuma OS concluída.'),
                _buildListaOS(_reabertas, 'Nenhuma OS reaberta.'),
              ],
            ),
    );
  }

  Widget _buildListaOS(
      List<OrdemServicoDetalhada> lista, String mensagemVazia) {
    if (lista.isEmpty) {
      return Center(
          child: Text(mensagemVazia,
              style: const TextStyle(color: Colors.white70)));
    }
    return RefreshIndicator(
      onRefresh: _carregarOS,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
        itemCount: lista.length,
        itemBuilder: (context, index) {
          final item = lista[index];
          final os = item.os;
          final statusColor = _getStatusColor(os.status);

          return Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: statusColor.withAlpha(80), width: 1.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: _getPrioridadeIcon(os.prioridade),
              title: Text(item.cliente?.nome ?? 'Cliente não encontrado',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                  'Técnico: ${item.tecnico?.nome ?? 'Não definido'}\nData: ${DateFormat('dd/MM/yyyy HH:mm').format(os.dataHoraInicio)}'),
              isThreeLine: true,
              trailing: Text(
                os.status,
                style:
                    TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              ),
              onTap: () => _abrirDetalhes(os),
            ),
          );
        },
      ),
    );
  }

  Widget _getPrioridadeIcon(String prioridade) {
    switch (prioridade) {
      case 'Alta':
        return CircleAvatar(
          backgroundColor: Colors.redAccent.withAlpha(40),
          child: const Icon(Icons.keyboard_double_arrow_up,
              color: Colors.redAccent),
        );
      case 'Média':
        return CircleAvatar(
          backgroundColor: Colors.orangeAccent.withAlpha(40),
          child: const Icon(Icons.remove, color: Colors.orangeAccent),
        );
      default: // Baixa
        return CircleAvatar(
          backgroundColor: Colors.blueAccent.withAlpha(40),
          child: const Icon(Icons.keyboard_double_arrow_down,
              color: Colors.blueAccent),
        );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Concluída':
        return Colors.greenAccent;
      case 'Reaberta':
        return Colors.redAccent;
      case 'Em Andamento':
        return Colors.lightBlueAccent;
      default: // Pendente
        return Colors.orangeAccent;
    }
  }
}
