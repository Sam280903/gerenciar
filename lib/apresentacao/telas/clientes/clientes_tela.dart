import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/cliente/cliente_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/cliente/listar_clientes.dart';
import 'package:gerenciar/dominio/entidades/cliente.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart'; // ADICIONADO
import 'cadastro_cliente_tela.dart';
import 'detalhes_cliente_tela.dart';

class ClientesTela extends StatefulWidget {
  const ClientesTela({super.key});
  @override
  State<ClientesTela> createState() => _ClientesTelaState();
}

class _ClientesTelaState extends State<ClientesTela> {
  late final ListarClientes _listarClientes;
  Future<List<Cliente>>? _futureClientes;
  bool _mostrarInativos = false;

  List<Cliente> _todosClientes = [];
  List<Cliente> _clientesFiltrados = [];
  final _buscaController = TextEditingController();

  // ADICIONADO
  final AutenticacaoServico _authServico = AutenticacaoServico();
  String? _idGestor;

  @override
  void initState() {
    super.initState();
    _listarClientes = ListarClientes(ClienteRepositorioAdaptativo());
    _carregarDadosIniciais(); // MÉTODO ALTERADO
    _buscaController.addListener(_filtrarClientes);
  }

  // NOVO MÉTODO
  Future<void> _carregarDadosIniciais() async {
    final dadosUsuario = await _authServico.buscarDadosUsuarioLogado();
    if (mounted && dadosUsuario != null) {
      setState(() {
        _idGestor = dadosUsuario['idGestor'];
      });
      _carregarClientes();
    }
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _filtrarClientes() {
    final query = _buscaController.text.toLowerCase();
    setState(() {
      _clientesFiltrados = _todosClientes
          .where((cliente) => cliente.nome.toLowerCase().contains(query))
          .toList();
    });
  }

  void _carregarClientes() {
    if (_idGestor == null) return; // Não carrega se não souber o gestor

    // ALTERADO: Passa o idGestor para o caso de uso
    final future = _listarClientes.executar(
        idGestor: _idGestor!, incluirInativos: _mostrarInativos);

    setState(() {
      _futureClientes = future;
    });

    future.then((lista) {
      if (mounted) {
        setState(() {
          _todosClientes = lista;
          _clientesFiltrados = lista;
          _filtrarClientes();
        });
      }
    });
  }

  void _abrirFormularioCadastro() async {
    final resultado = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const CadastroClienteTela()));
    if (resultado == true) _carregarClientes();
  }

  void _abrirDetalhes(Cliente cliente) async {
    final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetalhesClienteTela(cliente: cliente)));
    if (resultado == true) _carregarClientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Clientes"),
        actions: [
          IconButton(
            tooltip: _mostrarInativos ? 'Ocultar inativos' : 'Mostrar inativos',
            icon: Icon(_mostrarInativos
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
            onPressed: () {
              setState(() => _mostrarInativos = !_mostrarInativos);
              _carregarClientes();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormularioCadastro,
        icon: const Icon(Icons.add),
        label: const Text('NOVO CLIENTE'),
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
              onRefresh: () async => _carregarClientes(),
              child: FutureBuilder<List<Cliente>>(
                future: _futureClientes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                                'Erro ao carregar clientes:\n${snapshot.error}',
                                textAlign: TextAlign.center,
                                style:
                                    const TextStyle(color: Colors.white70))));
                  }
                  if (_clientesFiltrados.isEmpty) {
                    return Center(
                        child: Text(
                            _buscaController.text.isNotEmpty
                                ? 'Nenhum cliente encontrado.'
                                : 'Nenhum cliente ativo cadastrado.',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16)));
                  }
                  final clientes = _clientesFiltrados;
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                    itemCount: clientes.length,
                    itemBuilder: (context, index) {
                      final cliente = clientes[index];
                      return Card(
                        color: cliente.ativo
                            ? null
                            : Colors.grey.shade800.withAlpha(150),
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        child: ListTile(
                          leading: Icon(cliente.ativo
                              ? Icons.person_outline
                              : Icons.person_off_outlined),
                          title: Text(cliente.nome,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: cliente.ativo
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough)),
                          subtitle: Text(cliente.telefone),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _abrirDetalhes(cliente),
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