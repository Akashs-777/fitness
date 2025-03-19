class ChatListModel {
  final String chatName;
  final String chatSessionId;
  final String createdAt;

  ChatListModel({
    required this.chatName,
    required this.chatSessionId,
    required this.createdAt,
  });

  // Factory method to convert JSON to a Chat object
  factory ChatListModel.fromJson(Map<String, dynamic> json) {
    return ChatListModel(
      chatName: json['chatName'],
      chatSessionId: json['chatSessionId'],
      createdAt: json['createdAt']);
  }
}