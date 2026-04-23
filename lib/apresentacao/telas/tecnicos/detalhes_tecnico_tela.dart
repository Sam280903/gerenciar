// lib/apresentacao/telas/tecnicos/detalhes_tecnico_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/inativar_tecnico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/reativar_tecnico.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/dominio/interfaces/tecnico_repositorio_interface.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'editar_tecnico_tela.dart';

class DetalhesTecnicoTela extends StatefulWidget {
  final Tecnico tecnico;
  final AutenticacaoServico? authServico;
  final TecnicoRepositorioInterface? tecnicoRepo;
  const DetalhesTecnicoTela({super.key, required this.tecnico, this.authServico, this.tecnicoRepo});
  @override
  State<DetalhesTecnicoTela> createState() => _DetalhesTecnicoTelaState();
}

class _DetalhesTecnicoTelaState extends State<DetalhesTecnicoTela> {
  bool _carregando = false;
  late Tecnico _tecnicoAtual;
  late final AutenticacaoServico _authServico;
  String _perfilUsuario = "";

  @override
  void initState() {
    super.initState();
    _authServico = widget.authServico ?? AutenticacaoServico();
    _tecnicoAtual = widget.tecnico;
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

  Future<void> _toggleAtivo() async {
    final bool vaiInativar = _tecnicoAtual.ativo;
    final acao = vaiInativar ? 'inativar' : 'reativar';
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar ${vaiInativar ? "Inativação" : "Reativação"}'),
        content: Text(
            'Tem certeza que deseja $acao o técnico ${_tecnicoAtual.nome}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            // CORREÇÃO: Argumento 'style' movido para antes de 'child'
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
        final repo = widget.tecnicoRepo ?? TecnicoRepositorioAdaptativo();
        if (vaiInativar) {
          await InativarTecnico(repo).executar(_tecnicoAtual.id);
        } else {
          await ReativarTecnico(repo).executar(_tecnicoAtual.id);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Técnico ${acao}do com sucesso!'),
              backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Erro ao $acao técnico: $e'),
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
            builder: (context) => EditarTecnicoTela(tecnico: _tecnicoAtual)));
    if (resultado == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Técnico')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(
                'Nome Completo', _tecnicoAtual.nome, Icons.person_outline),
            const SizedBox(height: 16),
            _buildInfoCard('E-mail', _tecnicoAtual.email, Icons.email_outlined),
            const SizedBox(height: 16),
            _buildInfoCard(
                'Telefone', _tecnicoAtual.telefone, Icons.phone_outlined),
            const SizedBox(height: 16),
            _buildInfoCard(
                'Status',
                _tecnicoAtual.ativo ? 'Ativo' : 'Inativo',
                _tecnicoAtual.ativo
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                valueColor: _tecnicoAtual.ativo
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
              icon: Icon(_tecnicoAtual.ativo
                  ? Icons.power_settings_new
                  : Icons.refresh),
              label: Text(_tecnicoAtual.ativo ? 'INATIVAR' : 'REATIVAR'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: _tecnicoAtual.ativo
                      ? Colors.redAccent
                      : Colors.greenAccent,
                  side: BorderSide(
                      color: _tecnicoAtual.ativo
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
      {Color? valueColor}) {
    return Card(
      color: Colors.white.withAlpha(15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(color: Colors.white70, fontSize: 14))
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
    );
  }
}
