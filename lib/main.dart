import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; // 1. Importe o pacote
import 'aplicativo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 2. Inicialize as informações de data para o Brasil
  await initializeDateFormatting('pt_BR', null);

  runApp(const GerenciarApp());
}
