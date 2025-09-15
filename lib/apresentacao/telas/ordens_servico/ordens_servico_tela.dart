// lib/apresentacao/telas/ordens_servico/ordens_servico_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/ordem_servico/ordem_servico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/listar_ordens_servico.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:intl/intl.dart';
import 'cadastro_os_tela.dart';
import 'detalhes_os_tela.dart';

class OrdensServicoTela extends StatefulWidget {
  const OrdensServicoTela({super.key});

  @override
  State<OrdensServicoTela> createState() => _OrdensServicoTelaState();
}

class _OrdensServicoTelaState extends State<OrdensServicoTela> {
  late final ListarOrdensServico _listarOS;
  Future<List<OrdemServico>>? _futureOS;

  @override
  void initState() {
    super.initState();
    _listarOS = ListarOrdensServico(OrdemServicoRepositorioAdaptativo());
    _carregarOS();
  }

  void _carregarOS() {
    setState(() {
      _futureOS = _listarOS.executar();
    });
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

  // Helper para o ícone de prioridade
  Widget _getPrioridadeIcon(String prioridade) {
    switch (prioridade.toLowerCase()) {
      case 'alta':
        return CircleAvatar(
          backgroundColor: Colors.redAccent.withAlpha(40),
          child: const Icon(Icons.keyboard_double_arrow_up,
              color: Colors.redAccent),
        );
      case 'média':
        return CircleAvatar(
          backgroundColor: Colors.orangeAccent.withAlpha(40),
          child: const Icon(Icons.remove, color: Colors.orangeAccent),
        );
      default: // 'baixa'
        return CircleAvatar(
          backgroundColor: Colors.blueAccent.withAlpha(40),
          child: const Icon(Icons.keyboard_double_arrow_down,
              color: Colors.blueAccent),
        );
    }
  }

  // Helper para a cor do status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'concluída':
        return Colors.greenAccent;
      case 'reaberta':
        return Colors.redAccent;
      case 'em andamento':
        return Colors.lightBlueAccent;
      default: // 'pendente'
        return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormularioCadastro,
        icon: const Icon(Icons.add),
        label: const Text('NOVA OS'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _carregarOS(),
        child: FutureBuilder<List<OrdemServico>>(
          future: _futureOS,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('Nenhuma Ordem de Serviço encontrada.'));
            }
            final ordens = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
              itemCount: ordens.length,
              itemBuilder: (context, index) {
                final os = ordens[index];
                final statusColor = _getStatusColor(os.status);

                return Card(
                  // Borda colorida para indicar o status
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: statusColor.withAlpha(80), width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: _getPrioridadeIcon(
                        os.prioridade), // Ícone de prioridade
                    title: Text('OS #${os.id.substring(0, 6)}...'),
                    subtitle: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context)
                            .style
                            .copyWith(color: Colors.white70, fontSize: 12),
                        children: <TextSpan>[
                          const TextSpan(text: 'Status: '),
                          TextSpan(
                            text: os.status, // Texto do status colorido
                            style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                              text:
                                  '\nData: ${DateFormat('dd/MM/yyyy').format(os.dataHoraInicio)}'),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _abrirDetalhes(os),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
