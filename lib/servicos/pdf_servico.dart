// lib/servicos/pdf_servico.dart

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico_detalhada.dart';
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
    final font =
        pw.Font.ttf(await rootBundle.load("assets/fontes/Roboto-Regular.ttf"));

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: font),
        ),
        header: (context) => _buildHeader(logoImage),
        build: (context) => [
          pw.Header(text: 'Ordem de Serviço - Nº ${os.id.substring(0, 8)}'),
          _buildTitle('Detalhes da Ordem de Serviço'),
          _buildDetailRow('Status:', os.status),
          _buildDetailRow('Data de Abertura:',
              DateFormat('dd/MM/yyyy \'às\' HH:mm').format(os.dataHoraInicio)),
          if (os.dataHoraFim != null)
            _buildDetailRow('Data de Conclusão:',
                DateFormat('dd/MM/yyyy \'às\' HH:mm').format(os.dataHoraFim!)),

          // --- CORREÇÃO APLICADA AQUI ---
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 16),
            child: pw.Divider(),
          ),

          _buildTitle('Informações do Cliente'),
          _buildDetailRow('Nome:', osDetalhada.cliente?.nome ?? 'N/A'),
          _buildDetailRow('Telefone:', osDetalhada.cliente?.telefone ?? 'N/A'),
          _buildDetailRow('Endereço:', osDetalhada.cliente?.endereco ?? 'N/A'),

          // --- CORREÇÃO APLICADA AQUI ---
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 16),
            child: pw.Divider(),
          ),

          _buildTitle('Informações do Técnico'),
          _buildDetailRow(
              'Técnico Responsável:', osDetalhada.tecnico?.nome ?? 'N/A'),

          // --- CORREÇÃO APLICADA AQUI ---
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 16),
            child: pw.Divider(),
          ),

          _buildTitle('Descrição do Serviço'),
          pw.Paragraph(text: os.descricao),

          // --- CORREÇÃO APLICADA AQUI ---
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 16),
            child: pw.Divider(),
          ),

          _buildTotal(os.valor),
        ],
        footer: (context) => _buildFooter(),
      ),
    );

    // Salva o arquivo e abre
    final output = await getTemporaryDirectory();
    final file = File("${output.path}/os_${os.id.substring(0, 8)}.pdf");
    await file.writeAsBytes(await pdf.save());

    // Abre o arquivo gerado
    await OpenFile.open(file.path);
  }

  pw.Widget _buildHeader(pw.MemoryImage logo) {
    return pw.Container(
      decoration: const pw.BoxDecoration(
        border:
            pw.Border(bottom: pw.BorderSide(color: PdfColors.grey, width: 0.5)),
      ),
      padding: const pw.EdgeInsets.only(bottom: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Image(logo, height: 50),
          pw.Text('Relatório de Serviço',
              style:
                  pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  pw.Widget _buildTitle(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10, top: 20),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
      ),
    );
  }

  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(label,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(
            child: pw.Text(value),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildTotal(double valor) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Text(
        'Valor Total: ${NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(valor)}',
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 18,
          color: PdfColors.green800,
        ),
      ),
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
        child: pw.Text('GerenciAR - Sistema de Gestão de Atendimentos Técnicos',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)));
  }
}
