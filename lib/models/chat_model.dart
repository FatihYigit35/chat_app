import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String text;
  final String userId;
  final String userName;
  final String userImage;
  final Timestamp createdAt;

  ChatModel({
    required this.text,
    required this.userId,
    required this.userName,
    required this.userImage,
    createdAt,
  }) : createdAt = Timestamp.now();

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'createdAt': createdAt,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
        text: map['text'] ?? '',
        userId: map['userId'] ?? '',
        userName: map['userName'] ?? '',
        userImage: map['userImage'] ?? '',
        createdAt: map['createdAt'] ?? Timestamp.fromMillisecondsSinceEpoch(0));
  }
}
