import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy(
            'createdAt',
            descending: true,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No message found.'),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }

        final chatMessages = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 30, right: 10, left: 10),
          reverse: true,
          itemCount: chatMessages.length,
          itemBuilder: (context, index) {
            final chatMessage = chatMessages[index].data();
            final chatModel = ChatModel.fromMap(chatMessage);
            final nextChatMessage = index + 1 < chatMessages.length
                ? chatMessages[index + 1].data()
                : null;
            final nextChatModel = nextChatMessage != null
                ? ChatModel.fromMap(nextChatMessage)
                : null;

            final currentMessageUserId = chatModel.userId;
            final nextMessageUserId = nextChatModel?.userId;

            final nextUserIsSame = currentMessageUserId == nextMessageUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatModel.text,
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                userImage: chatModel.userImage,
                username: chatModel.userName,
                message: chatModel.text,
                isMe: authenticatedUser.uid == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
