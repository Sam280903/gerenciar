// lib/apresentacao/telas/ordens_servico/detalhes_os_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/buscar_cliente_por_id.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/buscar_tecnico_por_id.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'editar_os_tela.dart';

class DetalhesOSTela extends StatefulWidget {
  final OrdemServico ordemServico;

  const DetalhesOSTela({super.key, required this.ordemServico});

  @override
  State<DetalhesOSTela> createState() => _DetalhesOSTelaState();
}

class _DetalhesOSTelaState extends State<DetalhesOSTela> {
  late Future<Map<String, dynamic>> _dadosFuture;

  @override
  void initState() {
    super.initState();
    _dadosFuture = _carregarDados();
  }

  Future<Map<String, dynamic>> _carregarDados() async {
    final clienteFuture = BuscarClientePorId(ClienteRepositorioAdaptativo())
        .executar(widget.ordemServico.idCliente);
    final tecnicoFuture = BuscarTecnicoPorId(TecnicoRepositorioAdaptativo())
        .executar(widget.ordemServico.idTecnico);

    final resultados = await Future.wait([clienteFuture, tecnicoFuture]);

    return {
      'cliente': resultados[0] as Cliente?,
      'tecnico': resultados[1] as Tecnico?,
    };
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
    // --- CORREÇÃO APLICADA AQUI ---
    final query = Uri.encodeComponent(endereco);
    final uri =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    // --- FIM DA CORREÇÃO ---

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
      // Retorna true para a tela anterior para recarregar a lista
      Navigator.of(context).pop(true);
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
                      // --- CORREÇÃO AQUI ---
                      child: _buildInfoCard(
                          'Data e Hora',
                          DateFormat('dd/MM/yyyy \'às\' HH:mm')
                              .format(widget.ordemServico.dataHoraInicio),
                          Icons.calendar_today_outlined),
                      // --- FIM DA CORREÇÃO ---
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
                const SizedBox(height: 40),
                _buildActionButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _abrirEdicao,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('EDITAR'),
          ),
        ),
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
