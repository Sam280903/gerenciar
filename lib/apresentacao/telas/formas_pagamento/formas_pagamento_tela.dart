// lib/apresentacao/telas/formas_pagamento/formas_pagamento_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/forma_pagamento/forma_pagamento_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/cadastrar_forma_pagamento.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/listar_formas_pagamento.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'cadastro_forma_pagamento_tela.dart';
import 'detalhes_forma_pagamento_tela.dart';

class FormasPagamentoTela extends StatefulWidget {
  final ListarFormasPagamento? listarFormasPagamento;
  final CadastrarFormaPagamento? cadastrarFormaPagamento;
  final AutenticacaoServico? authServico;

  const FormasPagamentoTela(
      {super.key, this.listarFormasPagamento, this.cadastrarFormaPagamento, this.authServico});

  @override
  State<FormasPagamentoTela> createState() => _FormasPagamentoTelaState();
}

class _FormasPagamentoTelaState extends State<FormasPagamentoTela> {
  late final ListarFormasPagamento _listar;
  Future<List<FormaPagamento>>? _futureFormas;
  bool _mostrarInativos = false;

  List<FormaPagamento> _todasFormas = [];
  List<FormaPagamento> _formasFiltradas = [];
  final _buscaController = TextEditingController();

  late final AutenticacaoServico _authServico;
  String? _idGestor;

  @override
  void initState() {
    super.initState();
    _authServico = widget.authServico ?? AutenticacaoServico();
    _listar = widget.listarFormasPagamento ??
        ListarFormasPagamento(FormaPagamentoRepositorioAdaptativo());
    _carregarDadosIniciais();
    _buscaController.addListener(_filtrarFormas);
  }

  Future<void> _carregarDadosIniciais() async {
    final dadosUsuario = await _authServico.buscarDadosUsuarioLogado();
    if (mounted && dadosUsuario != null) {
      setState(() {
        _idGestor = dadosUsuario['idGestor'];
      });
      _carregar();
    }
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _filtrarFormas() {
    final query = _buscaController.text.toLowerCase();
    setState(() {
      _formasFiltradas = _todasFormas
          .where((forma) => forma.nome.toLowerCase().contains(query))
          .toList();
    });
  }

  void _carregar() {
    if (_idGestor == null) return;
    final future = _listar.executar(
        idGestor: _idGestor!, incluirInativos: _mostrarInativos);
    setState(() {
      _futureFormas = future;
    });

    future.then((lista) {
      if (mounted) {
        setState(() {
          _todasFormas = lista;
          _formasFiltradas = lista;
          _filtrarFormas();
        });
      }
    });
  }

  void _abrirFormularioCadastro() async {
    // --- CORREÇÃO APLICADA AQUI ---
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CadastroFormaPagamentoTela(
          cadastrarFormaPagamento: widget.cadastrarFormaPagamento,
        ),
      ),
    );
    // --- FIM DA CORREÇÃO ---
    if (resultado == true) _carregar();
  }

  void _abrirDetalhes(FormaPagamento forma) async {
    final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                DetalhesFormaPagamentoTela(formaPagamento: forma)));
    if (resultado == true) _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Formas de Pagamento"),
        actions: [
          IconButton(
            tooltip: _mostrarInativos ? 'Ocultar inativos' : 'Mostrar inativos',
            icon: Icon(_mostrarInativos
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
            onPressed: () {
              setState(() => _mostrarInativos = !_mostrarInativos);
              _carregar();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormularioCadastro,
        icon: const Icon(Icons.add),
        label: const Text('NOVA FORMA'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _buscaController,
              decoration: const InputDecoration(
                labelText: 'Buscar por nome...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _carregar(),
              child: FutureBuilder<List<FormaPagamento>>(
                future: _futureFormas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Erro ao carregar: ${snapshot.error}'));
                  }
                  if (_formasFiltradas.isEmpty) {
                    return Center(
                        child: Text(_buscaController.text.isNotEmpty
                            ? 'Nenhuma forma de pagamento encontrada.'
                            : 'Nenhuma forma de pagamento ativa.'));
                  }
                  final formas = _formasFiltradas;
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                    itemCount: formas.length,
                    itemBuilder: (context, index) {
                      final forma = formas[index];
                      return Card(
                        color: forma.ativo
                            ? null
                            : Colors.grey.shade800.withAlpha(150),
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        child: ListTile(
                          leading: Icon(forma.ativo
                              ? Icons.payment_outlined
                              : Icons.money_off_csred_outlined),
                          title: Text(forma.nome,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: forma.ativo
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough)),
                          subtitle: Text(forma.descricao ?? 'Sem descrição'),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _abrirDetalhes(forma),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
