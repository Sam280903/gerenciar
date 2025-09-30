// lib/apresentacao/telas/agendamentos/cadastro_agendamento_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/agendamento/agendamento_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/agendamento/cadastrar_agendamento.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/listar_clientes.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/listar_tecnicos.dart';
import 'package:gerenciar/dominio/entidades/agendamento.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/apresentacao/widgets/_tela_busca.dart';
import 'package:gerenciar/apresentacao/widgets/_widget_selecao.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class CadastroAgendamentoTela extends StatefulWidget {
  // Adicionando dependências para injeção
  final CadastrarAgendamento? cadastrarAgendamento;
  final ListarClientes? listarClientes;
  final ListarTecnicos? listarTecnicos;

  const CadastroAgendamentoTela(
      {super.key,
      this.cadastrarAgendamento,
      this.listarClientes,
      this.listarTecnicos});

  @override
  State<CadastroAgendamentoTela> createState() =>
      _CadastroAgendamentoTelaState();
}

class _CadastroAgendamentoTelaState extends State<CadastroAgendamentoTela> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _horaController = TextEditingController();
  final _obsController = TextEditingController();

  Cliente? _clienteSelecionado;
  Tecnico? _tecnicoSelecionado;
  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();
  bool _carregando = false;
  bool _isInit = true;

  late final CadastrarAgendamento _cadastrarAgendamento;
  late final ListarClientes _listarClientes;
  late final ListarTecnicos _listarTecnicos;

  @override
  void initState() {
    super.initState();
    _cadastrarAgendamento = widget.cadastrarAgendamento ??
        CadastrarAgendamento(AgendamentoRepositorioAdaptativo());
    _listarClientes =
        widget.listarClientes ?? ListarClientes(ClienteRepositorioAdaptativo());
    _listarTecnicos =
        widget.listarTecnicos ?? ListarTecnicos(TecnicoRepositorioAdaptativo());

    _dataController.text = DateFormat('dd/MM/yyyy').format(_dataSelecionada);
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
    _dataController.dispose();
    _horaController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (data != null) {
      setState(() {
        _dataSelecionada = data;
        _dataController.text = DateFormat('dd/MM/yyyy').format(data);
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

  Future<void> _abrirBuscaCliente() async {
    final cliente = await Navigator.push<Cliente>(
      context,
      MaterialPageRoute(
        builder: (_) => TelaBusca<Cliente>(
          titulo: 'Selecionar Cliente',
          futureItens: _listarClientes.executar(),
          getNomeItem: (c) => c.nome,
        ),
      ),
    );
    if (cliente != null) {
      setState(() => _clienteSelecionado = cliente);
    }
  }

  Future<void> _abrirBuscaTecnico() async {
    final tecnico = await Navigator.push<Tecnico>(
      context,
      MaterialPageRoute(
        builder: (_) => TelaBusca<Tecnico>(
          titulo: 'Selecionar Técnico',
          futureItens: _listarTecnicos.executar(),
          getNomeItem: (t) => t.nome,
        ),
      ),
    );
    if (tecnico != null) {
      setState(() => _tecnicoSelecionado = tecnico);
    }
  }

  Future<void> _salvarAgendamento() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      setState(() => _carregando = true);
      try {
        final dataHoraAgendamento = DateTime(
          _dataSelecionada.year,
          _dataSelecionada.month,
          _dataSelecionada.day,
          _horaSelecionada.hour,
          _horaSelecionada.minute,
        );

        final novoAgendamento = Agendamento(
          id: const Uuid().v4(),
          idCliente: _clienteSelecionado!.id,
          idTecnico: _tecnicoSelecionado!.id,
          dataHora: dataHoraAgendamento,
          observacao: _obsController.text.trim(),
          ativo: true,
        );

        await _cadastrarAgendamento.executar(novoAgendamento);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Agendamento salvo com sucesso!'),
            backgroundColor: Colors.green,
          ));
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Erro: ${e.toString().replaceAll("Exception: ", "")}'),
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
      appBar: AppBar(title: const Text('Novo Agendamento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
                label: 'Técnico',
                valor: _tecnicoSelecionado?.nome ?? '',
                onTap: _abrirBuscaTecnico,
                validator: (v) =>
                    _tecnicoSelecionado == null ? 'Selecione um técnico' : null,
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
                      decoration: const InputDecoration(labelText: 'Horário'),
                      readOnly: true,
                      onTap: _selecionarHora,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _obsController,
                decoration: const InputDecoration(labelText: 'Observações'),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _carregando ? null : _salvarAgendamento,
                child: _carregando
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.blue,
                        ),
                      )
                    : const Text('SALVAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}