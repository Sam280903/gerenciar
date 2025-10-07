// lib/apresentacao/telas/tecnicos/tecnicos_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/listar_tecnicos.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';
import 'cadastro_tecnico_tela.dart';
import 'detalhes_tecnico_tela.dart';

class TecnicosTela extends StatefulWidget {
  // Dependências injetáveis para facilitar os testes
  final AutenticacaoServico? authServico;
  final ListarTecnicos? listarTecnicos;

  const TecnicosTela({super.key, this.authServico, this.listarTecnicos});
  @override
  State<TecnicosTela> createState() => _TecnicosTelaState();
}

class _TecnicosTelaState extends State<TecnicosTela> {
  late final ListarTecnicos _listarTecnicos;
  late final AutenticacaoServico _authServico;

  Future<List<Tecnico>>? _futureTecnicos;
  bool _mostrarInativos = false;

  List<Tecnico> _todosTecnicos = [];
  List<Tecnico> _tecnicosFiltrados = [];
  final _buscaController = TextEditingController();

  String _perfilUsuario = "";
  String? _idGestor;

  @override
  void initState() {
    super.initState();
    // Usa as dependências injetadas ou cria instâncias padrão
    _listarTecnicos =
        widget.listarTecnicos ?? ListarTecnicos(TecnicoRepositorioAdaptativo());
    _authServico = widget.authServico ?? AutenticacaoServico();

    _carregarDadosIniciais();
    _buscaController.addListener(_filtrarTecnicos);
  }

  // O restante do arquivo permanece o mesmo até o método _abrirFormularioCadastro
  Future<void> _carregarDadosIniciais() async {
    final dados = await _authServico.buscarDadosUsuarioLogado();
    if (dados != null && mounted) {
      setState(() {
        _perfilUsuario = dados['perfil'] ?? '';
        _idGestor = dados['idGestor'];
      });
      _carregarTecnicos();
    }
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  void _filtrarTecnicos() {
    final query = _buscaController.text.toLowerCase();
    setState(() {
      _tecnicosFiltrados = _todosTecnicos
          .where((tecnico) => tecnico.nome.toLowerCase().contains(query))
          .toList();
    });
  }

  void _carregarTecnicos() {
    if (_idGestor == null) return;

    final future = _listarTecnicos.executar(
        idGestor: _idGestor!, incluirInativos: _mostrarInativos);
    setState(() {
      _futureTecnicos = future;
    });

    future.then((lista) {
      if (mounted) {
        setState(() {
          _todosTecnicos = lista;
          _tecnicosFiltrados = lista;
          _filtrarTecnicos();
        });
      }
    });
  }

  // --- CORREÇÃO PRINCIPAL AQUI ---
  void _abrirFormularioCadastro() async {
    final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => CadastroTecnicoTela(
                  // Injeta o serviço de autenticação na tela de cadastro
                  authServico: _authServico,
                )));
    if (resultado == true) _carregarTecnicos();
  }
  // --- FIM DA CORREÇÃO ---

  void _abrirDetalhes(Tecnico tecnico) async {
    final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetalhesTecnicoTela(tecnico: tecnico)));
    if (resultado == true) _carregarTecnicos();
  }

  @override
  Widget build(BuildContext context) {
    // O método build permanece o mesmo...
    return Scaffold(
      appBar: AppBar(
        title: const Text("Técnicos"),
        actions: [
          IconButton(
            tooltip: _mostrarInativos ? 'Ocultar inativos' : 'Mostrar inativos',
            icon: Icon(_mostrarInativos
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
            onPressed: () {
              setState(() => _mostrarInativos = !_mostrarInativos);
              _carregarTecnicos();
            },
          ),
        ],
      ),
      floatingActionButton: _perfilUsuario == 'gestor'
          ? FloatingActionButton.extended(
              onPressed: _abrirFormularioCadastro,
              icon: const Icon(Icons.add),
              label: const Text('NOVO TÉCNICO'),
            )
          : null,
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
              onRefresh: () async => _carregarTecnicos(),
              child: FutureBuilder<List<Tecnico>>(
                future: _futureTecnicos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                                'Erro ao carregar técnicos:\n${snapshot.error}',
                                textAlign: TextAlign.center,
                                style:
                                    const TextStyle(color: Colors.white70))));
                  }
                  if (_tecnicosFiltrados.isEmpty) {
                    return Center(
                        child: Text(
                            _buscaController.text.isNotEmpty
                                ? 'Nenhum técnico encontrado.'
                                : 'Nenhum técnico ativo cadastrado.',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 16)));
                  }
                  final tecnicos = _tecnicosFiltrados;
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
                    itemCount: tecnicos.length,
                    itemBuilder: (context, index) {
                      final tecnico = tecnicos[index];
                      return Card(
                        color: tecnico.ativo
                            ? null
                            : Colors.grey.shade800.withAlpha(150),
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        child: ListTile(
                          leading: Icon(tecnico.ativo
                              ? Icons.engineering_outlined
                              : Icons.person_off_outlined),
                          title: Text(tecnico.nome,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: tecnico.ativo
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough)),
                          subtitle: Text(tecnico.telefone),
                          trailing:
                              const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _abrirDetalhes(tecnico),
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
