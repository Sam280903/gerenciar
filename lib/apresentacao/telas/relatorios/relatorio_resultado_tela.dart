// lib/apresentacao/telas/relatorios/relatorio_resultado_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/apresentacao/telas/ordens_servico/detalhes_os_tela.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico_detalhada.dart';
import 'package:gerenciar/servicos/pdf_servico.dart';
import 'package:gerenciar/servicos/relatorio_servico.dart';
import 'package:intl/intl.dart';

class RelatorioResultadoTela extends StatefulWidget {
  final List<OrdemServicoDetalhada> ordensDeServico;
  final FiltrosRelatorio filtros;

  const RelatorioResultadoTela({
    super.key,
    required this.ordensDeServico,
    required this.filtros,
  });

  @override
  State<RelatorioResultadoTela> createState() => _RelatorioResultadoTelaState();
}

class _RelatorioResultadoTelaState extends State<RelatorioResultadoTela> {
  bool _exportando = false;

  Future<void> _exportarPDF() async {
    if (!mounted) return;
    setState(() => _exportando = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gerando PDF do relatório...')),
    );
    try {
      await PdfServico()
          .gerarPdfRelatorio(widget.ordensDeServico, widget.filtros);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao gerar PDF: $e'),
            backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _exportando = false);
    }
  }

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
    final sortedOrdens =
        List<OrdemServicoDetalhada>.from(widget.ordensDeServico)
          ..sort((a, b) =>
              (a.cliente?.nome ?? '').compareTo(b.cliente?.nome ?? ''));
    final double valorTotal =
        sortedOrdens.fold(0.0, (sum, item) => sum + item.os.valor);
    final formatadorMoeda =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    String periodo = 'Período: Completo';
    if (widget.filtros.dataInicial != null &&
        widget.filtros.dataFinal != null) {
      periodo =
          'De: ${DateFormat('dd/MM/yy').format(widget.filtros.dataInicial!)} até ${DateFormat('dd/MM/yy').format(widget.filtros.dataFinal!)}';
    } else if (widget.filtros.dataInicial != null) {
      periodo =
          'A partir de: ${DateFormat('dd/MM/yy').format(widget.filtros.dataInicial!)}';
    } else if (widget.filtros.dataFinal != null) {
      periodo =
          'Até: ${DateFormat('dd/MM/yy').format(widget.filtros.dataFinal!)}';
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
                  widget.ordensDeServico.length.toString(),
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
        actions: [
          if (widget.ordensDeServico.isNotEmpty)
            _exportando
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    tooltip: 'Exportar PDF',
                    onPressed: _exportarPDF,
                  ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          if (widget.ordensDeServico.isEmpty)
            const Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Nenhuma Ordem de Serviço encontrada para os filtros selecionados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: Builder(
                builder: (context) {
                  final sortedOrdens =
                      List<OrdemServicoDetalhada>.from(widget.ordensDeServico)
                        ..sort((a, b) => (a.cliente?.nome ?? '')
                            .compareTo(b.cliente?.nome ?? ''));
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 80),
                    itemCount: sortedOrdens.length,
                    itemBuilder: (context, index) {
                      final item = sortedOrdens[index];
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
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold)),
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
                                color: statusColor,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () => _abrirDetalhes(context, os),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
