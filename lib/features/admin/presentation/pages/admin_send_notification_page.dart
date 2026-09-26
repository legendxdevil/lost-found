import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_and_found/features/notifications/data/models/notification_dto.dart';
import 'package:lost_and_found/features/notifications/presentation/providers/notification_provider.dart';

class AdminSendNotificationPage extends ConsumerStatefulWidget {
  final String userId;

  const AdminSendNotificationPage({super.key, required this.userId});

  @override
  ConsumerState<AdminSendNotificationPage> createState() => _AdminSendNotificationPageState();
}

class _AdminSendNotificationPageState extends ConsumerState<AdminSendNotificationPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _send() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    
    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final notification = NotificationDTO(
      id: '',
      userId: widget.userId,
      title: title,
      body: body,
      timestamp: DateTime.now(),
      isRead: false,
      type: 'custom',
      relatedId: null,
    );

    try {
      await ref.read(notificationDatasourceProvider).sendNotification(notification);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification sent successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send notification: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notification'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Message Title',
                hintText: 'e.g. Item Found Updates',
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Message Body',
                hintText: 'Describe the update...',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _send,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Send Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
