import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/app_repository.dart';

class PosterNotificationsPage extends StatelessWidget {
  const PosterNotificationsPage({super.key});

  String _getNotificationMessage(Map<String, dynamic> notification) {
    final type = notification['type'] ?? '';
    final applicantName = notification['applicantName'] ?? 'Someone';
    final jobTitle = notification['jobTitle'] ?? 'your job';

    switch (type) {
      case 'new_application':
        return '$applicantName applied for $jobTitle';
      case 'application_withdrawn':
        return '$applicantName withdrew their application for $jobTitle';
      default:
        return 'New notification';
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'new_application':
        return Icons.person_add;
      case 'application_withdrawn':
        return Icons.person_remove;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'new_application':
        return const Color(0xFF1a4d8f);
      case 'application_withdrawn':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';

    try {
      final now = DateTime.now();
      final notificationTime = timestamp is DateTime
          ? timestamp
          : DateTime.parse(timestamp.toString());

      final difference = now.difference(notificationTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${notificationTime.day}/${notificationTime.month}/${notificationTime.year}';
      }
    } catch (e) {
      return '';
    }
  }

  void _showDeleteConfirmation(
    BuildContext context,
    AppRepository repo,
    String notificationId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Notification'),
          content: const Text(
            'Are you sure you want to delete this notification?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                repo.deleteNotification(notificationId);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<AppRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(fontSize: 20)),
        actions: [
          TextButton.icon(
            onPressed: () {
              repo.markAllNotificationsAsRead();
            },
            icon: const Icon(Icons.done_all, size: 16),
            label: const Text('Mark all read', style: TextStyle(fontSize: 16)),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1a4d8f),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: repo.posterNotificationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final isRead = notification['isRead'] ?? false;
              final type = notification['type'] ?? '';

              return Dismissible(
                key: Key(notification['id'] ?? index.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  repo.deleteNotification(notification['id'] ?? '');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification deleted')),
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    if (!isRead) {
                      repo.markNotificationAsRead(notification['id'] ?? '');
                    }
                    // Navigate to My Jobs page or specific job
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.white : const Color(0xFFe3f2fd),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isRead
                            ? Colors.grey.shade200
                            : const Color(0xFF1a4d8f).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _getNotificationColor(
                                type,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getNotificationIcon(type),
                              color: _getNotificationColor(type),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getNotificationMessage(notification),
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isRead
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                    color: Colors.grey.shade900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatTimestamp(notification['timestamp']),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF1a4d8f),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
