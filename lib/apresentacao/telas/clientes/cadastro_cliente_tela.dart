// lib/apresentacao/telas/clientes/cadastro_cliente_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/cadastrar_cliente.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:uuid/uuid.dart';

class CadastroClienteTela extends StatefulWidget {
  const CadastroClienteTela({super.key});
  @override
  State<CadastroClienteTela> createState() => _CadastroClienteTelaState();
}

class _CadastroClienteTelaState extends State<CadastroClienteTela> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _enderecoController = TextEditingController();
  bool _carregando = false;

  Future<void> _salvarCliente() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);
      final novoCliente = Cliente(
        id: const Uuid().v4(),
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        telefone: _telefoneController.text.trim(),
        endereco: _enderecoController.text.trim(),
        cpf: _cpfController.text.trim(),
        ativo: true,
      );
      final cadastrarCliente = CadastrarCliente(ClienteRepositorioAdaptativo());
      try {
        await cadastrarCliente.executar(novoCliente);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Cliente salvo com sucesso!'),
              backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Erro ao salvar cliente: $e'),
              backgroundColor: Colors.redAccent));
        }
      } finally {
        if (mounted) setState(() => _carregando = false);
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Novo Cliente")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome completo'),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                    child: TextFormField(
                        controller: _telefoneController,
                        decoration:
                            const InputDecoration(labelText: 'Telefone'),
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            v!.isEmpty ? 'Campo obrigatório' : null)),
                const SizedBox(width: 16),
                Expanded(
                    child: TextFormField(
                        controller: _cpfController,
                        decoration: const InputDecoration(labelText: 'CPF'),
                        keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _enderecoController,
                  decoration: const InputDecoration(labelText: 'Endereço'),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 32),
              _carregando
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _salvarCliente,
                      child: const Text('SALVAR CLIENTE')),
            ],
          ),
        ),
      ),
    );
  }
}
