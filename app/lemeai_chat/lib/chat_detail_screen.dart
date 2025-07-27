// ARQUIVO: lib/chat_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'models/chat_models.dart';
import 'details_panel_screen.dart';

class ChatDetailScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String otherUserAvatar;

  const ChatDetailScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
    required this.otherUserAvatar,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _emojiShowing = false;

  final List<Message> _messages = [
    Message(id: '1', text: 'Olá, como você está hoje? 😄', time: '15:30', isSentByMe: false),
    Message(id: '2', text: 'Olá, Lucas! Estou bem e você?', time: '15:31', isSentByMe: true),
    Message(id: '3', text: 'Estou ótimo 👍', time: '09:15', isSentByMe: false),
    Message(id: '4', text: 'Que bom! Podemos agendar uma demonstração do produto para amanhã?', time: '09:16', isSentByMe: true),
  ];
  
  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: _messageController.text.trim(),
      time: DateFormat('HH:mm').format(DateTime.now()),
      isSentByMe: true,
    );

    setState(() {
      _messages.add(message);
      _messageController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
          ),
          child: Wrap(
            children: <Widget>[
              _buildMenuOption(Icons.photo_library, 'Fotos e Vídeos', () {}),
              _buildMenuOption(Icons.camera_alt, 'Câmera', () {}),
              _buildMenuOption(Icons.insert_drive_file, 'Documento', () {}),
              const Divider(height: 1, color: Colors.grey),
              _buildMenuOption(Icons.mic, 'Áudio', () {}),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              children: [
                _DateDivider(date: 'Ontem'),
                _MessageBubble(message: _messages[0]),
                _MessageBubble(message: _messages[1]),
                _DateDivider(date: 'Hoje'),
                _MessageBubble(message: _messages[2]),
                _MessageBubble(message: _messages[3]),
                ..._messages.where((m) => int.tryParse(m.id) != null && int.parse(m.id) > 4).map((m) => _MessageBubble(message: m)),
              ],
            ),
          ),
          _buildMessageInput(),
          Offstage(
            offstage: !_emojiShowing,
            child: SizedBox(
              height: 250,
              child: EmojiPicker(
                textEditingController: _messageController,
                config: const Config(
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(
                    columns: 7,
                    backgroundColor: Color(0xFFF2F2F2),
                    noRecents: Text(
                      'Sem recentes',
                      style: TextStyle(fontSize: 20, color: Colors.black26),
                      textAlign: TextAlign.center,
                    ),
                    recentsLimit: 28,
                  ),
                  swapCategoryAndBottomBar: false,
                  skinToneConfig: SkinToneConfig(),
                  categoryViewConfig: CategoryViewConfig(
                    indicatorColor: Color(0xFF005F73),
                    iconColorSelected: Color(0xFF005F73),
                    backgroundColor: Color(0xFFF2F2F2),
                  ),
                  bottomActionBarConfig: BottomActionBarConfig(),
                  searchViewConfig: SearchViewConfig(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      shadowColor: Colors.grey.withAlpha(25),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              widget.otherUserName.substring(0, 1),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.otherUserName,
            style: const TextStyle(color: Color(0xFF343A40), fontWeight: FontWeight.w600, fontSize: 17),
          ),
        ],
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'profile') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DetailsPanelScreen(
                    contact: ContactDetails(
                      name: widget.otherUserName,
                      initials: widget.otherUserName.substring(0, 1),
                      phone: '(11) 98765-4321',
                    ),
                  ),
                  fullscreenDialog: true,
                ),
              );
            }
          },
          icon: const Icon(Icons.more_vert, color: Colors.black54),
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'profile',
              child: Text('Ver Perfil do Contato'),
            ),
            const PopupMenuItem<String>(
              value: 'clear',
              child: Text('Limpar Histórico'),
            ),
            const PopupMenuItem<String>(
              value: 'block',
              child: Text('Bloquear Contato'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        border: Border(top: BorderSide(color: Color(0xFFF0F2F5))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.emoji_emotions_outlined, color: Colors.grey[600]),
            onPressed: () {
              setState(() {
                _emojiShowing = !_emojiShowing;
                if (_emojiShowing) FocusScope.of(context).unfocus();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.black54),
            onPressed: _showAttachmentMenu,
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDEE2E6)),
              ),
              child: TextField(
                controller: _messageController,
                onTap: () {
                  if (_emojiShowing) setState(() => _emojiShowing = false);
                },
                decoration: const InputDecoration(
                  hintText: "Digite sua mensagem...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _sendMessage,
            mini: true,
            backgroundColor: Theme.of(context).primaryColor,
            elevation: 1,
            child: const Icon(Icons.send, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isSentByMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isMe ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(18),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Text(
                message.text,
                style: TextStyle(color: isMe ? Colors.white : Colors.black87),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Text(
                message.time,
                style: TextStyle(
                  fontSize: 11,
                  color: isMe ? Colors.white.withAlpha(178) : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateDivider extends StatelessWidget {
  final String date;
  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFE9ECEF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          date,
          style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}