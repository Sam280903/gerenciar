// lib/apresentacao/telas/ordens_servico/cadastro_os_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/agendamento/agendamento_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/forma_pagamento/forma_pagamento_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/ordem_servico/ordem_servico_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/listar_clientes.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/listar_formas_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/ordem_servico/cadastrar_ordem_servico.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/listar_tecnicos.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:gerenciar/dominio/entidades/ordem_servico.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/apresentacao/widgets/_tela_busca.dart';
import 'package:gerenciar/apresentacao/widgets/_widget_selecao.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:gerenciar/dominio/interfaces/agendamento_repositorio_interface.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CadastroOSTela extends StatefulWidget {
  final ListarClientes? listarClientes;
  final ListarTecnicos? listarTecnicos;
  final ListarFormasPagamento? listarFormasPagamento;
  final CadastrarOrdemServico? cadastrarOS;
  final AgendamentoRepositorioInterface? agendamentoRepo;

  const CadastroOSTela(
      {super.key,
      this.listarClientes,
      this.listarTecnicos,
      this.listarFormasPagamento,
      this.cadastrarOS,
      this.agendamentoRepo});

  @override
  State<CadastroOSTela> createState() => _CadastroOSTelaState();
}

class _CadastroOSTelaState extends State<CadastroOSTela> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _dataController = TextEditingController();
  final _horaController = TextEditingController();

  Cliente? _clienteSelecionado;
  Tecnico? _tecnicoSelecionado;
  FormaPagamento? _formaPagamentoSelecionada;
  String _prioridadeSelecionada = 'Baixa';
  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();
  bool _carregando = false;
  bool _isInit = true;

  final AutenticacaoServico _authServico = AutenticacaoServico();
  String? _idGestor;

  late final ListarClientes _listarClientes;
  late final ListarTecnicos _listarTecnicos;
  late final ListarFormasPagamento _listarFormasPagamento;
  late final CadastrarOrdemServico _cadastrarOS;
  late final AgendamentoRepositorioInterface _agendamentoRepo;

  @override
  void initState() {
    super.initState();
    _listarClientes =
        widget.listarClientes ?? ListarClientes(ClienteRepositorioAdaptativo());
    _listarTecnicos =
        widget.listarTecnicos ?? ListarTecnicos(TecnicoRepositorioAdaptativo());
    _listarFormasPagamento = widget.listarFormasPagamento ??
        ListarFormasPagamento(FormaPagamentoRepositorioAdaptativo());
    _cadastrarOS = widget.cadastrarOS ??
        CadastrarOrdemServico(OrdemServicoRepositorioAdaptativo());
    _agendamentoRepo =
        widget.agendamentoRepo ?? AgendamentoRepositorioAdaptativo();

    _dataController.text = DateFormat('dd/MM/yyyy').format(_dataSelecionada);
    _carregarDadosIniciais();
  }

  Future<void> _carregarDadosIniciais() async {
    final dadosUsuario = await _authServico.buscarDadosUsuarioLogado();
    if (mounted && dadosUsuario != null) {
      setState(() {
        _idGestor = dadosUsuario['idGestor'];
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _horaController.text = _horaSelecionada.format(context);
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _dataController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  Future<void> _abrirBuscaCliente() async {
    if (_idGestor == null) return;
    final cliente = await Navigator.push<Cliente>(
      context,
      MaterialPageRoute(
        builder: (_) => TelaBusca<Cliente>(
          titulo: 'Selecionar Cliente',
          futureItens: _listarClientes.executar(idGestor: _idGestor!),
          getNomeItem: (cliente) => cliente.nome,
        ),
      ),
    );
    if (cliente != null) {
      setState(() => _clienteSelecionado = cliente);
    }
  }

  Future<void> _abrirBuscaTecnico() async {
    if (_idGestor == null) return;
    final tecnico = await Navigator.push<Tecnico>(
      context,
      MaterialPageRoute(
        builder: (_) => TelaBusca<Tecnico>(
          titulo: 'Selecionar Técnico',
          futureItens: _listarTecnicos.executar(idGestor: _idGestor!),
          getNomeItem: (tecnico) => tecnico.nome,
        ),
      ),
    );
    if (tecnico != null) {
      setState(() => _tecnicoSelecionado = tecnico);
    }
  }

  Future<void> _abrirBuscaFormaPagamento() async {
    if (_idGestor == null) return;
    final forma = await Navigator.push<FormaPagamento>(
      context,
      MaterialPageRoute(
        builder: (_) => TelaBusca<FormaPagamento>(
          titulo: 'Selecionar Forma de Pagamento',
          futureItens: _listarFormasPagamento.executar(idGestor: _idGestor!),
          getNomeItem: (forma) => forma.nome,
        ),
      ),
    );
    if (forma != null) {
      setState(() => _formaPagamentoSelecionada = forma);
    }
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

  Future<void> _selecionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaSelecionada,
    );
    if (hora != null) {
      setState(() {
        _horaSelecionada = hora;
        _horaController.text = hora.format(context);
      });
    }
  }

  // --- CORREÇÃO PRINCIPAL AQUI ---
  Future<void> _salvarOS() async {
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

      final dataHoraCompleta = DateTime(
        _dataSelecionada.year,
        _dataSelecionada.month,
        _dataSelecionada.day,
        _horaSelecionada.hour,
        _horaSelecionada.minute,
      );

      // USA a variável da classe (_agendamentoRepo), que foi injetada
      final ocupado = await _agendamentoRepo.verificarDisponibilidade(
        _tecnicoSelecionado!.id,
        dataHoraCompleta,
      );

      if (ocupado && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Conflito! O técnico já possui um agendamento ou OS neste horário.'),
            backgroundColor: Colors.redAccent));
        setState(() => _carregando = false);
        return;
      }

      final novaOS = OrdemServico(
        id: const Uuid().v4(),
        idCliente: _clienteSelecionado!.id,
        idTecnico: _tecnicoSelecionado!.id,
        idFormaPagamento: _formaPagamentoSelecionada!.id,
        idGestor: _idGestor!,
        dataHoraInicio: dataHoraCompleta,
        descricao: _descricaoController.text,
        valor: double.tryParse(_valorController.text.contains(',')
                ? _valorController.text.replaceAll('.', '').replaceAll(',', '.')
                : _valorController.text) ?? 0.0,
        prioridade: _prioridadeSelecionada,
        status: 'Pendente',
        ativo: true,
      );

      // USA a variável da classe (_cadastrarOS), que foi injetada
      try {
        await _cadastrarOS.executar(novaOS);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('OS cadastrada com sucesso!'),
              backgroundColor: Colors.green));
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Erro ao salvar OS: $e'),
              backgroundColor: Colors.redAccent));
        }
      } finally {
        if (mounted) {
          setState(() => _carregando = false);
        }
      }
    }
  }
  // --- FIM DA CORREÇÃO ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova Ordem de Serviço')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WidgetSelecao(
                label: 'Cliente',
                valor: _clienteSelecionado?.nome ?? '',
                onTap: _abrirBuscaCliente,
                validator: (v) =>
                    _clienteSelecionado == null ? 'Selecione um cliente' : null,
              ),
              const SizedBox(height: 16),
              WidgetSelecao(
                label: 'Técnico Responsável',
                valor: _tecnicoSelecionado?.nome ?? '',
                onTap: _abrirBuscaTecnico,
                validator: (v) =>
                    _tecnicoSelecionado == null ? 'Selecione um técnico' : null,
              ),
              const SizedBox(height: 16),
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
                      decoration: const InputDecoration(labelText: 'Data'),
                      readOnly: true,
                      onTap: _selecionarData,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _horaController,
                      decoration: const InputDecoration(labelText: 'Hora'),
                      readOnly: true,
                      onTap: _selecionarHora,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _prioridadeSelecionada,
                decoration: const InputDecoration(labelText: 'Prioridade'),
                items: ['Baixa', 'Média', 'Alta']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _prioridadeSelecionada = val);
                  }
                },
              ),
              const SizedBox(height: 16),
              WidgetSelecao(
                label: 'Forma de Pagamento',
                valor: _formaPagamentoSelecionada?.nome ?? '',
                onTap: _abrirBuscaFormaPagamento,
                validator: (v) => _formaPagamentoSelecionada == null
                    ? 'Selecione uma forma de pagamento'
                    : null,
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
              ElevatedButton(
                onPressed: _carregando ? null : _salvarOS,
                child: _carregando
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue,
                        ),
                      )
                    : const Text('SALVAR OS'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
