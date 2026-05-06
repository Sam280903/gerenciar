// lib/apresentacao/telas/ordens_servico/detalhes_os_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/forma_pagamento/forma_pagamento_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/ordem_servico/ordem_servico_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/buscar_cliente_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/buscar_forma_pagamento_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/reabrir_ordem_servico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/buscar_tecnico_por_id.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico_detalhada.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:gerenciar/servicos/pdf_servico.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'editar_os_tela.dart';

class DetalhesOSTela extends StatefulWidget {
  final OrdemServico ordemServico;
  final AutenticacaoServico? authServico;
  final BuscarClientePorId? buscarCliente;
  final BuscarTecnicoPorId? buscarTecnico;

  const DetalhesOSTela({super.key, required this.ordemServico, this.authServico, this.buscarCliente, this.buscarTecnico});

  @override
  State<DetalhesOSTela> createState() => _DetalhesOSTelaState();
}

class _DetalhesOSTelaState extends State<DetalhesOSTela> {
  late Future<Map<String, dynamic>> _dadosFuture;
  late final AutenticacaoServico _authServico;
  late final BuscarClientePorId _buscarCliente;
  late final BuscarTecnicoPorId _buscarTecnico;
  late final BuscarFormaPagamentoPorId _buscarFormaPagamento;
  String _perfilUsuario = "";
  bool _carregandoAcao = false;

  @override
  void initState() {
    super.initState();
    _authServico = widget.authServico ?? AutenticacaoServico();
    _buscarCliente = widget.buscarCliente ?? BuscarClientePorId(ClienteRepositorioAdaptativo());
    _buscarTecnico = widget.buscarTecnico ?? BuscarTecnicoPorId(TecnicoRepositorioAdaptativo());
    _buscarFormaPagamento = BuscarFormaPagamentoPorId(FormaPagamentoRepositorioAdaptativo());
    _dadosFuture = _carregarDados();
  }

  Future<Map<String, dynamic>> _carregarDados() async {
    final clienteFuture = _buscarCliente.executar(widget.ordemServico.idCliente);
    final tecnicoFuture = _buscarTecnico.executar(widget.ordemServico.idTecnico);
    final dadosUsuarioFuture = _authServico.buscarDadosUsuarioLogado();
    final formaPagamentoFuture = _buscarFormaPagamento.executar(widget.ordemServico.idFormaPagamento);

    final resultados = await Future.wait([clienteFuture, tecnicoFuture, dadosUsuarioFuture, formaPagamentoFuture]);

    if (mounted && resultados[2] != null) {
      final dadosUsuario = resultados[2] as Map<String, dynamic>;
      setState(() {
        _perfilUsuario = dadosUsuario['perfil'] ?? '';
      });
    }

    return {
      'cliente': resultados[0] as Cliente?,
      'tecnico': resultados[1] as Tecnico?,
      'formaPagamento': resultados[3] as FormaPagamento?,
    };
  }

