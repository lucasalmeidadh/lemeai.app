// lib/main.dart - VERSÃO FINAL COM API CUSTOMIZADA

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_wrapper.dart';
import 'chat_detail_screen.dart';
import 'firebase_options.dart';
import 'auth_service.dart'; // Nosso novo serviço
import 'login_screen.dart'; // Precisamos para o logout

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leme Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  // Carrega o ID do usuário do token quando a tela inicia
  void _loadCurrentUser() async {
    final userId = await _authService.getUserIdFromToken();
    setState(() {
      _currentUserId = userId;
    });
  }
  
  // A lógica de logout agora usa nosso AuthService
  void _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _startNewChat() async {
    // ... (Esta função precisa do _currentUserId, que agora carregamos no initState)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conversas", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(onPressed: _handleLogout, icon: const Icon(Icons.logout_outlined)),
        ],
      ),
      // Se ainda não sabemos qual é o usuário, mostramos um loader
      body: _currentUserId == null
          ? const Center(child: CircularProgressIndicator())
          : buildChatList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        child: const Icon(Icons.add),
      ),
    );
  }

  // A construção da lista agora usa a variável _currentUserId
  Widget buildChatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('chats')
          .where('users', arrayContains: _currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Nenhuma conversa por aqui.\nClique no botão '+' para iniciar uma.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
            ),
          );
        }

        final chats = snapshot.data!.docs;
        return ListView.separated(
          itemCount: chats.length,
          separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, indent: 75, endIndent: 16, color: Color(0xFFF0F0F0)),
          itemBuilder: (context, index) {
            final chat = chats[index];
            final chatData = chat.data() as Map<String, dynamic>;
            final List<dynamic> users = chatData['users'];
            final otherUserId = users.firstWhere((id) => id != _currentUserId);

            return FutureBuilder<DocumentSnapshot>(
              future: _firestore.collection('users').doc(otherUserId).get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) return const SizedBox(height: 72);
                final otherUserData = userSnapshot.data!.data() as Map<String, dynamic>;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(radius: 28, backgroundColor: Colors.grey[200], child: Text(otherUserData['email'][0].toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
                  title: Text(otherUserData['email'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Última mensagem vai aqui...", style: TextStyle(color: Colors.grey[600])),
                  trailing: Text("14:30", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(chatId: chat.id, otherUserName: otherUserData['email'], otherUserAvatar: ""),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}