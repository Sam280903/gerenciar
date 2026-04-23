// lib/apresentacao/telas/formas_pagamento/editar_forma_pagamento_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/forma_pagamento/forma_pagamento_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/atualizar_forma_pagamento.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';

class EditarFormaPagamentoTela extends StatefulWidget {
  final FormaPagamento formaPagamento;
  final AtualizarFormaPagamento? atualizarFormaPagamento;
  const EditarFormaPagamentoTela({super.key, required this.formaPagamento, this.atualizarFormaPagamento});

  @override
  State<EditarFormaPagamentoTela> createState() =>
      _EditarFormaPagamentoTelaState();
}

class _EditarFormaPagamentoTelaState extends State<EditarFormaPagamentoTela> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _descricaoController;
  bool _carregando = false;
  late final AtualizarFormaPagamento _atualizar;

  @override
  void initState() {
    super.initState();
    _atualizar = widget.atualizarFormaPagamento ?? AtualizarFormaPagamento(FormaPagamentoRepositorioAdaptativo());
    _nomeController = TextEditingController(text: widget.formaPagamento.nome);
    _descricaoController =
        TextEditingController(text: widget.formaPagamento.descricao);
  }

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);

      final formaAtualizada = FormaPagamento(
        id: widget.formaPagamento.id,
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
        ativo: widget.formaPagamento.ativo,
        idGestor: widget.formaPagamento.idGestor,
      );

      final atualizar = _atualizar;
      try {
        await atualizar.executar(formaAtualizada);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Atualizado com sucesso!'),
              backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Erro ao atualizar: $e'),
              backgroundColor: Colors.redAccent));
        }
      } finally {
        if (mounted) setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Editar Forma de Pagamento',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descricaoController,
              decoration:
                  const InputDecoration(labelText: 'Descrição (opcional)'),
            ),
            const SizedBox(height: 32),
            _carregando
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _salvar, child: const Text('SALVAR ALTERAÇÕES')),
          ],
        ),
      ),
    );
  }
}