  Future<void> _reabrirOS() async {
    final justificativaController = TextEditingController();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reabrir Ordem de Serviço'),
        content: TextField(
          controller: justificativaController,
          decoration: const InputDecoration(
            labelText: 'Justificativa da Reabertura',
            hintText: 'Ex: Retorno em garantia.',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (justificativaController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('A justificativa é obrigatória.'),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }
              Navigator.of(context).pop(true);
            },
            child: const Text('REABRIR'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _carregandoAcao = true);
      try {
        await ReabrirOrdemServico(OrdemServicoRepositorioAdaptativo()).executar(
          id: widget.ordemServico.id,
          justificativa: justificativaController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('OS reaberta com sucesso!'),
            backgroundColor: Colors.green,
          ));
          Navigator.of(context).pop(true); // Retorna para recarregar a lista
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao reabrir OS: $e'),
            backgroundColor: Colors.redAccent,
          ));
        }
      } finally {
        if (mounted) {
          setState(() => _carregandoAcao = false);
        }
      }
    }
  }

  Future<void> _abrirMapa(String? endereco) async {
    if (endereco == null || endereco.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Endereço não disponível.'),
            backgroundColor: Colors.orangeAccent),
      );
      return;
    }
    final query = Uri.encodeComponent(endereco);
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Não foi possível abrir o mapa para: $endereco'),
              backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _abrirEdicao() async {
    final resultado = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => EditarOSTela(ordemServico: widget.ordemServico)));

    if (resultado == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _exportarPDF() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gerando PDF...')),
    );

    final dados = await _carregarDados();
    final cliente = dados['cliente'];
    final tecnico = dados['tecnico'];

    if (cliente == null || tecnico == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Não foi possível carregar os dados para o PDF.'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }

    final osDetalhada = OrdemServicoDetalhada(
      os: widget.ordemServico,
      cliente: cliente,
      tecnico: tecnico,
    );

    try {
      await PdfServico().gerarPdfOS(osDetalhada);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao gerar PDF: $e'),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OS #${widget.ordemServico.id.substring(0, 6)}...'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dadosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Erro ao carregar dados.'));
          }

          final cliente = snapshot.data!['cliente'] as Cliente?;
          final tecnico = snapshot.data!['tecnico'] as Tecnico?;
          final formaPagamento = snapshot.data!['formaPagamento'] as FormaPagamento?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInfoCard('Cliente', cliente?.nome ?? 'Não encontrado',
                    Icons.person_outline),
                const SizedBox(height: 16),
                _buildInfoCard(
                  'Endereço do Cliente',
                  cliente?.endereco ?? 'Não informado',
                  Icons.location_on_outlined,
                  onTap: () => _abrirMapa(cliente?.endereco),
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                    'Técnico Responsável',
                    tecnico?.nome ?? 'Não encontrado',
                    Icons.engineering_outlined),
                const SizedBox(height: 16),
                _buildInfoCard(
                    'Status', widget.ordemServico.status, Icons.flag_outlined,
                    valueColor: _getStatusColor(widget.ordemServico.status)),
                const SizedBox(height: 16),
                _buildInfoCard('Descrição do Problema',
                    widget.ordemServico.descricao, Icons.description_outlined),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                          'Data e Hora',
                          DateFormat('dd/MM/yyyy \'às\' HH:mm')
                              .format(widget.ordemServico.dataHoraInicio),
                          Icons.calendar_today_outlined),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildInfoCard(
                            'Prioridade',
                            widget.ordemServico.prioridade,
                            Icons.priority_high_outlined)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                    'Valor',
                    'R\$ ${widget.ordemServico.valor.toStringAsFixed(2)}',
                    Icons.monetization_on_outlined),
                const SizedBox(height: 16),
                _buildInfoCard(
                    'Forma de Pagamento',
                    formaPagamento?.nome ?? 'Não informado',
                    Icons.payment_outlined),
                const SizedBox(height: 40),
                if (_carregandoAcao)
                  const Center(child: CircularProgressIndicator())
                else
                  _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    final concluida = widget.ordemServico.status == 'Concluída';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!concluida) ...[
          ElevatedButton.icon(
            onPressed: _abrirEdicao,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('EDITAR'),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: _exportarPDF,
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('EXPORTAR PDF'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blueAccent,
            side: const BorderSide(color: Colors.blueAccent),
          ),
        ),
        if (concluida && _perfilUsuario == 'gestor') ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _reabrirOS,
            icon: const Icon(Icons.replay_outlined),
            label: const Text('REABRIR OS'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orangeAccent,
              side: const BorderSide(color: Colors.orangeAccent),
            ),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pendente':
        return Colors.orangeAccent;
      case 'concluída':
        return Colors.greenAccent;
      case 'reaberta':
      case 'reaberto': // legado
        return Colors.redAccent;
      default:
        return Colors.white;
    }
  }

  Widget _buildInfoCard(String title, String value, IconData icon,
      {Color? valueColor, VoidCallback? onTap}) {
    return Card(
      color: Colors.white.withAlpha(15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(icon, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14))
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      value.isNotEmpty ? value : 'Não informado',
                      style: TextStyle(
                        color: valueColor ?? Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.map_outlined, color: Colors.blueAccent),
            ],
          ),
        ),
      ),
    );
  }
}
