import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/app_repository.dart';

class SeekerNotificationsPage extends StatelessWidget {
  const SeekerNotificationsPage({super.key});

  String _getNotificationMessage(Map<String, dynamic> notification) {
    final type = notification['type'] ?? '';
    final jobTitle = notification['jobTitle'] ?? 'a job';
    final status = notification['status'] ?? '';

    switch (type) {
      case 'application_accepted':
        return 'Your application for $jobTitle was accepted! 🎉';
      case 'application_denied':
        return 'Your application for $jobTitle was declined';
      case 'job_updated':
        return 'Job "$jobTitle" has been updated';
      case 'job_deleted':
        return 'Job "$jobTitle" has been removed';
      default:
        return 'New notification';
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'application_accepted':
        return Icons.check_circle;
      case 'application_denied':
        return Icons.cancel;
      case 'job_updated':
        return Icons.update;
      case 'job_deleted':
        return Icons.delete;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'application_accepted':
        return const Color(0xFF065f46);
      case 'application_denied':
        return const Color(0xFF991b1b);
      case 'job_updated':
        return const Color(0xFF1a4d8f);
      case 'job_deleted':
        return Colors.grey;
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
      body: Builder(
        builder: (context) {
          final repo = context.watch<AppRepository>();
          final user = repo.currentUser;

          // 🧠 Wait for authentication
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: repo.seekerNotificationsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
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
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
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
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: isRead
                              ? Colors.white
                              : const Color(0xFFe3f2fd),
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
                                      _formatTimestamp(
                                        notification['timestamp'],
                                      ),
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
          );
        },
      ),
    );
  }
}
