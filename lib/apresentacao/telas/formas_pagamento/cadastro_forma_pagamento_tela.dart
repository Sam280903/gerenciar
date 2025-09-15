// lib/apresentacao/telas/formas_pagamento/cadastro_forma_pagamento_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/forma_pagamento/forma_pagamento_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/buscar_forma_pagamento_por_nome.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/cadastrar_forma_pagamento.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:uuid/uuid.dart';

class CadastroFormaPagamentoTela extends StatefulWidget {
  const CadastroFormaPagamentoTela({super.key});

  @override
  State<CadastroFormaPagamentoTela> createState() =>
      _CadastroFormaPagamentoTelaState();
}

class _CadastroFormaPagamentoTelaState
    extends State<CadastroFormaPagamentoTela> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  bool _carregando = false;

  Future<void> _salvar() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);
      final nome = _nomeController.text.trim();
      final repositorio = FormaPagamentoRepositorioAdaptativo();

      try {
        final buscarPorNome = BuscarFormaPagamentoPorNome(repositorio);
        final existente = await buscarPorNome.executar(nome);
        if (existente != null) {
          throw Exception('Já existe uma forma de pagamento com este nome.');
        }

        final novaForma = FormaPagamento(
          id: const Uuid().v4(),
          nome: nome,
          descricao: _descricaoController.text.trim(),
          ativo: true,
        );
        final cadastrar = CadastrarFormaPagamento(repositorio);
        await cadastrar.executar(novaForma);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Salvo com sucesso!'),
              backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(e.toString().replaceAll("Exception: ", "")),
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
            const Text('Nova Forma de Pagamento',
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
                    onPressed: _salvar, child: const Text('SALVAR')),
          ],
        ),
      ),
    );
  }
}
