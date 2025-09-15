// lib/apresentacao/telas/login/login_tela.dart

import 'package:flutter/material.dart';
import 'package:gerenciar/app/rotas.dart';
import '../../../servicos/autenticacao_servico.dart';

class LoginTela extends StatefulWidget {
  const LoginTela({super.key});

  @override
  State<LoginTela> createState() => _LoginTelaState();
}

class _LoginTelaState extends State<LoginTela>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authServico = AutenticacaoServico();

  bool _ocultarSenha = true;
  bool _carregando = false;
  String? _mensagemErro;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _fazerLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _carregando = true;
      _mensagemErro = null;
    });

    try {
      final usuario = await _authServico.login(
        _emailController.text.trim(),
        _senhaController.text,
      );
      if (mounted && usuario != null) {
        Navigator.pushReplacementNamed(context, Rotas.home);
      }
    } catch (e) {
      if (mounted) {
        setState(
            () => _mensagemErro = e.toString().replaceFirst("Exception: ", ""));
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- ALTERAÇÃO AQUI ---
                    Image.asset('assets/imagens/logo_gerenciar.png',
                        height: 120),
                    const SizedBox(height: 48),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty ? 'Informe o e-mail' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _senhaController,
                      obscureText: _ocultarSenha,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_ocultarSenha
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () =>
                              setState(() => _ocultarSenha = !_ocultarSenha),
                        ),
                      ),
                      validator: (v) => v!.isEmpty ? 'Informe a senha' : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, Rotas.redefinirSenha),
                        child: const Text('Esqueci a senha'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_mensagemErro != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _mensagemErro!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 14),
                        ),
                      ),
                    if (_carregando)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: _fazerLogin,
                        child: const Text('ENTRAR'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
