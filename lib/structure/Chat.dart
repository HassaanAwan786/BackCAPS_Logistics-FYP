class Chat {
  late String chatId;
  late String text;
  late String email;
  late bool isMe;
  late int timestamp;

  Chat({
    required this.text,
    required this.email,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    text: json['text'] ?? 'NULL',
    email: json['email'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'text': text,
    'email': email,
  };
}
