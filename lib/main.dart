// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:gerenciar/servicos/sincronizacao_servico.dart'; // Importe o novo serviço
import 'aplicativo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('pt_BR', null);

  // Inicia a verificação de sincronização em segundo plano
  SincronizacaoServico().iniciarSincronizacaoPeriodica();

  runApp(const GerenciarApp());
}