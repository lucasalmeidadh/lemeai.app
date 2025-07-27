class Message {
  final String id;
  final String text;
  final String time;
  final bool isSentByMe;

  Message({
    required this.id,
    required this.text,
    required this.time,
    required this.isSentByMe,
  });
}