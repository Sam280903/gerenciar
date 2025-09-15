// lib/apresentacao/telas/tecnicos/editar_tecnico_tela.dart

import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/atualizar_tecnico.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';

class EditarTecnicoTela extends StatefulWidget {
  final Tecnico tecnico;

  const EditarTecnicoTela({super.key, required this.tecnico});

  @override
  State<EditarTecnicoTela> createState() => _EditarTecnicoTelaState();
}

class _EditarTecnicoTelaState extends State<EditarTecnicoTela> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _emailController;
  late final TextEditingController _telefoneController;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.tecnico.nome);
    _emailController = TextEditingController(text: widget.tecnico.email);
    _telefoneController = TextEditingController(text: widget.tecnico.telefone);
  }

  Future<void> _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);

      final tecnicoAtualizado = Tecnico(
        id: widget.tecnico.id,
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        telefone: _telefoneController.text.trim(),
        ativo: widget.tecnico.ativo,
      );

      final atualizarTecnico = AtualizarTecnico(TecnicoRepositorioAdaptativo());

      try {
        await atualizarTecnico.executar(tecnicoAtualizado);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Técnico atualizado com sucesso!'),
                backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(true); // Retorna true para recarregar
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Erro ao atualizar: $e'),
                backgroundColor: Colors.redAccent),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _carregando = false);
        }
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editar Técnico"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome Completo',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail (para login)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value!.isEmpty ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _telefoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 40),
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
