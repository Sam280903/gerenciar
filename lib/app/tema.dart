// lib/app/tema.dart

import 'package:flutter/material.dart';
import '../constantes/cores.dart';

final ThemeData temaProfissional = ThemeData(
  // Esquema de cores principal, garantindo consistência.
  colorScheme: ColorScheme.fromSeed(
    seedColor: Cores.azulFundo,
    primary: Cores.azulCard,
    secondary: Colors.white,
    surface: Cores.azulFundo,
    brightness: Brightness
        .dark, // Isso faz com que textos e ícones fiquem claros por padrão.
  ),

  // Estilo da fonte padrão
  fontFamily: 'Roboto',

  // Tema do Scaffold (fundo das telas)
  scaffoldBackgroundColor: Cores.azulFundo,

  // Tema dos campos de texto (TextFormField)
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    // CORREÇÃO: Uso de .withAlpha() em vez de .withOpacity()
    fillColor: Colors.white.withAlpha(26), // Equivalente a ~0.1 de opacidade
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

    // Borda padrão (quando o campo não está focado)
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none, // Sem borda visível
    ),

    // Borda para quando o usuário clica no campo
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white, width: 2),
    ),

    // Estilo do texto de dica (label)
    // CORREÇÃO: Uso de .withAlpha() em vez de .withOpacity()
    labelStyle: TextStyle(color: Colors.white.withAlpha(179)), // ~0.7 opacidade

    // Estilo do ícone
    // CORREÇÃO: Uso de .withAlpha() em vez de .withOpacity()
    prefixIconColor: Colors.white.withAlpha(179), // ~0.7 opacidade
  ),

  // Tema dos botões principais (ElevatedButton)
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Cores.azulFundo,
      padding: const EdgeInsets.symmetric(vertical: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    ),
  ),

  // Tema dos botões secundários (OutlinedButton)
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 18),
      side: const BorderSide(color: Colors.white, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
    ),
  ),

  // Tema do botão de texto (TextButton)
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          // CORREÇÃO: Uso de .withAlpha() em vez de .withOpacity()
          foregroundColor: Colors.white.withAlpha(230), // ~0.9 opacidade
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
          ))),

  // Tema da AppBar (barra no topo)
  appBarTheme: const AppBarTheme(
    backgroundColor: Cores.azulFundo,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.bold,
    ),
  ),
);
