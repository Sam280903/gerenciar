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
import 'package:gerenciar/servicos/relatorio_servico.dart';
import 'package:intl/intl.dart';

class RelatoriosTela extends StatefulWidget {
  // Adicionando dependências para injeção
  final RelatorioServico? relatorioServico;
  final ListarTecnicos? listarTecnicos;
  final ListarClientes? listarClientes;

  const RelatoriosTela(
      {super.key,
      this.relatorioServico,
      this.listarTecnicos,
      this.listarClientes});

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

  // Declarando as dependências
  late final RelatorioServico _relatorioServico;
  late final ListarTecnicos _listarTecnicos;
  late final ListarClientes _listarClientes;

  @override
  void initState() {
    super.initState();
    // Inicializando as dependências
    _relatorioServico = widget.relatorioServico ?? RelatorioServico();
    _listarTecnicos =
        widget.listarTecnicos ?? ListarTecnicos(TecnicoRepositorioAdaptativo());
    _listarClientes =
        widget.listarClientes ?? ListarClientes(ClienteRepositorioAdaptativo());
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
    setState(() => _carregando = true);

    final filtros = FiltrosRelatorio(
      dataInicial: _dataInicial,
      dataFinal: _dataFinal,
      idTecnico: _tecnicoSelecionado?.id,
      idCliente: _clienteSelecionado?.id,
      status: _statusSelecionado != null ? [_statusSelecionado!] : null,
    );

    try {
      final resultado =
          await _relatorioServico.gerarRelatorioOrdensServico(filtros);

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
            content: Text('Erro ao gerar relatório: $e'),
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
                final tecnico = await Navigator.push<Tecnico>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => TelaBusca<Tecnico>(
                            titulo: 'Selecionar Técnico',
                            futureItens: _listarTecnicos.executar(),
                            getNomeItem: (t) => t.nome)));
                if (tecnico != null) {
                  setState(() => _tecnicoSelecionado = tecnico);
                }
              },
              child: InputDecorator(
                decoration:
                    const InputDecoration(labelText: 'Filtrar por Técnico'),
                child: Text(_tecnicoSelecionado?.nome ?? 'Todos'),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                final cliente = await Navigator.push<Cliente>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => TelaBusca<Cliente>(
                            titulo: 'Selecionar Cliente',
                            futureItens: _listarClientes.executar(),
                            getNomeItem: (c) => c.nome)));
                if (cliente != null) {
                  setState(() => _clienteSelecionado = cliente);
                }
              },
              child: InputDecorator(
                decoration:
                    const InputDecoration(labelText: 'Filtrar por Cliente'),
                child: Text(_clienteSelecionado?.nome ?? 'Todos'),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _statusSelecionado,
              hint: const Text('Todos'),
              decoration:
                  const InputDecoration(labelText: 'Filtrar por Status'),
              items: ['Pendente', 'Em Andamento', 'Concluída', 'Reaberta']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _statusSelecionado = val);
                }
              },
            ),
            const SizedBox(height: 40),
            _carregando
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _gerarRelatorio,
                    icon: const Icon(Icons.search),
                    label: const Text('GERAR RELATÓRIO'),
                  ),
          ],
        ),
      ),
    );
  }
}