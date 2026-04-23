// lib/apresentacao/telas/ordens_servico/ordens_servico_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/ordem_servico/ordem_servico_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/buscar_cliente_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/listar_ordens_servico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/buscar_tecnico_por_id.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico_detalhada.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:intl/intl.dart';

// --- IMPORTS ADICIONADOS PARA INJEÇÃO DE DEPENDÊNCIA ---
import 'package:gerenciar/dominio/casos_uso/cliente/listar_clientes.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/listar_tecnicos.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/listar_formas_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/cadastrar_ordem_servico.dart';
import 'package:gerenciar/dominio/interfaces/agendamento_repositorio_interface.dart';
// --------------------------------------------------------

import 'cadastro_os_tela.dart';
import 'detalhes_os_tela.dart';

class OrdensServicoTela extends StatefulWidget {
  final ListarOrdensServico? listarOS;
  final BuscarClientePorId? buscarCliente;
  final BuscarTecnicoPorId? buscarTecnico;

  // Dependências para a tela de cadastro que será chamada
  final ListarClientes? listarClientes;
  final ListarTecnicos? listarTecnicos;
  final ListarFormasPagamento? listarFormasPagamento;
  final CadastrarOrdemServico? cadastrarOS;
  final AgendamentoRepositorioInterface? agendamentoRepo;

  final AutenticacaoServico? authServico;

  const OrdensServicoTela(
      {super.key,
      this.listarOS,
      this.buscarCliente,
      this.buscarTecnico,
      this.listarClientes,
      this.listarTecnicos,
      this.listarFormasPagamento,
      this.cadastrarOS,
      this.agendamentoRepo,
      this.authServico});

  @override
  State<OrdensServicoTela> createState() => _OrdensServicoTelaState();
}

