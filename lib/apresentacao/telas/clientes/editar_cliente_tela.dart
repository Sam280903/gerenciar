// NOVO ARQUIVO: lib/apresentacao/telas/clientes/editar_cliente_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/atualizar_cliente.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';

class EditarClienteTela extends StatefulWidget {
  final Cliente cliente;
  const EditarClienteTela({super.key, required this.cliente});
  @override
  State<EditarClienteTela> createState() => _EditarClienteTelaState();
}

class _EditarClienteTelaState extends State<EditarClienteTela> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _cpfController;
  late final TextEditingController _telefoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _enderecoController;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.cliente.nome);
    _cpfController = TextEditingController(text: widget.cliente.cpf);
    _telefoneController = TextEditingController(text: widget.cliente.telefone);
    _emailController = TextEditingController(text: widget.cliente.email);
    _enderecoController = TextEditingController(text: widget.cliente.endereco);
  }

  Future<void> _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);
      final clienteAtualizado = Cliente(
        id: widget.cliente.id,
        nome: _nomeController.text.trim(),
        cpf: _cpfController.text.trim(),
        telefone: _telefoneController.text.trim(),
        email: _emailController.text.trim(),
        endereco: _enderecoController.text.trim(),
        ativo: widget.cliente.ativo,
      );
      final atualizarCliente = AtualizarCliente(ClienteRepositorioAdaptativo());
      try {
        await atualizarCliente.executar(clienteAtualizado);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Cliente atualizado com sucesso!'),
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
      appBar: AppBar(title: const Text("Editar Cliente")),
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
                      onPressed: _salvarAlteracoes,
                      child: const Text('SALVAR ALTERAÇÕES')),
            ],
          ),
        ),
      ),
    );
  }
}
