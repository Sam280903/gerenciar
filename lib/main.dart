// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gerenciar/servicos/sincronizacao_servico.dart';
import 'aplicativo.dart';

// Esta função precisa ficar fora de qualquer classe (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Se você precisar fazer algo com a notificação em background,
  // como inicializar outros serviços, faça aqui.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('pt_BR', null);

  // --- CONFIGURAÇÃO DE NOTIFICAÇÃO ADICIONADA AQUI ---
  // Define o handler para mensagens em background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Pede permissão para o usuário (necessário para Android 13+ e iOS)
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Garante que as notificações apareçam quando o app está em primeiro plano
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  // --- FIM DA CONFIGURAÇÃO DE NOTIFICAÇÃO ---

  // Inicia a verificação de sincronização em segundo plano
  SincronizacaoServico().iniciarSincronizacaoPeriodica();

  runApp(const GerenciarApp());
}
