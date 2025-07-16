// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_wrapper.dart';
import 'chat_detail_screen.dart';
import 'firebase_options.dart';

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
      title: 'LemeAI Chat',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

// TELA DE LISTA DE CHATS TOTALMENTE DINÂMICA
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Função para iniciar um novo chat
  Future<void> _startNewChat() async {
    // AVISO: Precisamos do context aqui, antes do 'await'
    // Se o widget for destruído, não podemos chamar o showDialog
    if (!mounted) return;

    final TextEditingController emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) { // Usamos um context diferente para o dialog
        return AlertDialog(
          title: const Text("Iniciar Nova Conversa"),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(hintText: "Email do usuário"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final otherUserQuery = await _firestore
                    .collection('users')
                    .where('email', isEqualTo: emailController.text.trim())
                    .limit(1)
                    .get();

                if (otherUserQuery.docs.isNotEmpty) {
                  final otherUser = otherUserQuery.docs.first;
                  final currentUser = _auth.currentUser!;
                  
                  final ids = [currentUser.uid, otherUser.id];
                  ids.sort();
                  final chatId = ids.join('_');

                  await _firestore.collection('chats').doc(chatId).set({
                    'users': [currentUser.uid, otherUser.id],
                    // Podemos adicionar mais campos aqui no futuro
                  });
                  
                  // A SOLUÇÃO: Checar se o widget ainda está montado
                  // antes de usar o context do Navigator.
                  // Usamos o context do dialog que passamos no builder.
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop(); // Fecha o dialog
                  }

                }
                // Opcional: Adicionar um 'else' para avisar se o usuário não foi encontrado
              },
              child: const Text("Iniciar"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // O resto do seu código do método build continua igual...
    // Pode colar o método build que já estava aqui.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversas'),
        actions: [IconButton(onPressed: () => _auth.signOut(), icon: const Icon(Icons.logout))],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('chats')
            .where('users', arrayContains: _auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Nenhuma conversa encontrada."));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final chatData = chat.data() as Map<String, dynamic>;
              final List<dynamic> users = chatData['users'];
              final otherUserId = users.firstWhere((id) => id != _auth.currentUser!.uid);

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const ListTile(title: Text("Carregando..."));

                  final otherUserData = userSnapshot.data!.data() as Map<String, dynamic>;

                  return ListTile(
                    leading: CircleAvatar(child: Text(otherUserData['email'][0].toUpperCase())),
                    title: Text(otherUserData['email']),
                    subtitle: const Text("Última mensagem..."), // Placeholder
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            chatId: chat.id,
                            otherUserName: otherUserData['email'],
                            otherUserAvatar: "", // Placeholder
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startNewChat,
        child: const Icon(Icons.add),
      ),
    );
  }
}