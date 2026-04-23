// lib/apresentacao/telas/clientes/detalhes_cliente_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/inativar_cliente.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/reativar_cliente.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/interfaces/cliente_repositorio_interface.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:url_launcher/url_launcher.dart';
import 'editar_cliente_tela.dart';

class DetalhesClienteTela extends StatefulWidget {
  final Cliente cliente;
  final AutenticacaoServico? authServico;
  final ClienteRepositorioInterface? clienteRepo;
  const DetalhesClienteTela({super.key, required this.cliente, this.authServico, this.clienteRepo});
  @override
  State<DetalhesClienteTela> createState() => _DetalhesClienteTelaState();
}

class _DetalhesClienteTelaState extends State<DetalhesClienteTela> {
  bool _carregando = false;
  late Cliente _clienteAtual;
  late final AutenticacaoServico _authServico;
  String _perfilUsuario = "";

  @override
  void initState() {
    super.initState();
    _authServico = widget.authServico ?? AutenticacaoServico();
    _clienteAtual = widget.cliente;
    _carregarPerfilUsuario();
  }

  Future<void> _carregarPerfilUsuario() async {
    final dados = await _authServico.buscarDadosUsuarioLogado();
    if (mounted && dados != null) {
      setState(() {
        _perfilUsuario = dados['perfil'] ?? '';
      });
    }
  }

  Future<void> _abrirMapa(String endereco) async {
    if (endereco.isEmpty) {
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

  Future<void> _toggleAtivo() async {
    final bool vaiInativar = _clienteAtual.ativo;
    final acao = vaiInativar ? 'inativar' : 'reativar';
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar ${vaiInativar ? "Inativação" : "Reativação"}'),
        content: Text(
            'Tem certeza que deseja $acao o cliente ${_clienteAtual.nome}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor:
                    vaiInativar ? Colors.redAccent : Colors.greenAccent),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(acao.toUpperCase()),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _carregando = true);
      try {
        final repo = widget.clienteRepo ?? ClienteRepositorioAdaptativo();
        if (vaiInativar) {
          await InativarCliente(repo).executar(_clienteAtual.id);
        } else {
          await ReativarCliente(repo).executar(_clienteAtual.id);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Cliente ${acao}do com sucesso!'),
              backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Erro ao $acao cliente: $e'),
              backgroundColor: Colors.redAccent));
        }
      } finally {
        if (mounted) setState(() => _carregando = false);
      }
    }
  }

  void _abrirEdicao() async {
    final resultado = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (context) => EditarClienteTela(cliente: _clienteAtual, clienteRepo: widget.clienteRepo)));
    if (resultado == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Cliente')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(
                'Nome Completo', _clienteAtual.nome, Icons.person_outline),
            const SizedBox(height: 16),
            _buildInfoCard(
                'CPF', _clienteAtual.cpf ?? '', Icons.badge_outlined),
            const SizedBox(height: 16),
            _buildInfoCard(
                'Telefone', _clienteAtual.telefone, Icons.phone_outlined),
            const SizedBox(height: 16),
            _buildInfoCard('E-mail', _clienteAtual.email, Icons.email_outlined),
            const SizedBox(height: 16),
            _buildInfoCard(
                'Endereço', _clienteAtual.endereco, Icons.location_on_outlined,
                onTap: () => _abrirMapa(_clienteAtual.endereco)),
            const SizedBox(height: 16),
            _buildInfoCard(
                'Status',
                _clienteAtual.ativo ? 'Ativo' : 'Inativo',
                _clienteAtual.ativo
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                valueColor: _clienteAtual.ativo
                    ? Colors.greenAccent
                    : Colors.redAccent),
            const SizedBox(height: 40),
            if (_carregando)
              const Center(child: CircularProgressIndicator())
            else
              _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (_perfilUsuario == 'gestor')
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _toggleAtivo,
              icon: Icon(_clienteAtual.ativo
                  ? Icons.power_settings_new
                  : Icons.refresh),
              label: Text(_clienteAtual.ativo ? 'INATIVAR' : 'REATIVAR'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: _clienteAtual.ativo
                      ? Colors.redAccent
                      : Colors.greenAccent,
                  side: BorderSide(
                      color: _clienteAtual.ativo
                          ? Colors.redAccent
                          : Colors.greenAccent)),
            ),
          ),
        if (_perfilUsuario == 'gestor') const SizedBox(width: 16),
        Expanded(
            child: ElevatedButton.icon(
                onPressed: _abrirEdicao,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('EDITAR'))),
      ],
    );
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
                    Text(value.isNotEmpty ? value : 'Não informado',
                        style: TextStyle(
                            color: valueColor ?? Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
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
