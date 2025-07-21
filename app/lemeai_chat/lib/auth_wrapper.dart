// lib/auth_wrapper.dart - VERSÃO COM API CUSTOMIZADA

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lemeai_chat/login_screen.dart';
import 'package:lemeai_chat/main.dart'; // Import da ChatListScreen

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _storage = const FlutterSecureStorage();

  // Função que verifica se existe um token salvo
  Future<String?> _getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  @override
  Widget build(BuildContext context) {
    // Usamos um FutureBuilder para esperar o resultado da verificação do token
    return FutureBuilder<String?>(
      future: _getToken(),
      builder: (context, snapshot) {
        // Enquanto verifica, mostramos uma tela de carregamento
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // Se o snapshot tem um token (não é nulo), o usuário está logado
        if (snapshot.hasData && snapshot.data != null) {
          return const ChatListScreen();
        }

        // Senão, ele precisa fazer login
        return const LoginScreen();
      },
    );
  }
}