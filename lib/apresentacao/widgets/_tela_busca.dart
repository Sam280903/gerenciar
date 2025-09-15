// lib/apresentacao/widgets/_tela_busca.dart
import 'package:flutter/material.dart';

class TelaBusca<T> extends StatefulWidget {
  final String titulo;
  final Future<List<T>> futureItens;
  final String Function(T) getNomeItem;

  const TelaBusca({
    super.key,
    required this.titulo,
    required this.futureItens,
    required this.getNomeItem,
  });

  @override
  State<TelaBusca<T>> createState() => _TelaBuscaState<T>();
}

class _TelaBuscaState<T> extends State<TelaBusca<T>> {
  List<T> _todosItens = [];
  List<T> _itensFiltrados = [];
  final _buscaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.futureItens.then((lista) {
      if (mounted) {
        setState(() {
          _todosItens = lista;
          _itensFiltrados = lista;
        });
      }
    });
    _buscaController.addListener(_filtrarItens);
  }

  void _filtrarItens() {
    final query = _buscaController.text.toLowerCase();
    setState(() {
      _itensFiltrados = _todosItens
          .where(
              (item) => widget.getNomeItem(item).toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _buscaController,
              decoration: const InputDecoration(
                labelText: 'Buscar...',
                prefixIcon: Icon(Icons.search),
              ),
              autofocus: true,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<T>>(
              future: widget.futureItens,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _todosItens.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Erro: ${snapshot.error}"));
                }
                if (_itensFiltrados.isEmpty) {
                  return const Center(child: Text("Nenhum item encontrado."));
                }
                return ListView.builder(
                  itemCount: _itensFiltrados.length,
                  itemBuilder: (context, index) {
                    final item = _itensFiltrados[index];
                    return ListTile(
                      title: Text(widget.getNomeItem(item)),
                      onTap: () => Navigator.of(context).pop(item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
