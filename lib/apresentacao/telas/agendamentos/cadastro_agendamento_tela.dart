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
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

class CadastroAgendamentoTela extends StatefulWidget {
  final CadastrarAgendamento? cadastrarAgendamento;
  final ListarClientes? listarClientes;
  final ListarTecnicos? listarTecnicos;

  const CadastroAgendamentoTela({
    super.key,
    this.cadastrarAgendamento,
    this.listarClientes,
    this.listarTecnicos,
  });

  @override
  State<CadastroAgendamentoTela> createState() =>
      _CadastroAgendamentoTelaState();
}

class _CadastroAgendamentoTelaState extends State<CadastroAgendamentoTela> {
  final _formKey = GlobalKey<FormState>();
  final _dataController = TextEditingController();
  final _horaController = TextEditingController();
  final _obsController = TextEditingController();
  final _enderecoController =
      TextEditingController(); // Controlador para o endereço automático

  Cliente? _clienteSelecionado;
  Tecnico? _tecnicoSelecionado;
  DateTime _dataSelecionada = DateTime.now();
  TimeOfDay _horaSelecionada = TimeOfDay.now();
  bool _carregando = false;
  bool _isInit = true;

  late final CadastrarAgendamento _cadastrarAgendamento;
  late final ListarClientes _listarClientes;
  late final ListarTecnicos _listarTecnicos;

  final AutenticacaoServico _authServico = AutenticacaoServico();
  String? _idGestor;
  String _lembreteSelecionado = '15_minutos_antes';

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
    _dataController.dispose();
    _horaController.dispose();
    _obsController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  // RF09: Função para abrir o Google Maps com o endereço do cliente
  Future<void> _abrirMapa() async {
    if (_enderecoController.text.isEmpty) return;

    final query = Uri.encodeComponent(_enderecoController.text);
    final url =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$query");

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não foi possível abrir o mapa.')));
      }
    }
  }

  Future<void> _abrirBuscaCliente() async {
    if (_idGestor == null) return;
    final cliente = await Navigator.push<Cliente>(
      context,
      MaterialPageRoute(
        builder: (_) => TelaBusca<Cliente>(
          titulo: 'Selecionar Cliente',
          futureItens: _listarClientes.executar(idGestor: _idGestor!),
          getNomeItem: (c) => c.nome,
        ),
      ),
    );
    if (cliente != null) {
      setState(() {
        _clienteSelecionado = cliente;
        // RF06/RF09: Preenchimento automático do endereço
        _enderecoController.text = cliente.endereco;
      });
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
          getNomeItem: (t) => t.nome,
        ),
      ),
    );
    if (tecnico != null) {
      setState(() => _tecnicoSelecionado = tecnico);
    }
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

  Future<void> _salvarAgendamento() async {
    if (_idGestor == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Não foi possível identificar o gestor. Tente novamente.'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

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
          idGestor: _idGestor!,
          dataHora: dataHoraAgendamento,
          observacao: _obsController.text.trim(),
          lembreteNotificacao: _lembreteSelecionado,
          notificacaoEnviada: false,
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
              // Campo de Endereço preenchido automaticamente com ícone para o Mapa
              TextFormField(
                controller: _enderecoController,
                decoration: InputDecoration(
                  labelText: 'Endereço do Atendimento',
                  prefixIcon: const Icon(Icons.location_on),
                  suffixIcon: _enderecoController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.map_outlined,
                              color: Colors.blue),
                          onPressed: _abrirMapa,
                          tooltip: 'Ver no Mapa',
                        )
                      : null,
                ),
                readOnly: true, // Endereço vem do cadastro do cliente
                maxLines: 2,
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
              DropdownButtonFormField<String>(
                value: _lembreteSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Lembrar-me',
                  prefixIcon: Icon(Icons.notifications_active_outlined),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'na_hora', child: Text('Na hora do agendamento')),
                  DropdownMenuItem(
                      value: '15_minutos_antes',
                      child: Text('15 minutos antes')),
                  DropdownMenuItem(
                      value: '30_minutos_antes',
                      child: Text('30 minutos antes')),
                  DropdownMenuItem(
                      value: '1_hora_antes', child: Text('1 hora antes')),
                  DropdownMenuItem(
                      value: '1_dia_antes', child: Text('1 dia antes')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _lembreteSelecionado = val);
                },
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
                            strokeWidth: 2, color: Colors.white),
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
