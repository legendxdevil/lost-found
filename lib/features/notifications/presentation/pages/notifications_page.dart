import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_and_found/features/notifications/presentation/providers/notification_provider.dart';
import 'package:lost_and_found/features/notifications/domain/entities/notification.dart';
import 'package:go_router/go_router.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(myNotificationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: _buildBody(context, notificationsAsync, theme),
    );
  }

  Widget _buildBody(BuildContext context, AsyncValue<List<AppNotification>> notificationsAsync, ThemeData theme) {
    if (notificationsAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (notificationsAsync.hasError) {
      return Center(child: Text('Error: ${notificationsAsync.error}'));
    }
    
    final notifications = notificationsAsync.value ?? [];
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            const Text('No notifications yet', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationTile(notification: notification);
      },
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final AppNotification notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return ListTile(
      onTap: () {
        if (!notification.isRead) {
          ref.read(notificationNotifierProvider.notifier).markAsRead(notification.id);
        }
        if (notification.relatedId != null) {
          if (notification.type == NotificationType.message) {
             context.push('/chat/${notification.relatedId}');
          } else if (notification.type == NotificationType.statusUpdate) {
             context.push('/report-detail/${notification.relatedId}');
          }
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: notification.isRead 
              ? theme.colorScheme.outlineVariant 
              : theme.colorScheme.primary.withValues(alpha: 0.3),
          width: notification.isRead ? 1 : 2,
        ),
      ),
      tileColor: notification.isRead 
          ? Colors.transparent 
          : theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getIconColor(notification.type, theme).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(_getIcon(notification.type), color: _getIconColor(notification.type, theme), size: 20),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        notification.body,
        style: const TextStyle(fontSize: 12),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatTime(notification.timestamp),
        style: TextStyle(fontSize: 10, color: theme.colorScheme.outline),
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.statusUpdate: return Icons.update_rounded;
      case NotificationType.message: return Icons.chat_bubble_outline_rounded;
      case NotificationType.system: return Icons.info_outline_rounded;
    }
  }

  Color _getIconColor(NotificationType type, ThemeData theme) {
    switch (type) {
      case NotificationType.statusUpdate: return Colors.blue;
      case NotificationType.message: return Colors.green;
      case NotificationType.system: return theme.colorScheme.primary;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${dt.day}/${dt.month}";
  }
}
