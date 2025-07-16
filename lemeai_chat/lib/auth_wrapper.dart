// lib/auth_wrapper.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lemeai_chat/login_screen.dart';
import 'package:lemeai_chat/main.dart'; // Precisa do nome do seu pacote, verifique no pubspec.yaml

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Se o usuário está logado, mostra a tela de chats
        if (snapshot.hasData) {
          return const ChatListScreen();
        }
        // Senão, mostra a tela de login
        return const LoginScreen();
      },
    );
  }
}