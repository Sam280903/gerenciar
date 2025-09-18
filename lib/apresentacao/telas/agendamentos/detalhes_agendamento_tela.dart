// lib/apresentacao/telas/agendamentos/detalhes_agendamento_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/agendamento/agendamento_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/atualizar_agendamento.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/inativar_agendamento.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/reativar_agendamento.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'editar_agendamento_tela.dart';
import 'package:intl/intl.dart';

class DetalhesAgendamentoTela extends StatefulWidget {
  final Agendamento agendamento;
  const DetalhesAgendamentoTela({super.key, required this.agendamento});

  @override
  State<DetalhesAgendamentoTela> createState() =>
      _DetalhesAgendamentoTelaState();
}

class _DetalhesAgendamentoTelaState extends State<DetalhesAgendamentoTela> {
  late Agendamento _agendamentoAtual;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _agendamentoAtual = widget.agendamento;
  }

  Future<void> _atualizarStatus(String novoStatus) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Alteração de Status'),
        content:
            Text('Tem certeza que deseja alterar o status para "$novoStatus"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('CONFIRMAR'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _carregando = true);
    try {
      final agendamentoAtualizado = Agendamento(
        id: _agendamentoAtual.id,
        idCliente: _agendamentoAtual.idCliente,
        idTecnico: _agendamentoAtual.idTecnico,
        dataHora: _agendamentoAtual.dataHora,
        observacao: _agendamentoAtual.observacao,
        status: novoStatus,
        ativo: _agendamentoAtual.ativo,
      );

      await AtualizarAgendamento(AgendamentoRepositorioAdaptativo())
          .executar(agendamentoAtualizado);

      if (mounted) {
        setState(() => _agendamentoAtual = agendamentoAtualizado);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Status atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erro ao atualizar status: $e'),
          backgroundColor: Colors.redAccent,
        ));
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _abrirEdicao() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
          builder: (_) =>
              EditarAgendamentoTela(agendamento: _agendamentoAtual)),
    );
    if (resultado == true && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _toggleAtivo() async {
    final bool vaiInativar = _agendamentoAtual.ativo;
    final acao = vaiInativar ? 'inativar' : 'reativar';
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar ${vaiInativar ? "Inativação" : "Reativação"}'),
        content: Text('Tem certeza que deseja $acao este agendamento?'),
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
        if (vaiInativar) {
          await InativarAgendamento(AgendamentoRepositorioAdaptativo())
              .executar(_agendamentoAtual.id);
        } else {
          await ReativarAgendamento(AgendamentoRepositorioAdaptativo())
              .executar(_agendamentoAtual.id);
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Agendamento ${acao}do com sucesso!'),
              backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Erro ao $acao o agendamento: $e'),
              backgroundColor: Colors.redAccent));
        }
      } finally {
        if (mounted) setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhes do Agendamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(
                'Data e Hora',
                DateFormat('dd/MM/yyyy \'às\' HH:mm')
                    .format(_agendamentoAtual.dataHora),
                Icons.calendar_today_outlined),
            const SizedBox(height: 16),
            _buildInfoCard(
                'Status', _agendamentoAtual.status, Icons.flag_outlined,
                valueColor: _getStatusColor(_agendamentoAtual.status)),
            const SizedBox(height: 16),
            _buildInfoCard('Observações', _agendamentoAtual.observacao ?? '',
                Icons.description_outlined),
            const SizedBox(height: 16),
            _buildInfoCard(
                'Situação',
                _agendamentoAtual.ativo ? 'Ativo' : 'Inativo',
                _agendamentoAtual.ativo
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                valueColor: _agendamentoAtual.ativo
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_agendamentoAtual.ativo) ...[
          ElevatedButton.icon(
            onPressed: _abrirEdicao,
            icon: const Icon(Icons.edit_calendar_outlined),
            label: const Text('EDITAR DATA E OBS.'),
          ),
          const SizedBox(height: 16),
          if (_agendamentoAtual.status == 'Confirmado')
            ElevatedButton.icon(
              onPressed: () => _atualizarStatus('Concluído'),
              icon: const Icon(Icons.task_alt),
              label: const Text('CONCLUIR AGENDAMENTO'),
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            ),
          if (_agendamentoAtual.status != 'Confirmado' &&
              _agendamentoAtual.status != 'Concluído')
            ElevatedButton.icon(
              onPressed: () => _atualizarStatus('Confirmado'),
              icon: const Icon(Icons.check),
              label: const Text('CONFIRMAR'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          const SizedBox(height: 12),
          if (_agendamentoAtual.status != 'Cancelado' &&
              _agendamentoAtual.status != 'Concluído')
            OutlinedButton.icon(
              onPressed: () => _atualizarStatus('Cancelado'),
              icon: const Icon(Icons.close),
              label: const Text('CANCELAR'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.orangeAccent,
                  side: const BorderSide(color: Colors.orangeAccent)),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _toggleAtivo,
            icon: const Icon(Icons.visibility_off_outlined),
            label: const Text('INATIVAR'),
            style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent)),
          ),
        ] else ...[
          ElevatedButton.icon(
            onPressed: _toggleAtivo,
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('REATIVAR AGENDAMENTO'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
        ],
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Concluído':
        return Colors.greenAccent;
      case 'Confirmado':
        return Colors.blueAccent;
      case 'Cancelado':
        return Colors.redAccent;
      default: // Pendente
        return Colors.orangeAccent;
    }
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
            Text(
              value.isNotEmpty ? value : 'Não informado',
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
