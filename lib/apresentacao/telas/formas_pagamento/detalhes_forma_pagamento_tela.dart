// lib/apresentacao/telas/formas_pagamento/detalhes_forma_pagamento_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/forma_pagamento/forma_pagamento_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/inativar_forma_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/reativar_forma_pagamento.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'editar_forma_pagamento_tela.dart';

class DetalhesFormaPagamentoTela extends StatefulWidget {
  final FormaPagamento formaPagamento;

  const DetalhesFormaPagamentoTela({super.key, required this.formaPagamento});

  @override
  State<DetalhesFormaPagamentoTela> createState() =>
      _DetalhesFormaPagamentoTelaState();
}

class _DetalhesFormaPagamentoTelaState
    extends State<DetalhesFormaPagamentoTela> {
  late FormaPagamento _formaAtual;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _formaAtual = widget.formaPagamento;
  }

  Future<void> _toggleAtivo() async {
    final bool vaiInativar = _formaAtual.ativo;
    final acao = vaiInativar ? 'inativar' : 'reativar';
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar ${vaiInativar ? "Inativação" : "Reativação"}'),
        content: Text(
            'Tem certeza que deseja $acao a forma de pagamento ${_formaAtual.nome}?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor:
                    vaiInativar ? Colors.redAccent : Colors.greenAccent),
            child: Text(acao.toUpperCase()),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() => _carregando = true);
      try {
        if (vaiInativar) {
          await InativarFormaPagamento(FormaPagamentoRepositorioAdaptativo())
              .executar(_formaAtual.id);
        } else {
          await ReativarFormaPagamento(FormaPagamentoRepositorioAdaptativo())
              .executar(_formaAtual.id);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Forma de pagamento ${acao}da com sucesso!'),
              backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Erro ao $acao: $e'),
              backgroundColor: Colors.redAccent));
        }
      } finally {
        if (mounted) setState(() => _carregando = false);
      }
    }
  }

  void _abrirEdicao() async {
    final resultado = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: EditarFormaPagamentoTela(formaPagamento: _formaAtual),
      ),
    );
    if (resultado == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard('Nome', _formaAtual.nome, Icons.payment),
            const SizedBox(height: 16),
            _buildInfoCard('Descrição', _formaAtual.descricao ?? 'N/A',
                Icons.description_outlined),
            const SizedBox(height: 16),
            _buildInfoCard(
                'Status',
                _formaAtual.ativo ? 'Ativo' : 'Inativo',
                _formaAtual.ativo
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                valueColor:
                    _formaAtual.ativo ? Colors.greenAccent : Colors.redAccent),
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
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _toggleAtivo,
            icon: Icon(
                _formaAtual.ativo ? Icons.power_settings_new : Icons.refresh),
            label: Text(_formaAtual.ativo ? 'INATIVAR' : 'REATIVAR'),
            style: OutlinedButton.styleFrom(
                foregroundColor:
                    _formaAtual.ativo ? Colors.redAccent : Colors.greenAccent,
                side: BorderSide(
                    color: _formaAtual.ativo
                        ? Colors.redAccent
                        : Colors.greenAccent)),
          ),
        ),
        const SizedBox(width: 16),
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
