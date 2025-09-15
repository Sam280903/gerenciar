// lib/apresentacao/telas/cadastro_gestor/cadastro_gestor_tela.dart

import 'package:flutter/material.dart';
import 'package:gerenciar/app/rotas.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';

class CadastroGestorTela extends StatefulWidget {
  const CadastroGestorTela({super.key});

  @override
  State<CadastroGestorTela> createState() => _CadastroGestorTelaState();
}

class _CadastroGestorTelaState extends State<CadastroGestorTela> {
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authServico = AutenticacaoServico();

  String? _mensagemErro;
  bool _carregando = false;

  Future<void> _cadastrarGestor() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      await _authServico.cadastrarPrimeiroGestor(
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(context, Rotas.home);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _mensagemErro = e.toString().replaceFirst("Exception: ", "");
        });
      }
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro do Gestor'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/imagens/logo_gerenciar.png', height: 170),
                const SizedBox(height: 48),
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                      labelText: 'Nome (usuário)',
                      prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'E-mail',
                      prefixIcon: Icon(Icons.email_outlined)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _senhaController,
                  decoration: const InputDecoration(
                      labelText: 'Senha', prefixIcon: Icon(Icons.lock_outline)),
                  obscureText: true,
                  validator: (v) {
                    if (v!.isEmpty) {
                      return 'Campo obrigatório';
                    }
                    if (v.length < 6) {
                      return 'A senha deve ter no mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmarSenhaController,
                  decoration: const InputDecoration(
                      labelText: 'Confirmar Senha',
                      prefixIcon: Icon(Icons.lock_outline)),
                  obscureText: true,
                  validator: (v) => v != _senhaController.text
                      ? 'As senhas não coincidem'
                      : null,
                ),
                const SizedBox(height: 32),
                if (_mensagemErro != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _mensagemErro!,
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _carregando
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _cadastrarGestor,
                        child: const Text('CADASTRAR'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
