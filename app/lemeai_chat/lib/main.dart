// ARQUIVO: lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_wrapper.dart';
import 'chat_detail_screen.dart';
import 'firebase_options.dart';
import 'auth_service.dart';
import 'login_screen.dart';

// Simulação dos dados que viriam da sua API/Firebase
// para facilitar a construção do layout.
final mockContacts = [
  {
    "id": "chat_1", "name": "Lucas Almeida", "initials": "LA",
    "lastMessage": "Olá, como você está hoje?", "time": "5m", "unread": 1
  },
  {
    "id": "chat_2", "name": "Camila Santana", "initials": "CS",
    "lastMessage": "Olá, eu gostaria de um orçamento.", "time": "1h", "unread": 0
  },
  {
    "id": "chat_3", "name": "Bruna Rosa", "initials": "BR",
    "lastMessage": "Olá, tudo bem?", "time": "3h", "unread": 2
  },
];

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
        primaryColor: const Color(0xFF005F73),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Segoe UI',
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
  bool _isSellerOnline = true;
  String _activeFilter = 'all'; // 'all' ou 'unread'

  void _handleLogout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filtra a lista de contatos com base no botão ativo
    final filteredContacts = _activeFilter == 'unread'
        ? mockContacts.where((c) => (c['unread'] as int) > 0).toList()
        : mockContacts;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Remove a appbar padrão
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. CABEÇALHO PERSONALIZADO
          _buildHeader(),
          // 2. ABAS DE FILTRO
          _buildFilterTabs(),
          const Divider(height: 1, color: Color(0xFFF0F2F5)),
          // 3. LISTA DE CONTATOS
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = filteredContacts[index];
                final bool isActive = contact['id'] == 'chat_1';
                return _buildContactTile(contact, isActive);
              },
            ),
          ),
        ],
      ),
      // BOTÃO DE LOGOUT SIMPLES (PODE SER REINTEGRADO A UM MENU DEPOIS)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextButton.icon(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout, color: Colors.grey),
          label: const Text("Sair", style: TextStyle(color: Colors.grey)),
        ),
      ),
    );
  }

  // WIDGET DO CABEÇALHO
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("Inbox", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF343A40))),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F7FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text("2 Novas", style: TextStyle(color: Color(0xFF005F73), fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ],
              ),
              InkWell(
                onTap: () => setState(() => _isSellerOnline = !_isSellerOnline),
                borderRadius: BorderRadius.circular(20),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFF005F73),
                  child: Stack(
                    children: [
                      const Center(child: Text("V", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _isSellerOnline ? Colors.greenAccent[400] : Colors.grey,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: "Buscar conversas",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET DAS ABAS DE FILTRO
  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => _activeFilter = 'all'),
              style: TextButton.styleFrom(
                backgroundColor: _activeFilter == 'all' ? const Color(0xFF005F73) : Colors.white,
                foregroundColor: _activeFilter == 'all' ? Colors.white : const Color(0xFF495057),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFDEE2E6)),
                ),
              ),
              child: const Text("Todas"),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextButton(
              onPressed: () => setState(() => _activeFilter = 'unread'),
              style: TextButton.styleFrom(
                backgroundColor: _activeFilter == 'unread' ? const Color(0xFF005F73) : Colors.white,
                foregroundColor: _activeFilter == 'unread' ? Colors.white : const Color(0xFF495057),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Color(0xFFDEE2E6)),
                ),
              ),
              child: const Text("Não Lidas"),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET DE CADA CONTATO NA LISTA
  Widget _buildContactTile(Map<String, dynamic> contact, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE0F7FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: CircleAvatar(
          radius: 22.5,
          backgroundColor: const Color(0xFFCED4DA),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(child: Text(contact['initials'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF495057)))),
              if (contact['unread'] > 0)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEE9B00),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Center(child: Text(contact['unread'].toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                  ),
                ),
            ],
          ),
        ),
        title: Text(contact['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(contact['lastMessage'], overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        trailing: Text(contact['time'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(chatId: contact['id'], otherUserName: contact['name'], otherUserAvatar: ""),
            ),
          );
        },
      ),
    );
  }
}