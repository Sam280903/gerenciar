// lib/apresentacao/telas/clientes/cadastro_cliente_tela.dart
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/cadastrar_cliente.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart'; // ADICIONADO
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';

class CadastroClienteTela extends StatefulWidget {
  final CadastrarCliente? cadastrarCliente;
  final http.Client? httpClient;
  final AutenticacaoServico? authServico;

  const CadastroClienteTela({super.key, this.cadastrarCliente, this.httpClient, this.authServico});
  @override
  State<CadastroClienteTela> createState() => _CadastroClienteTelaState();
}

class _CadastroClienteTelaState extends State<CadastroClienteTela> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();

  final _cepController = TextEditingController();
  final _logradouroController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _bairroController = TextEditingController();
  final _cidadeController = TextEditingController();
  final _ufController = TextEditingController();

  late final CadastrarCliente _cadastrarCliente;
  late final http.Client _httpClient;

  late final AutenticacaoServico _authServico;
  String? _idGestor;

  bool _carregando = false;
  bool _buscandoCep = false;
  bool _isCadastroRapido = true;

  @override
  void initState() {
    super.initState();
    _authServico = widget.authServico ?? AutenticacaoServico();
    _cadastrarCliente =
        widget.cadastrarCliente ?? CadastrarCliente(ClienteRepositorioAdaptativo());
    _httpClient = widget.httpClient ?? http.Client();
    _carregarDadosIniciais();
  }

  // NOVO MÉTODO
  Future<void> _carregarDadosIniciais() async {
    final dadosUsuario = await _authServico.buscarDadosUsuarioLogado();
    if (mounted && dadosUsuario != null) {
      setState(() {
        _idGestor = dadosUsuario['idGestor'];
      });
    }
  }

  Future<void> _buscarCep() async {
    final cep = _cepController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cep.length != 8) return;
    FocusScope.of(context).unfocus();

    setState(() => _buscandoCep = true);
    try {
      final response = await _httpClient
          .get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
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

  Future<void> _salvarCliente() async {
    if (_idGestor == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Erro: Gestor não identificado. Tente novamente.'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);

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

      final novoCliente = Cliente(
        id: const Uuid().v4(),
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        telefone: _telefoneController.text.trim(),
        endereco: enderecoCompleto,
        cpf: _cpfController.text.trim(),
        ativo: true,
        idGestor: _idGestor!, // ADICIONADO
      );

      try {
        await _cadastrarCliente.executar(novoCliente);
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
      appBar: AppBar(title: const Text("Novo Cliente")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                title: const Text('Cadastro Rápido',
                    style: TextStyle(color: Colors.white)),
                subtitle: const Text('Cadastrar apenas nome e telefone',
                    style: TextStyle(color: Colors.white70)),
                value: _isCadastroRapido,
                onChanged: (bool value) {
                  setState(() {
                    _isCadastroRapido = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                      labelText: 'Nome completo *',
                      prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),

              TextFormField(
                  controller: _telefoneController,
                  decoration: const InputDecoration(
                      labelText: 'Telefone *',
                      prefixIcon: Icon(Icons.phone_outlined)),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TelefoneInputFormatter(),
                  ],
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null),
              const SizedBox(height: 16),

              Visibility(
                visible: !_isCadastroRapido,
                child: Column(
                  children: [
                    TextFormField(
                        controller: _cpfController,
                        decoration: const InputDecoration(
                            labelText: 'CPF/CNPJ',
                            prefixIcon: Icon(Icons.badge_outlined)),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CpfOuCnpjFormatter(),
                        ]),
                    const SizedBox(height: 16),
                    TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                            labelText: 'E-mail',
                            prefixIcon: Icon(Icons.email_outlined)),
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
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
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
                        decoration: const InputDecoration(
                            labelText: 'Logradouro (Rua, Av.) *'),
                        validator: (v) => !_isCadastroRapido && v!.isEmpty
                            ? 'Campo obrigatório'
                            : null),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _numeroController,
                            decoration:
                                const InputDecoration(labelText: 'Número'),
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
                        decoration:
                            const InputDecoration(labelText: 'Bairro *'),
                        validator: (v) => !_isCadastroRapido && v!.isEmpty
                            ? 'Campo obrigatório'
                            : null),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                              controller: _cidadeController,
                              decoration:
                                  const InputDecoration(labelText: 'Cidade *'),
                              validator: (v) => !_isCadastroRapido && v!.isEmpty
                                  ? 'Campo obrigatório'
                                  : null),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                              controller: _ufController,
                              decoration:
                                  const InputDecoration(labelText: 'UF *'),
                              validator: (v) => !_isCadastroRapido && v!.isEmpty
                                  ? 'Campo obrigatório'
                                  : null),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _carregando ? null : _salvarCliente,
                child: _carregando
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue,
                        ),
                      )
                    : const Text('SALVAR CLIENTE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}