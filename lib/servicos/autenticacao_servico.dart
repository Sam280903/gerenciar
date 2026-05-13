// lib/servicos/autenticacao_servico.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
    _cacheUsuario = null;
    _cacheUid = null;
    _cacheTimestamp = null;
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
      if (kDebugMode) debugPrint("Erro ao verificar primeiro gestor: $e");
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

      // Usa uma instância secundária do Firebase para criar o usuário
      // sem deslogar o gestor da instância principal
      FirebaseApp tempApp = await Firebase.initializeApp(
        name: 'tempAuthApp_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      try {
        final tempAuth = FirebaseAuth.instanceFor(app: tempApp);
        final credenciais = await tempAuth.createUserWithEmailAndPassword(
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
            'idGestor': idGestor,
          });

          await _firestore.collection('tecnicos').doc(usuario.uid).set({
            'id': usuario.uid,
            'nome': nome,
            'email': email,
            'telefone': telefone,
            'ativo': true,
            'idGestor': idGestor,
          });
        }

        await tempAuth.signOut();
        return usuario;
      } finally {
        await tempApp.delete();
      }
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

  // Cache em memória para evitar leituras repetidas no Firestore
  static Map<String, dynamic>? _cacheUsuario;
  static String? _cacheUid;
  static DateTime? _cacheTimestamp;
  static const Duration _cacheTTL = Duration(minutes: 30);

  Future<Map<String, dynamic>?> buscarDadosUsuarioLogado({bool forcarAtualizacao = false}) async {
    final usuario = _auth.currentUser;
    if (usuario == null) return null;

    // Verifica se cache é válido (TTL não expirado)
    final cacheValido = _cacheTimestamp != null &&
        DateTime.now().difference(_cacheTimestamp!) < _cacheTTL;

    // Retorna cache se o UID for o mesmo, não foi pedida atualização forçada e cache é válido
    if (!forcarAtualizacao && _cacheUid == usuario.uid &&
        _cacheUsuario != null && cacheValido) {
      return _cacheUsuario;
    }

    try {
      final docSnapshot =
          await _firestore.collection('usuarios').doc(usuario.uid).get();
      if (docSnapshot.exists) {
        _cacheUid = usuario.uid;
        _cacheUsuario = docSnapshot.data();
        _cacheTimestamp = DateTime.now();
        return _cacheUsuario;
      }
    } catch (e) {
      // Se estiver offline, retorna o cache anterior se houver
      if (_cacheUid == usuario.uid && _cacheUsuario != null) {
        return _cacheUsuario;
      }
      if (kDebugMode) debugPrint('Erro ao buscar dados do usuário: $e');
    }
    return null;
  }
}
