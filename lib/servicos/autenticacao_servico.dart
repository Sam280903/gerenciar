// lib/servicos/autenticacao_servico.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class AutenticacaoServico {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // NOVO MÉTODO ADICIONADO
  Future<void> enviarEmailRedefinicaoSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Nenhum usuário encontrado para este e-mail.');
      } else {
        throw Exception('Ocorreu um erro. Tente novamente.');
      }
    }
  }

  Future<User?> login(String email, String senha) async {
    try {
      final credenciais = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      
      // *** MUDANÇA ADICIONADA AQUI ***
      if (credenciais.user != null) {
        // Agora, sempre que o login for bem-sucedido...
        await salvarTokenDoDispositivo(); // ...o token do dispositivo é salvo no Firebase.
      }
      
      return credenciais.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_traduzirErro(e.code));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get usuarioAtual => _auth.currentUser;

  String _traduzirErro(String code) {
    switch (code) {
      case 'user-not-found':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Usuário ou senha incorretos.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-email':
        return 'E-mail inválido.';
      default:
        return 'Erro ao fazer login. [$code]';
    }
  }

  Future<bool> primeiroGestorJaCadastrado() async {
    try {
      final doc =
          await _firestore.collection('configuracao').doc('sistema').get();
      if (doc.exists) {
        return doc.data()?['primeiroGestorCadastrado'] ?? false;
      }
      return false;
    } catch (e) {
      // ignore: avoid_print
      print("Erro ao verificar primeiro gestor: $e");
      return false;
    }
  }

  Future<User?> cadastrarPrimeiroGestor({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      // 1. Cria o usuário no Firebase Authentication
      final credenciais = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      final usuario = credenciais.user;

      if (usuario != null) {
        // 2. Cria o documento na coleção 'usuarios'
        await _firestore.collection('usuarios').doc(usuario.uid).set({
          'nome': nome,
          'email': email,
          'perfil': 'gestor',
          'ativo': true,
        });

        // 3. Cria o documento correspondente na coleção 'gestores'
        await _firestore.collection('gestores').doc(usuario.uid).set({
          'nome': nome,
          'email': email,
          'idUsuario': usuario.uid, // Vincula ao usuário
          'ativo': true,
        });

        // 4. Atualiza a configuração do sistema
        await _firestore.collection('configuracao').doc('sistema').set({
          'primeiroGestorCadastrado': true,
        });
      }
      return usuario;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Este e-mail já está em uso.');
      }
      if (e.code == 'weak-password') {
        throw Exception('A senha fornecida é muito fraca.');
      }
      throw Exception('Erro ao cadastrar: ${e.message}');
    }
  }

  //MÉTODO PARA CADASTRAR TÉCNICO ---
  Future<User?> cadastrarTecnico({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
  }) async {
    try {
      // Cria um usuário temporário para o técnico
      final credenciais = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      final usuario = credenciais.user;

      if (usuario != null) {
        // Adiciona na coleção 'usuarios'
        await _firestore.collection('usuarios').doc(usuario.uid).set({
          'nome': nome,
          'email': email,
          'perfil': 'tecnico',
          'ativo': true,
        });

        // Adiciona na coleção 'tecnicos'
        await _firestore.collection('tecnicos').doc(usuario.uid).set({
          'id': usuario.uid,
          'nome': nome,
          'email': email,
          'telefone': telefone,
          'ativo': true,
        });
      }
      return usuario;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('Este e-mail já está em uso por outro usuário.');
      }
      throw Exception('Erro ao cadastrar técnico: ${e.message}');
    }
  }

  Future<void> salvarTokenDoDispositivo() async {
    final usuario = _auth.currentUser;
    if (usuario == null) return;

    await _fcm.requestPermission();
    final token = await _fcm.getToken();

    if (token != null) {
      final tokensRef = _firestore
          .collection('usuarios')
          .doc(usuario.uid)
          .collection('tokens')
          .doc(token);

      await tokensRef.set({
        'token': token,
        'criadoEm': FieldValue.serverTimestamp(),
      });
      // ignore: avoid_print
      print('Token salvo com sucesso: $token');
    }
  }

  Future<Map<String, dynamic>?> buscarDadosUsuarioLogado() async {
    final usuario = _auth.currentUser;
    if (usuario != null) {
      final docSnapshot =
          await _firestore.collection('usuarios').doc(usuario.uid).get();
      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
    }
    return null;
  }
}
