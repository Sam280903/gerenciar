// lib/apresentacao/telas/ordens_servico/editar_os_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/ordem_servico/ordem_servico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/atualizar_ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:intl/intl.dart';

class EditarOSTela extends StatefulWidget {
  final OrdemServico ordemServico;

  const EditarOSTela({super.key, required this.ordemServico});

  @override
  State<EditarOSTela> createState() => _EditarOSTelaState();
}

class _EditarOSTelaState extends State<EditarOSTela> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descricaoController;
  late final TextEditingController _valorController;
  late final TextEditingController _dataController;

  late String _prioridadeSelecionada;
  late String _statusSelecionado;
  late DateTime _dataSelecionada;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    final os = widget.ordemServico;
    _descricaoController = TextEditingController(text: os.descricao);
    _valorController = TextEditingController(text: os.valor.toStringAsFixed(2));
    _dataSelecionada = os.dataHoraInicio;
    _dataController = TextEditingController(
        text: DateFormat('dd/MM/yyyy').format(os.dataHoraInicio));
    _prioridadeSelecionada = os.prioridade;
    _statusSelecionado = os.status;
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _dataController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (data != null) {
      setState(() {
        _dataSelecionada = data;
        _dataController.text =
            DateFormat('dd/MM/yyyy').format(_dataSelecionada);
      });
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);

      final osAtualizada = OrdemServico(
        id: widget.ordemServico.id,
        idCliente: widget.ordemServico.idCliente,
        idTecnico: widget.ordemServico.idTecnico,
        idFormaPagamento: widget.ordemServico.idFormaPagamento,
        dataHoraInicio: _dataSelecionada,
        descricao: _descricaoController.text.trim(),
        valor:
            double.tryParse(_valorController.text.replaceAll(',', '.')) ?? 0.0,
        prioridade: _prioridadeSelecionada,
        status: _statusSelecionado,
        ativo: widget.ordemServico.ativo,
        dataHoraFim: _statusSelecionado == 'Concluída' ? DateTime.now() : null,
      );

      final atualizarOS =
          AtualizarOrdemServico(OrdemServicoRepositorioAdaptativo());

      try {
        await atualizarOS.executar(osAtualizada);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('OS atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ));
          Navigator.of(context).pop(true); // Retorna true para recarregar
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro ao atualizar OS: $e'),
            backgroundColor: Colors.redAccent,
          ));
        }
      } finally {
        if (mounted) {
          setState(() => _carregando = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar OS #${widget.ordemServico.id.substring(0, 6)}...'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _descricaoController,
                decoration:
                    const InputDecoration(labelText: 'Descrição do Problema'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dataController,
                      decoration:
                          const InputDecoration(labelText: 'Data de Abertura'),
                      readOnly: true,
                      onTap: _selecionarData,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _prioridadeSelecionada,
                      decoration:
                          const InputDecoration(labelText: 'Prioridade'),
                      items: ['Baixa', 'Média', 'Alta']
                          .map(
                              (p) => DropdownMenuItem(value: p, child: Text(p)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _prioridadeSelecionada = val);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _statusSelecionado,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['Pendente', 'Em Andamento', 'Concluída', 'Reaberta']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _statusSelecionado = val);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                decoration:
                    const InputDecoration(labelText: 'Valor do Serviço (R\$)'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 32),
              _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _salvarAlteracoes,
                      child: const Text('SALVAR ALTERAÇÕES'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
