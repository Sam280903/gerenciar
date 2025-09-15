// lib/apresentacao/telas/redefinir_senha/redefinir_senha_tela.dart

import 'package:flutter/material.dart';
import 'package:gerenciar/servicos/autenticacao_servico.dart';

class RedefinirSenhaTela extends StatefulWidget {
  const RedefinirSenhaTela({super.key});

  @override
  State<RedefinirSenhaTela> createState() => _RedefinirSenhaTelaState();
}

class _RedefinirSenhaTelaState extends State<RedefinirSenhaTela> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authServico = AutenticacaoServico();

  bool _carregando = false;
  String? _mensagemErro;
  String? _mensagemSucesso;

  Future<void> _enviarEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _carregando = true;
        _mensagemErro = null;
        _mensagemSucesso = null;
      });

      try {
        await _authServico
            .enviarEmailRedefinicaoSenha(_emailController.text.trim());
        if (mounted) {
          setState(() {
            _mensagemSucesso =
                'E-mail de redefinição enviado! Verifique sua caixa de entrada.';
          });
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Redefinir Senha'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/imagens/logo_gerenciar.png', height: 100),
                const SizedBox(height: 24),
                const Text(
                  'Digite seu e-mail para receber as instruções de como redefinir sua senha.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Informe o e-mail' : null,
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
                if (_mensagemSucesso != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _mensagemSucesso!,
                      style: const TextStyle(color: Colors.greenAccent),
                      textAlign: TextAlign.center,
                    ),
                  ),
                _carregando
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _enviarEmail,
                        child: const Text('ENVIAR E-MAIL'),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
