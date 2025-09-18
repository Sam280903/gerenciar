// lib/apresentacao/telas/suporte/suporte_tela.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SuporteTela extends StatelessWidget {
  const SuporteTela({super.key});

  // Função para abrir o WhatsApp com a mensagem padrão
  Future<void> _abrirWhatsApp(BuildContext context, String telefone) async {
    // --- MENSAGEM CONFIGURADA CONFORME SUA ESCOLHA ---
    const String mensagem =
        'Olá, entro em contato para obter suporte com o aplicativo GerenciAR. Poderiam me ajudar, por favor?\n\nMinha dúvida é sobre: [Descreva sua dúvida ou problema aqui]';
    final String mensagemCodificada = Uri.encodeComponent(mensagem);

    // Adiciona o código do país (55 para o Brasil) e a mensagem
    final url = 'https://wa.me/55$telefone?text=$mensagemCodificada';
    final uri = Uri.parse(url);
    // --- FIM DA CONFIGURAÇÃO ---

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível abrir o WhatsApp.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // Função que mostra a caixa de diálogo para escolher o contato
  void _mostrarOpcoesWhatsapp(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Com quem você quer falar?'),
          content: const Text(
              'Escolha um dos desenvolvedores para iniciar a conversa.'),
          actions: <Widget>[
            TextButton.icon(
              icon: const Icon(Icons.support_agent),
              label: const Text('Flávio Amorim'),
              onPressed: () {
                Navigator.of(context).pop();
                _abrirWhatsApp(context, '64992042511');
              },
            ),
            TextButton.icon(
              icon: const Icon(Icons.support_agent),
              label: const Text('Samuel Augusto'),
              onPressed: () {
                Navigator.of(context).pop();
                _abrirWhatsApp(context, '64992164177');
              },
            ),
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suporte via WhatsApp'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.chat_bubble_outline,
                  size: 80, color: Colors.greenAccent),
              const SizedBox(height: 24),
              const Text(
                'Precisa de ajuda?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Toque no botão abaixo para iniciar uma conversa com nossa equipe de suporte diretamente no WhatsApp.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.chat),
                label: const Text('ENTRAR EM CONTATO'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _mostrarOpcoesWhatsapp(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
