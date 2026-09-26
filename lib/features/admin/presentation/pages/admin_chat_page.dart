import 'package:flutter/material.dart';
import 'package:lost_and_found/features/chat/presentation/pages/chat_page.dart';

class AdminChatPage extends StatelessWidget {
  final String chatId; // reportId

  const AdminChatPage({super.key, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Chat View'),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      body: ChatPage(reportId: chatId),
    );
  }
}
