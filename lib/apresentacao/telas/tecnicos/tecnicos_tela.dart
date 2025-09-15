// lib/apresentacao/telas/tecnicos/tecnicos_tela.dart
import 'package:flutter/material.dart';
import 'package:gerenciar/dados/repositorios/tecnico/tecnico_repositorio_adaptativo.dart';
import 'package:gerenciar/dominio/casos_uso/tecnico/listar_tecnicos.dart';
import 'package:gerenciar/dominio/entidades/tecnico.dart';
import 'cadastro_tecnico_tela.dart';
import 'detalhes_tecnico_tela.dart';

class TecnicosTela extends StatefulWidget {
  const TecnicosTela({super.key});
  @override
  State<TecnicosTela> createState() => _TecnicosTelaState();
}

class _TecnicosTelaState extends State<TecnicosTela> {
  late final ListarTecnicos _listarTecnicos;
  Future<List<Tecnico>>? _futureTecnicos;
  bool _mostrarInativos = false;

  @override
  void initState() {
    super.initState();
    _listarTecnicos = ListarTecnicos(TecnicoRepositorioAdaptativo());
    _carregarTecnicos();
  }

  void _carregarTecnicos() {
    setState(() {
      _futureTecnicos =
          _listarTecnicos.executar(incluirInativos: _mostrarInativos);
    });
  }

  void _abrirFormularioCadastro() async {
    final resultado = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => const CadastroTecnicoTela()));
    if (resultado == true) _carregarTecnicos();
  }

  void _abrirDetalhes(Tecnico tecnico) async {
    final resultado = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetalhesTecnicoTela(tecnico: tecnico)));
    if (resultado == true) _carregarTecnicos();
  }

  @override
  Widget build(BuildContext context) {
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormularioCadastro,
        icon: const Icon(Icons.add),
        label: const Text('NOVO TÉCNICO'),
      ),
      body: RefreshIndicator(
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
                          style: const TextStyle(color: Colors.white70))));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text(
                      _mostrarInativos
                          ? 'Nenhum técnico encontrado.'
                          : 'Nenhum técnico ativo cadastrado.',
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 16)));
            }
            final tecnicos = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 80),
              itemCount: tecnicos.length,
              itemBuilder: (context, index) {
                final tecnico = tecnicos[index];
                return Card(
                  color: tecnico.ativo
                      ? null
                      : Colors.grey.shade800.withAlpha(150),
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: ListTile(
                    leading: Icon(tecnico.ativo
                        ? Icons.engineering_outlined
                        : Icons.person_off_outlined),
                    title: Text(tecnico.nome,
                        style: TextStyle(
                            decoration: tecnico.ativo
                                ? TextDecoration.none
                                : TextDecoration.lineThrough)),
                    subtitle: Text(tecnico.email),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _abrirDetalhes(tecnico),
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
