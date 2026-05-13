// lib/apresentacao/telas/relatorios/relatorio_resultado_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/apresentacao/telas/ordens_servico/detalhes_os_tela.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico_detalhada.dart';
import 'package:gerenciar/servicos/relatorio_servico.dart';
import 'package:intl/intl.dart';

class RelatorioResultadoTela extends StatelessWidget {
  final List<OrdemServicoDetalhada> ordensDeServico;
  final FiltrosRelatorio filtros;

  const RelatorioResultadoTela({
    super.key,
    required this.ordensDeServico,
    required this.filtros,
  });

  void _abrirDetalhes(BuildContext context, OrdemServico os) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetalhesOSTela(ordemServico: os)),
    );
  }

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
      default:
        return CircleAvatar(
          backgroundColor: Colors.blueAccent.withAlpha(40),
          child: const Icon(Icons.keyboard_double_arrow_down,
              color: Colors.blueAccent),
        );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'concluída':
        return Colors.greenAccent;
      case 'reaberta':
        return Colors.redAccent;
      case 'em andamento':
        return Colors.lightBlueAccent;
      case 'cancelada':
        return Colors.grey;
      default:
        return Colors.orangeAccent;
    }
  }

  Widget _buildHeader() {
    final double valorTotal = ordensDeServico.fold(0.0, (sum, item) => sum + item.os.valor);
    final formatadorMoeda =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    String periodo = 'Período: Completo';
    if (filtros.dataInicial != null && filtros.dataFinal != null) {
      periodo =
          'De: ${DateFormat('dd/MM/yy').format(filtros.dataInicial!)} até ${DateFormat('dd/MM/yy').format(filtros.dataFinal!)}';
    } else if (filtros.dataInicial != null) {
      periodo =
          'A partir de: ${DateFormat('dd/MM/yy').format(filtros.dataInicial!)}';
    } else if (filtros.dataFinal != null) {
      periodo = 'Até: ${DateFormat('dd/MM/yy').format(filtros.dataFinal!)}';
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Resumo do Relatório',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(periodo, style: const TextStyle(color: Colors.white70)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total de OS:', style: TextStyle(fontSize: 16)),
                Text(
                  ordensDeServico.length.toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Valor Total:', style: TextStyle(fontSize: 16)),
                Text(
                  formatadorMoeda.format(valorTotal),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado do Relatório'),
      ),
      body: Column(
        children: [
          _buildHeader(),
          if (ordensDeServico.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                    'Nenhuma Ordem de Serviço encontrada para os filtros selecionados.'),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
                itemCount: ordensDeServico.length,
                itemBuilder: (context, index) {
                  final item = ordensDeServico[index];
                  final os = item.os;
                  final statusColor = _getStatusColor(os.status);

                  return Card(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: statusColor.withAlpha(80), width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: _getPrioridadeIcon(os.prioridade),
                      title: Text(
                          item.cliente?.nome ?? 'Cliente não encontrado',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              'Técnico: ${item.tecnico?.nome ?? 'Não definido'}'),
                          Text(
                            'Detalhe: ${os.descricao}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: Text(
                        os.status,
                        style: TextStyle(
                            color: statusColor, fontWeight: FontWeight.bold),
                      ),
                      onTap: () => _abrirDetalhes(context, os),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
