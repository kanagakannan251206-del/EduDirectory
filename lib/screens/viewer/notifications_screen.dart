import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final notifications = provider.notifications;

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (provider.unreadNotificationCount > 0)
            TextButton(
              onPressed: provider.markAllNotificationsRead,
              child: const Text('Mark all read', 
                style: TextStyle(color: Colors.white, fontSize: 13)
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          // FIXED: Removed 'const' keyword
          ? EmptyState(
              icon: Icons.notifications_off, 
              title: 'No Notifications', 
              subtitle: 'You\'re all caught up!'
            )
          : ListView.builder(
              itemCount: notifications.length,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemBuilder: (ctx, i) {
                final n = notifications[i];
                return _NotificationTile(
                  notification: n, 
                  onTap: () => provider.markNotificationRead(n.id)
                );
              },
            ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  const _NotificationTile({required this.notification, required this.onTap});

  Color get _typeColor {
    switch (notification.type) {
      case 'alert': return AppTheme.accentCoral;
      case 'warning': return AppTheme.warningAmber;
      case 'update': return AppTheme.accentTeal;
      default: return AppTheme.primaryNavy;
    }
  }

  IconData get _typeIcon {
    switch (notification.type) {
      case 'alert': return Icons.warning_rounded;
      case 'warning': return Icons.info_outline_rounded;
      case 'update': return Icons.update_rounded;
      default: return Icons.notifications_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(12), // Reduced from 14
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : _typeColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12), // Reduced from 14
          border: Border.all(
            color: notification.isRead ? AppTheme.divider : _typeColor.withOpacity(0.2),
          ),
          boxShadow: notification.isRead ? null : [
            BoxShadow(
              color: _typeColor.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8), // Reduced from 10
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_typeIcon, color: _typeColor, size: 18), // Reduced from 20
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title, 
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13, // Slightly smaller
                          )
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(color: _typeColor, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notification.message, 
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
                    maxLines: 2, 
                    overflow: TextOverflow.ellipsis
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(notification.createdAt),
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