class _OrdensServicoTelaState extends State<OrdensServicoTela>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _buscaController = TextEditingController();

  late final ListarOrdensServico _listarOS;
  late final BuscarClientePorId _buscarCliente;
  late final BuscarTecnicoPorId _buscarTecnico;

  List<OrdemServicoDetalhada> _todosPendentes = [];
  List<OrdemServicoDetalhada> _todosEmAndamento = [];
  List<OrdemServicoDetalhada> _todosConcluidas = [];
  List<OrdemServicoDetalhada> _todosReabertas = [];

  List<OrdemServicoDetalhada> _pendentesFiltrados = [];
  List<OrdemServicoDetalhada> _emAndamentoFiltrados = [];
  List<OrdemServicoDetalhada> _concluidasFiltrados = [];
  List<OrdemServicoDetalhada> _reabertasFiltrados = [];

  late final AutenticacaoServico _authServico;
  String? _idGestor;
  String? _perfilUsuario;
  String? _idUsuarioLogado;

  bool _carregando = true;
  bool _ordenarCrescente = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    _listarOS = widget.listarOS ??
        ListarOrdensServico(OrdemServicoRepositorioAdaptativo());
    _buscarCliente = widget.buscarCliente ??
        BuscarClientePorId(ClienteRepositorioAdaptativo());
    _buscarTecnico = widget.buscarTecnico ??
        BuscarTecnicoPorId(TecnicoRepositorioAdaptativo());
    _authServico = widget.authServico ?? AutenticacaoServico();

    _carregarDadosIniciais();
    _buscaController.addListener(_filtrarOS);
  }

  Future<void> _carregarDadosIniciais() async {
    final dadosUsuario = await _authServico.buscarDadosUsuarioLogado();
    if (mounted && dadosUsuario != null) {
      setState(() {
        _idGestor = dadosUsuario['idGestor'];
        _perfilUsuario = dadosUsuario['perfil'];
        _idUsuarioLogado = _authServico.usuarioAtual?.uid;
      });
      _carregarOS();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  void _filtrarOS() {
    final query = _buscaController.text.toLowerCase();
    setState(() {
      _pendentesFiltrados = _todosPendentes.where((item) {
        final nomeCliente = item.cliente?.nome.toLowerCase() ?? '';
        final nomeTecnico = item.tecnico?.nome.toLowerCase() ?? '';
        return nomeCliente.contains(query) || nomeTecnico.contains(query);
      }).toList();
      _emAndamentoFiltrados = _todosEmAndamento.where((item) {
        final nomeCliente = item.cliente?.nome.toLowerCase() ?? '';
        final nomeTecnico = item.tecnico?.nome.toLowerCase() ?? '';
        return nomeCliente.contains(query) || nomeTecnico.contains(query);
      }).toList();
      _concluidasFiltrados = _todosConcluidas.where((item) {
        final nomeCliente = item.cliente?.nome.toLowerCase() ?? '';
        final nomeTecnico = item.tecnico?.nome.toLowerCase() ?? '';
        return nomeCliente.contains(query) || nomeTecnico.contains(query);
      }).toList();
      _reabertasFiltrados = _todosReabertas.where((item) {
        final nomeCliente = item.cliente?.nome.toLowerCase() ?? '';
        final nomeTecnico = item.tecnico?.nome.toLowerCase() ?? '';
        return nomeCliente.contains(query) || nomeTecnico.contains(query);
      }).toList();
    });
  }

  Future<void> _carregarOS() async {
    if (_idGestor == null) return;

    setState(() => _carregando = true);

    final ordensDeServico = await _listarOS.executar(idGestor: _idGestor!);

    // Cache de futures por ID — evita buscar o mesmo cliente/técnico mais de uma vez
    final cacheClientes = <String, Future<dynamic>>{};
    final cacheTecnicos = <String, Future<dynamic>>{};

    Future<dynamic> buscarCliente(String id) =>
        cacheClientes.putIfAbsent(id, () => _buscarCliente.executar(id));
    Future<dynamic> buscarTecnico(String id) =>
        cacheTecnicos.putIfAbsent(id, () => _buscarTecnico.executar(id));

    final osFiltradas = ordensDeServico.where((os) {
      if (_perfilUsuario == 'tecnico' && os.idTecnico != _idUsuarioLogado) return false;
      return true;
    }).toList();

    // Busca cliente e técnico de todas as OS em paralelo
    final detalhadas = await Future.wait(
      osFiltradas.map((os) async {
        final clienteFuture = buscarCliente(os.idCliente);
        final tecnicoFuture = buscarTecnico(os.idTecnico);
        return OrdemServicoDetalhada(
          os: os,
          cliente: await clienteFuture,
          tecnico: await tecnicoFuture,
        );
      }),
    );

    List<OrdemServicoDetalhada> pendentesTemp = [];
    List<OrdemServicoDetalhada> emAndamentoTemp = [];
    List<OrdemServicoDetalhada> concluidasTemp = [];
    List<OrdemServicoDetalhada> reabertasTemp = [];

    for (final itemDetalhado in detalhadas) {
      switch (itemDetalhado.os.status) {
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
        _todosPendentes = pendentesTemp;
        _todosEmAndamento = emAndamentoTemp;
        _todosConcluidas = concluidasTemp;
        _todosReabertas = reabertasTemp;
        _carregando = false;
        _filtrarOS();
      });
    }
  }

  void _abrirFormularioCadastro() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CadastroOSTela(
                listarClientes: widget.listarClientes,
                listarTecnicos: widget.listarTecnicos,
                listarFormasPagamento: widget.listarFormasPagamento,
                cadastrarOS: widget.cadastrarOS,
                agendamentoRepo: widget.agendamentoRepo,
                authServico: _authServico,
              )),
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
                _carregarOS();
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
                      _buildListaOS(
                          _pendentesFiltrados, 'Nenhuma OS pendente.'),
                      _buildListaOS(
                          _emAndamentoFiltrados, 'Nenhuma OS em andamento.'),
                      _buildListaOS(
                          _concluidasFiltrados, 'Nenhuma OS concluída.'),
                      _buildListaOS(
                          _reabertasFiltrados, 'Nenhuma OS reaberta.'),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListaOS(
      List<OrdemServicoDetalhada> lista, String mensagemVazia) {
    if (lista.isEmpty) {
      return Center(
          child: Text(
              _buscaController.text.isNotEmpty
                  ? 'Nenhum resultado encontrado.'
                  : mensagemVazia,
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
