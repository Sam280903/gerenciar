// lib/servicos/autenticacao_servico.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AutenticacaoServico {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> enviarEmailRedefinicaoSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_traduzirErro(e.code));
    } catch (e) {
      throw Exception('Algo deu errado. Verifique sua conexão e tente novamente.');
    }
  }

  Future<User?> login(String email, String senha) async {
    try {
      final credenciais = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      if (credenciais.user != null) {
        // Vincula o UID do Firebase ao OneSignal
        OneSignal.login(credenciais.user!.uid);
      }

      return credenciais.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_traduzirErro(e.code));
    }
  }

  Future<void> logout() async {
    await OneSignal.logout(); // Remove o vínculo do usuário com o aparelho
    await _auth.signOut();
  }

  User? get usuarioAtual => _auth.currentUser;

  String _traduzirErro(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Não encontramos uma conta com este e-mail. Tem certeza de que digitou corretamente?';
      case 'INVALID_LOGIN_CREDENTIALS':
      case 'invalid-credential':
        return 'E-mail ou senha estão incorretos. Verifique seus dados e tente de novo.';
      case 'wrong-password':
        return 'A senha informada não confere. Tente novamente ou use a opção "Esqueci a senha".';
      case 'invalid-email':
        return 'O endereço de e-mail parece estar incorreto. Verifique se há algum erro de digitação.';
      case 'email-already-in-use':
        return 'Este e-mail já está sendo usado por outra conta.';
      case 'weak-password':
        return 'A senha que você escolheu é muito simples. Use uma mais segura com letras e números.';
      case 'network-request-failed':
        return 'Ops! Parece que você está sem internet. Verifique sua conexão e tente novamente.';
      case 'too-many-requests':
        return 'Muitas tentativas sem sucesso. Por segurança, aguarde alguns minutos e tente novamente.';
      case 'user-disabled':
        return 'O acesso a esta conta foi bloqueado. Por favor, entre em contato com um administrador.';
      case 'operation-not-allowed':
        return 'Esta operação não está autorizada no momento.';
      default:
        // Caso ocorra algo imprevisto, entregamos uma mensagem amigável sem códigos técnicos.
        return 'Ocorreu um erro inesperado e não foi possível concluir a ação. Tente novamente mais tarde.';
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

  // MÉTODO ALTERADO
  Future<User?> cadastrarPrimeiroGestor({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final credenciais = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      final usuario = credenciais.user;

      if (usuario != null) {
        // O idGestor de um gestor é o seu próprio ID de usuário
        final idGestor = usuario.uid;

        await _firestore.collection('usuarios').doc(usuario.uid).set({
          'nome': nome,
          'email': email,
          'perfil': 'gestor',
          'ativo': true,
          'idGestor': idGestor, // ADICIONADO
        });

        await _firestore.collection('gestores').doc(usuario.uid).set({
          'nome': nome,
          'email': email,
          'idUsuario': usuario.uid,
          'ativo': true,
          'idGestor': idGestor, // ADICIONADO
        });

        await _firestore.collection('configuracao').doc('sistema').set({
          'primeiroGestorCadastrado': true,
        });
      }
      return usuario;
    } on FirebaseAuthException catch (e) {
      throw Exception(_traduzirErro(e.code));
    } catch (e) {
      throw Exception('Ops! Não foi possível realizar o cadastro no momento. Tente novamente mais tarde.');
    }
  }

  // MÉTODO ALTERADO
  Future<User?> cadastrarTecnico({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
  }) async {
    try {
      // Pega o ID do gestor que está logado no momento
      final idGestor = _auth.currentUser?.uid;
      if (idGestor == null) {
        throw Exception("Nenhum gestor logado para cadastrar o técnico.");
      }

      final credenciais = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      final usuario = credenciais.user;

      if (usuario != null) {
        await _firestore.collection('usuarios').doc(usuario.uid).set({
          'nome': nome,
          'email': email,
          'perfil': 'tecnico',
          'ativo': true,
          'idGestor': idGestor, // ADICIONADO
        });

        await _firestore.collection('tecnicos').doc(usuario.uid).set({
          'id': usuario.uid,
          'nome': nome,
          'email': email,
          'telefone': telefone,
          'ativo': true,
          'idGestor': idGestor, // ADICIONADO
        });
      }
      return usuario;
    } on FirebaseAuthException catch (e) {
      throw Exception(_traduzirErro(e.code));
    } catch (e) {
      throw Exception('Poxa vida! Não conseguimos finalizar o cadastro do técnico agora. Tente de novo em breve.');
    }
  }

  // MÉTODO REMOVIDO
  // Future<void> salvarTokenDoDispositivo() async {
  //   ...
  // }

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
