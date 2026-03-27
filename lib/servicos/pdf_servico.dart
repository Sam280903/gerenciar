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
}
