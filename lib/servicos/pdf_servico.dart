// lib/servicos/pdf_servico.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico_detalhada.dart';
import 'package:gerenciar/servicos/relatorio_servico.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfServico {
  Future<void> gerarPdfOS(OrdemServicoDetalhada osDetalhada) async {
    final pdf = pw.Document();
    final os = osDetalhada.os;

    // Carrega a imagem do logo e a fonte dos assets
    final logoImage = pw.MemoryImage(
        (await rootBundle.load('assets/imagens/logo_gerenciar.png'))
            .buffer
            .asUint8List());

    final fontRegular =
        pw.Font.ttf(await rootBundle.load("assets/fontes/Roboto-Regular.ttf"));

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: fontRegular),
          margin: const pw.EdgeInsets.all(32),
        ),
        header: (context) => _buildHeader(logoImage),
        footer: (context) => _buildFooter(),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
                'Ordem de Serviço - Nº ${os.id.substring(0, 8).toUpperCase()}',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          ),

          _buildTitle('Detalhes do Atendimento'),
          _buildDetailRow('Status:', os.status.toUpperCase()),
          _buildDetailRow('Data de Abertura:',
              DateFormat('dd/MM/yyyy \'às\' HH:mm').format(os.dataHoraInicio)),
          if (os.dataHoraFim != null)
            _buildDetailRow('Data de Conclusão:',
                DateFormat('dd/MM/yyyy \'às\' HH:mm').format(os.dataHoraFim!)),

          _buildDivider(),

          _buildTitle('Informações do Cliente'),
          _buildDetailRow(
              'Nome:', osDetalhada.cliente?.nome ?? 'Não informado'),
          _buildDetailRow(
              'Telefone:', osDetalhada.cliente?.telefone ?? 'Não informado'),
          _buildDetailRow(
              'Endereço:', osDetalhada.cliente?.endereco ?? 'Não informado'),

          _buildDivider(),

          _buildTitle('Informações do Técnico'),
          _buildDetailRow(
              'Responsável:', osDetalhada.tecnico?.nome ?? 'Não informado'),

          _buildDivider(),

          _buildTitle('Descrição do Serviço'),
          pw.Paragraph(
            text: os.descricao,
            style: const pw.TextStyle(fontSize: 12),
          ),

          _buildDivider(),

          _buildTotal(os.valor),

          // Espaço para assinaturas (Requisito de formalização)
          pw.SizedBox(height: 50),
          _buildSignatureRow(),
        ],
      ),
    );

    // Salva o arquivo em diretório temporário e abre
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/os_${os.id.substring(0, 8)}.pdf");
    await file.writeAsBytes(await pdf.save());

    // Abre o arquivo gerado automaticamente
    await OpenFile.open(file.path);
  }

  Future<void> gerarPdfRelatorio(
    List<OrdemServicoDetalhada> ordens,
    FiltrosRelatorio filtros,
  ) async {
    final pdf = pw.Document();

    final logoImage = pw.MemoryImage(
        (await rootBundle.load('assets/imagens/logo_gerenciar.png'))
            .buffer
            .asUint8List());

    final fontRegular =
        pw.Font.ttf(await rootBundle.load("assets/fontes/Roboto-Regular.ttf"));

    final sorted = List<OrdemServicoDetalhada>.from(ordens)
      ..sort((a, b) => (a.cliente?.nome ?? '').compareTo(b.cliente?.nome ?? ''));

    final valorTotal = sorted.fold(0.0, (sum, item) => sum + item.os.valor);
    final formatadorMoeda =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final formatadorData = DateFormat('dd/MM/yyyy');

    String periodo = 'Período: Completo';
    if (filtros.dataInicial != null && filtros.dataFinal != null) {
      periodo =
          'De: ${formatadorData.format(filtros.dataInicial!)} até ${formatadorData.format(filtros.dataFinal!)}';
    } else if (filtros.dataInicial != null) {
      periodo = 'A partir de: ${formatadorData.format(filtros.dataInicial!)}';
    } else if (filtros.dataFinal != null) {
      periodo = 'Até: ${formatadorData.format(filtros.dataFinal!)}';
    }

    // --- Agrupamentos para resumo financeiro ---
    final Map<String, _ResumoGrupo> porTecnico = {};
    final Map<String, _ResumoGrupo> porCliente = {};
    for (final item in sorted) {
      final nomeTecnico = item.tecnico?.nome ?? 'Não definido';
      final nomeCliente = item.cliente?.nome ?? 'Não definido';
      porTecnico.putIfAbsent(nomeTecnico, () => _ResumoGrupo(nomeTecnico));
      porCliente.putIfAbsent(nomeCliente, () => _ResumoGrupo(nomeCliente));
      porTecnico[nomeTecnico]!.adicionar(item.os.valor);
      porCliente[nomeCliente]!.adicionar(item.os.valor);
    }
    final tecnicosSorted = porTecnico.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));
    final clientesSorted = porCliente.values.toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: fontRegular),
          margin: const pw.EdgeInsets.all(32),
        ),
        header: (context) => _buildHeaderRelatorio(logoImage),
        footer: (context) => _buildFooter(),
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Relatório de Ordens de Serviço',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 14)),
          ),

          // Resumo geral
          _buildDetailRow('Período:', periodo),
          _buildDetailRow('Total de OS:', sorted.length.toString()),
          _buildDetailRow(
              'Valor Total:', formatadorMoeda.format(valorTotal)),
          _buildDivider(),

          // Tabela: Faturamento por Técnico
          _buildTitle('Faturamento por Técnico'),
          _buildFinancialTable(
            headers: ['Técnico', 'Qtd. OS', 'Total'],
            rows: tecnicosSorted
                .map((g) => [
                      g.nome,
                      g.quantidade.toString(),
                      formatadorMoeda.format(g.total),
                    ])
                .toList(),
            formatadorMoeda: formatadorMoeda,
            totalGeral: valorTotal,
          ),
          _buildDivider(),

          // Tabela: Faturamento por Cliente
          _buildTitle('Faturamento por Cliente'),
          _buildFinancialTable(
            headers: ['Cliente', 'Qtd. OS', 'Total'],
            rows: clientesSorted
                .map((g) => [
                      g.nome,
                      g.quantidade.toString(),
                      formatadorMoeda.format(g.total),
                    ])
                .toList(),
            formatadorMoeda: formatadorMoeda,
            totalGeral: valorTotal,
          ),
          _buildDivider(),

          // Tabela detalhada de OS
          _buildTitle('Detalhamento das Ordens de Serviço'),
          pw.Table(
            border:
                pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.5),
              1: pw.FlexColumnWidth(2),
              2: pw.FlexColumnWidth(1.5),
              3: pw.FlexColumnWidth(1.2),
              4: pw.FlexColumnWidth(1.5),
              5: pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration:
                    const pw.BoxDecoration(color: PdfColors.blue900),
                children: [
                  'Cliente',
                  'Técnico',
                  'Status',
                  'Prioridade',
                  'Data',
                  'Valor',
                ]
                    .map((h) => pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(
                              horizontal: 6, vertical: 5),
                          child: pw.Text(h,
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 9,
                                  color: PdfColors.white)),
                        ))
                    .toList(),
              ),
              ...sorted.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final bg = i.isEven ? PdfColors.white : PdfColors.grey100;
                final cells = [
                  item.cliente?.nome ?? 'N/A',
                  item.tecnico?.nome ?? 'N/A',
                  item.os.status,
                  item.os.prioridade,
                  formatadorData.format(item.os.dataHoraInicio),
                  formatadorMoeda.format(item.os.valor),
                ];
                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: bg),
                  children: cells
                      .map((c) => pw.Padding(
                            padding: const pw.EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            child: pw.Text(c,
                                style: const pw.TextStyle(fontSize: 9)),
                          ))
                      .toList(),
                );
              }),
            ],
          ),
        ],
      ),
    );

    final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final output = await getTemporaryDirectory();
    final file =
        File("${output.path}/relatorio_os_$timestamp.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFile.open(file.path);
  }

  pw.Widget _buildHeader(pw.MemoryImage logo) {
    return pw.Container(
      // A borda deve estar dentro de BoxDecoration
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(bottom: pw.BorderSide(color: PdfColors.grey, width: 0.5)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 10),
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Image(logo, height: 40),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('GERENCIAR',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 18,
                      color: PdfColors.blue800)),
              pw.Text('Relatório de Ordem de Serviço',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey700)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildHeaderRelatorio(pw.MemoryImage logo) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(bottom: pw.BorderSide(color: PdfColors.grey, width: 0.5)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 10),
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Image(logo, height: 40),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('GERENCIAR',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 18,
                      color: PdfColors.blue800)),
              pw.Text('Relatório Consolidado de OS',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey700)),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8, top: 12),
      child: pw.Text(
        title,
        style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            fontSize: 13,
            color: PdfColors.blue900),
      ),
    );
  }

  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(label,
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDivider() {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Divider(color: PdfColors.grey300, thickness: 0.5),
    );
  }

  pw.Widget _buildTotal(double valor) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      padding: const pw.EdgeInsets.all(10),
      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text('VALOR TOTAL: ',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.Text(
            NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valor),
            style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 16,
                color: PdfColors.green900),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSignatureRow() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        pw.Column(
          children: [
            // O Container aqui serve apenas para desenhar a linha (BorderSide)
            pw.Container(
              width: 180,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    top: pw.BorderSide(width: 0.5, color: PdfColors.black)),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text("Assinatura do Técnico",
                style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
        pw.Column(
          children: [
            pw.Container(
              width: 180,
              decoration: const pw.BoxDecoration(
                border: pw.Border(
                    top: pw.BorderSide(width: 0.5, color: PdfColors.black)),
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text("Assinatura do Cliente",
                style: const pw.TextStyle(fontSize: 9)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 20),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(top: pw.BorderSide(color: PdfColors.grey, width: 0.5)),
      ),
      child: pw.Text(
        'GerenciAR - Sistema de Gestão de Atendimentos Técnicos | UniRV - TFC',
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
      ),
    );
  }

  pw.Widget _buildFinancialTable({
    required List<String> headers,
    required List<List<String>> rows,
    required NumberFormat formatadorMoeda,
    required double totalGeral,
  }) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: const {
        0: pw.FlexColumnWidth(4),
        1: pw.FlexColumnWidth(1.5),
        2: pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue900),
          children: headers
              .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 5),
                    child: pw.Text(h,
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                            color: PdfColors.white)),
                  ))
              .toList(),
        ),
        ...rows.asMap().entries.map((entry) {
          final bg =
              entry.key.isEven ? PdfColors.white : PdfColors.grey100;
          return pw.TableRow(
            decoration: pw.BoxDecoration(color: bg),
            children: entry.value
                .map((c) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: pw.Text(c,
                          style: const pw.TextStyle(fontSize: 10)),
                    ))
                .toList(),
          );
        }),
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: pw.Text('TOTAL',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ),
            pw.SizedBox(),
            pw.Padding(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: pw.Text(formatadorMoeda.format(totalGeral),
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10)),
            ),
          ],
        ),
      ],
    );
  }
}

class _ResumoGrupo {
  final String nome;
  int quantidade = 0;
  double total = 0.0;

  _ResumoGrupo(this.nome);

  void adicionar(double valor) {
    quantidade++;
    total += valor;
  }
}
