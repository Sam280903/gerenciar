// lib/apresentacao/telas/relatorios/relatorios_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/apresentacao/telas/relatorios/relatorio_resultado_tela.dart';
import 'package:gerenciar/apresentacao/widgets/_tela_busca.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/listar_clientes.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/listar_tecnicos.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'package:gerenciar/servicos/relatorio_servico.dart';
import 'package:intl/intl.dart';

class RelatoriosTela extends StatefulWidget {
  final RelatorioServico? relatorioServico;
  final ListarTecnicos? listarTecnicos;
  final ListarClientes? listarClientes;
  final AutenticacaoServico? authServico;

  const RelatoriosTela(
      {super.key,
      this.relatorioServico,
      this.listarTecnicos,
      this.listarClientes,
      this.authServico});

  @override
  State<RelatoriosTela> createState() => _RelatoriosTelaState();
}

class _RelatoriosTelaState extends State<RelatoriosTela> {
  DateTime? _dataInicial;
  DateTime? _dataFinal;
  Tecnico? _tecnicoSelecionado;
  Cliente? _clienteSelecionado;
  String? _statusSelecionado;
  bool _carregando = false;

  final _dataInicialController = TextEditingController();
  final _dataFinalController = TextEditingController();

  late final RelatorioServico _relatorioServico;
  late final ListarTecnicos _listarTecnicos;
  late final ListarClientes _listarClientes;
  late final AutenticacaoServico _authServico;
  String? _idGestor;

  @override
  void initState() {
    super.initState();
    _authServico = widget.authServico ?? AutenticacaoServico();
    _relatorioServico = widget.relatorioServico ?? RelatorioServico();
    _listarTecnicos =
        widget.listarTecnicos ?? ListarTecnicos(TecnicoRepositorioAdaptativo());
    _listarClientes =
        widget.listarClientes ?? ListarClientes(ClienteRepositorioAdaptativo());
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
  void dispose() {
    _dataInicialController.dispose();
    _dataFinalController.dispose();
    super.dispose();
  }

  Future<void> _selecionarData(BuildContext context, bool isDataInicial) async {
    final data = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (data != null) {
      setState(() {
        if (isDataInicial) {
          _dataInicial = data;
          _dataInicialController.text = DateFormat('dd/MM/yyyy').format(data);
        } else {
          _dataFinal = data;
          _dataFinalController.text = DateFormat('dd/MM/yyyy').format(data);
        }
      });
    }
  }

  Future<void> _gerarRelatorio() async {
    if (_idGestor == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Não foi possível identificar o gestor.'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }
    setState(() => _carregando = true);
    FocusScope.of(context).unfocus();

    final filtros = FiltrosRelatorio(
      dataInicial: _dataInicial,
      dataFinal: _dataFinal,
      idTecnico: _tecnicoSelecionado?.id,
      idCliente: _clienteSelecionado?.id,
      status: _statusSelecionado != null
        ? [_statusSelecionado!]
        : ['Pendente', 'Em Andamento', 'Concluída', 'Reaberta'],
    );

    try {
      // AQUI ESTÁ A CORREÇÃO
      final resultado = await _relatorioServico.gerarRelatorioOrdensServico(
          filtros, _idGestor!);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RelatorioResultadoTela(
              ordensDeServico: resultado,
              filtros: filtros,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Erro ao gerar relatório: ${e.toString().replaceFirst("Exception: ", "")}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios de OS'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Filtros para o Relatório',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dataInicialController,
                    decoration:
                        const InputDecoration(labelText: 'Data Inicial'),
                    readOnly: true,
                    onTap: () => _selecionarData(context, true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _dataFinalController,
                    decoration: const InputDecoration(labelText: 'Data Final'),
                    readOnly: true,
                    onTap: () => _selecionarData(context, false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                if (_idGestor == null) return;
                final tecnico = await Navigator.push<Tecnico>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => TelaBusca<Tecnico>(
                            titulo: 'Selecionar Técnico',
                            futureItens:
                                _listarTecnicos.executar(idGestor: _idGestor!),
                            getNomeItem: (t) => t.nome)));
                if (tecnico != null) {
                  setState(() => _tecnicoSelecionado = tecnico);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Filtrar por Técnico',
                  suffixIcon: _tecnicoSelecionado != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _tecnicoSelecionado = null),
                        )
                      : null,
                ),
                child: Text(_tecnicoSelecionado?.nome ?? 'Todos'),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                if (_idGestor == null) return;
                final cliente = await Navigator.push<Cliente>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => TelaBusca<Cliente>(
                            titulo: 'Selecionar Cliente',
                            futureItens:
                                _listarClientes.executar(idGestor: _idGestor!),
                            getNomeItem: (c) => c.nome)));
                if (cliente != null) {
                  setState(() => _clienteSelecionado = cliente);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Filtrar por Cliente',
                  suffixIcon: _clienteSelecionado != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _clienteSelecionado = null),
                        )
                      : null,
                ),
                child: Text(_clienteSelecionado?.nome ?? 'Todos'),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String?>(
              value: _statusSelecionado,
              hint: const Text('Todos'),
              decoration:
                  const InputDecoration(labelText: 'Filtrar por Status'),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('Todos')),
                ...['Pendente', 'Em Andamento', 'Concluída', 'Reaberta', 'Cancelada']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              ],
              onChanged: (val) {
                setState(() => _statusSelecionado = val);
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _carregando ? null : _gerarRelatorio,
              icon: _carregando
                  ? Container(
                      width: 24,
                      height: 24,
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(
                        color: Colors.blue,
                        strokeWidth: 3,
                      ),
                    )
                  : const Icon(Icons.search),
              label: Text(_carregando ? 'GERANDO...' : 'GERAR RELATÓRIO'),
            ),
          ],
        ),
      ),
    );
  }
}
