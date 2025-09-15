// lib/apresentacao/telas/formas_pagamento/formas_pagamento_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/forma_pagamento/forma_pagamento_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/forma_pagamento/listar_formas_pagamento.dart';
import 'package:gerenciar/dominio/entidades/forma_pagamento.dart';
import 'cadastro_forma_pagamento_tela.dart';
import 'detalhes_forma_pagamento_tela.dart';

class FormasPagamentoTela extends StatefulWidget {
  const FormasPagamentoTela({super.key});
  @override
  State<FormasPagamentoTela> createState() => _FormasPagamentoTelaState();
}

class _FormasPagamentoTelaState extends State<FormasPagamentoTela> {
  late final ListarFormasPagamento _listar;
  Future<List<FormaPagamento>>? _futureFormas;
  bool _mostrarInativos = false;

  @override
  void initState() {
    super.initState();
    _listar = ListarFormasPagamento(FormaPagamentoRepositorioAdaptativo());
    _carregar();
  }

  void _carregar() {
    setState(() {
      _futureFormas = _listar.executar(incluirInativos: _mostrarInativos);
    });
  }

  void _abrirFormularioCadastro() async {
    final resultado = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: const CadastroFormaPagamentoTela(),
      ),
    );
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
      body: RefreshIndicator(
        onRefresh: () async => _carregar(),
        child: FutureBuilder<List<FormaPagamento>>(
          future: _futureFormas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erro ao carregar: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text(_mostrarInativos
                      ? 'Nenhuma forma de pagamento encontrada.'
                      : 'Nenhuma forma de pagamento ativa.'));
            }
            final formas = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
              itemCount: formas.length,
              itemBuilder: (context, index) {
                final forma = formas[index];
                return Card(
                  color:
                      forma.ativo ? null : Colors.grey.shade800.withAlpha(150),
                  child: ListTile(
                    leading: Icon(forma.ativo
                        ? Icons.payment_outlined
                        : Icons.money_off_csred_outlined),
                    title: Text(forma.nome,
                        style: TextStyle(
                            decoration: forma.ativo
                                ? TextDecoration.none
                                : TextDecoration.lineThrough)),
                    subtitle: Text(forma.descricao ?? 'Sem descrição'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _abrirDetalhes(forma),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
