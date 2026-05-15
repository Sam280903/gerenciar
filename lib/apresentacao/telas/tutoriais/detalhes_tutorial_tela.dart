// lib/apresentacao/telas/tutoriais/detalhes_tutorial_tela.dart
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:gerenciar/dominio/entidades/tutorial.dart';

class DetalhesTutorialTela extends StatefulWidget {
  final Tutorial tutorial;
  final String perfil;

  const DetalhesTutorialTela({
    super.key,
    required this.tutorial,
    this.perfil = '',
  });

  @override
  State<DetalhesTutorialTela> createState() => _DetalhesTutorialTelaState();
}

class _DetalhesTutorialTelaState extends State<DetalhesTutorialTela> {
  late Future<bool> _temConexaoFuture;
  YoutubePlayerController? _youtubeController;
  bool _feedbackEnviado = false;

  @override
  void initState() {
    super.initState();
    _temConexaoFuture = _verificarConexao();

    final videoUrl = widget.tutorial.videoUrlParaPerfil(widget.perfil);
    if (videoUrl != null) {
      final videoId = YoutubePlayer.convertUrlToId(videoUrl);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
      }
    }
  }

  Future<bool> _verificarConexao() async {
    final resultado = await Connectivity().checkConnectivity();
    return !resultado.contains(ConnectivityResult.none);
  }

  void _enviarFeedback() {
    setState(() => _feedbackEnviado = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Obrigado pelo seu feedback!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoUrl = widget.tutorial.videoUrlParaPerfil(widget.perfil);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tutorial.titulo),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<bool>(
              future: _temConexaoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final temInternet = snapshot.data ?? false;
                if (temInternet && _youtubeController != null) {
                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: YoutubePlayer(
                          controller: _youtubeController!,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                    ],
                  );
                } else if (!temInternet && videoUrl != null) {
                  return _buildAvisoOffline();
                }
                return const SizedBox.shrink();
              },
            ),
            Text(
              widget.tutorial.conteudo,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 16),
            _buildSecaoFeedback(),
          ],
        ),
      ),
    );
  }

  Widget _buildSecaoFeedback() {
    if (_feedbackEnviado) {
      return const Center(
        child: Text(
          'Agradecemos sua avaliação!',
          style: TextStyle(color: Colors.greenAccent),
        ),
      );
    }

    return Column(
      children: [
        const Text(
          'Este tutorial foi útil?',
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _enviarFeedback,
              icon: const Icon(Icons.thumb_up_outlined),
              label: const Text('Sim'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.greenAccent,
                side: const BorderSide(color: Colors.greenAccent),
              ),
            ),
            const SizedBox(width: 24),
            OutlinedButton.icon(
              onPressed: _enviarFeedback,
              icon: const Icon(Icons.thumb_down_outlined),
              label: const Text('Não'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvisoOffline() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(50)),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_outlined, color: Colors.amber),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Conecte-se à internet para assistir ao vídeo deste tutorial.',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
