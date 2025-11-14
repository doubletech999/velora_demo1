import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_localizations.dart';
import '../../providers/notifications_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Listen to new notifications from FCM
    _setupFCMListener();
  }

  void _setupFCMListener() {
    // This will be handled by FCMService, but we can also listen here
    // The FCMService already handles notifications and can add them to the provider
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.ofOrThrow(context);
    final notificationsProvider = context.watch<NotificationsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.get('notifications') ?? 'الإشعارات'),
        actions: [
          if (notificationsProvider.unreadCount > 0)
            IconButton(
              icon: const Icon(PhosphorIcons.check_circle),
              tooltip: 'تحديد الكل كمقروء',
              onPressed: () {
                notificationsProvider.markAllAsRead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم تحديد جميع الإشعارات كمقروءة')),
                );
              },
            ),
          IconButton(
            icon: const Icon(PhosphorIcons.trash),
            tooltip: 'حذف الكل',
            onPressed: () {
              _showClearAllDialog(context, notificationsProvider);
            },
          ),
        ],
      ),
      body: notificationsProvider.notifications.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () async {
                // Refresh notifications if needed
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notificationsProvider.notifications.length,
                itemBuilder: (context, index) {
                  final notification = notificationsProvider.notifications[index];
                  return _NotificationCard(
                    notification: notification,
                    onTap: () => _handleNotificationTap(context, notification),
                    onDelete: () => notificationsProvider.deleteNotification(notification.id),
                    onMarkAsRead: () => notificationsProvider.markAsRead(notification.id),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.bell_slash,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ستظهر الإشعارات هنا عند وصولها',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    // Mark as read
    context.read<NotificationsProvider>().markAsRead(notification.id);

    // Handle navigation based on notification type
    if (notification.data != null) {
      final type = notification.data!['type'] as String?;
      
      if (type == 'new_route_camping') {
        final siteId = notification.data!['site_id'] as String?;
        if (siteId != null) {
          context.push('/paths/$siteId');
        }
      } else if (type == 'trip_accepted') {
        final tripId = notification.data!['trip_id'] as String?;
        if (tripId != null) {
          // Navigate to trip details when route is available
          // For now, navigate to home
          context.go('/');
        }
      }
    }
  }

  void _showClearAllDialog(BuildContext context, NotificationsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف جميع الإشعارات'),
        content: const Text('هل أنت متأكد من حذف جميع الإشعارات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف جميع الإشعارات')),
              );
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onMarkAsRead;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeAgo = _getTimeAgo(notification.timestamp);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 0 : 2,
      color: notification.isRead ? Colors.grey[50] : Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: notification.isRead
                      ? AppColors.primary.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(notification.data?['type']),
                  color: notification.isRead
                      ? AppColors.primary.withOpacity(0.6)
                      : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton(
                icon: const Icon(PhosphorIcons.dots_three_vertical),
                itemBuilder: (context) => [
                  if (!notification.isRead)
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(PhosphorIcons.check, size: 20),
                          SizedBox(width: 8),
                          Text('تحديد كمقروء'),
                        ],
                      ),
                      onTap: () => Future.delayed(
                        const Duration(milliseconds: 100),
                        onMarkAsRead,
                      ),
                    ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(PhosphorIcons.trash, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('حذف', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    onTap: () => Future.delayed(
                      const Duration(milliseconds: 100),
                      onDelete,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'new_route_camping':
        return PhosphorIcons.map_trifold;
      case 'trip_accepted':
        return PhosphorIcons.check_circle;
      default:
        return PhosphorIcons.bell;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return DateFormat('yyyy/MM/dd').format(timestamp);
    } else if (difference.inDays > 0) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else {
      return 'الآن';
    }
  }
}

