// lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// IMPORT REMOVIDO:
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gerenciar/servicos/sincronizacao_servico.dart';
import 'package:gerenciar/servicos/migracao_servico.dart';
import 'aplicativo.dart';

// IMPORT ADICIONADO:
import 'package:onesignal_flutter/onesignal_flutter.dart';

// FUNÇÃO EM BACKGROUND REMOVIDA:
/*
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // ...
}
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase
      .initializeApp(); // Isso continua, pois você usa Firebase Auth/Firestore
  await initializeDateFormatting('pt_BR', null);

  // BLOCO INTEIRO DO FIREBASE MESSAGING REMOVIDO:
  /*
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

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

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  */

  SincronizacaoServico().iniciarSincronizacao();

  // Executa migrações pendentes de dados no Firestore
  MigracaoServico().executarMigracoesPendentes();

  // --- INÍCIO DO BLOCO DO ONESIGNAL ---

  // Coloque aqui o App ID que você pegou no painel do OneSignal
  // (Este é o passo 1 que mencionei antes)
  OneSignal.initialize("a0e5e812-11d0-46f9-8019-4992adacdb83");

  // Solicita permissão para exibir notificações
  OneSignal.Notifications.requestPermission(true);

  // Opcional: Adiciona um "ouvinte" para quando o usuário clicar na notificação
  OneSignal.Notifications.addClickListener((event) {
    if (kDebugMode)
      debugPrint('Notificação clicada: ${event.notification.title}');
  });

  // --- FIM DO BLOCO DO ONESIGNAL ---

  runApp(const GerenciarApp());
}
