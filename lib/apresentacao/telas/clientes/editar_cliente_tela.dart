// lib/apresentacao/telas/clientes/editar_cliente_tela.dart
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/atualizar_cliente.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  // Novos controllers para o endereço
  late final TextEditingController _cepController;
  late final TextEditingController _logradouroController;
  late final TextEditingController _numeroController;
  late final TextEditingController _complementoController;
  late final TextEditingController _bairroController;
  late final TextEditingController _cidadeController;
  late final TextEditingController _ufController;

  bool _carregando = false;
  bool _buscandoCep = false;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.cliente.nome);
    _cpfController = TextEditingController(text: widget.cliente.cpf);
    _telefoneController = TextEditingController(text: widget.cliente.telefone);
    _emailController = TextEditingController(text: widget.cliente.email);

    // Inicializa os novos controllers de endereço
    _cepController = TextEditingController();
    _logradouroController = TextEditingController();
    _numeroController = TextEditingController();
    _complementoController = TextEditingController();
    _bairroController = TextEditingController();
    _cidadeController = TextEditingController();
    _ufController = TextEditingController();

    // Tenta separar o endereço existente nos novos campos
    _preencherEnderecoInicial();
  }

  void _preencherEnderecoInicial() {
    // Lógica simples para separar o endereço. Pode ser ajustada.
    final parts = widget.cliente.endereco.split(',');
    if (parts.isNotEmpty) _logradouroController.text = parts[0].trim();
    if (parts.length > 1) _bairroController.text = parts[1].trim();
    if (parts.length > 2) _cidadeController.text = parts[2].trim();
  }

  Future<void> _buscarCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) return;

    setState(() => _buscandoCep = true);
    try {
      final response =
          await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['erro'] != true) {
          setState(() {
            _logradouroController.text = data['logradouro'] ?? '';
            _bairroController.text = data['bairro'] ?? '';
            _cidadeController.text = data['localidade'] ?? '';
            _ufController.text = data['uf'] ?? '';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Erro ao buscar CEP.'),
          backgroundColor: Colors.redAccent,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _buscandoCep = false);
      }
    }
  }

  Future<void> _salvarAlteracoes() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);

      // Constrói o endereço completo a partir dos campos
      final enderecoCompleto = [
        _logradouroController.text.trim(),
        if (_numeroController.text.isNotEmpty)
          'Nº ${_numeroController.text.trim()}',
        if (_complementoController.text.isNotEmpty)
          _complementoController.text.trim(),
        _bairroController.text.trim(),
        _cidadeController.text.trim(),
        _ufController.text.trim()
      ].where((s) => s.isNotEmpty).join(', ');

      final clienteAtualizado = Cliente(
        id: widget.cliente.id,
        nome: _nomeController.text.trim(),
        cpf: _cpfController.text.trim(),
        telefone: _telefoneController.text.trim(),
        email: _emailController.text.trim(),
        endereco: enderecoCompleto,
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
    _cepController.dispose();
    _logradouroController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _bairroController.dispose();
    _cidadeController.dispose();
    _ufController.dispose();
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          TelefoneInputFormatter(),
                        ],
                        validator: (v) =>
                            v!.isEmpty ? 'Campo obrigatório' : null)),
                const SizedBox(width: 16),
                Expanded(
                    child: TextFormField(
                        controller: _cpfController,
                        decoration:
                            const InputDecoration(labelText: 'CPF/CNPJ'),
                        keyboardType: TextInputType.number,
                        // ADICIONA A MÁSCARA AQUI
                        inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      CpfOuCnpjFormatter(),
                    ])),
              ]),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 24),
              const Divider(),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Endereço',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70)),
              ),
              TextFormField(
                controller: _cepController,
                decoration: InputDecoration(
                  labelText: 'CEP',
                  suffixIcon: _buscandoCep
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _buscarCep),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CepInputFormatter(),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _logradouroController,
                  decoration:
                      const InputDecoration(labelText: 'Logradouro (Rua, Av.)'),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _numeroController,
                      decoration: const InputDecoration(labelText: 'Número'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _complementoController,
                      decoration:
                          const InputDecoration(labelText: 'Complemento'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _bairroController,
                  decoration: const InputDecoration(labelText: 'Bairro'),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                        controller: _cidadeController,
                        decoration: const InputDecoration(labelText: 'Cidade'),
                        validator: (v) =>
                            v!.isEmpty ? 'Campo obrigatório' : null),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                        controller: _ufController,
                        decoration: const InputDecoration(labelText: 'UF'),
                        validator: (v) =>
                            v!.isEmpty ? 'Campo obrigatório' : null),
                  ),
                ],
              ),
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
