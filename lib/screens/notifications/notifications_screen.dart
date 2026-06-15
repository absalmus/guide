import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stitch_smart_church_guide/core/constants/app_colors.dart';
import 'package:stitch_smart_church_guide/models/app_notification.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [];
  }

  void _markAllRead() {
    setState(() {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final unread = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('قراءة الكل'),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text('لا توجد إشعارات'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final n = _notifications[i];
                return Dismissible(
                  key: ValueKey(n.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) {
                    setState(() => _notifications.removeAt(i));
                  },
                  background: Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    color: AppColors.closedRed,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    color: n.isRead
                        ? null
                        : Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.05),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.copticGold.withValues(
                          alpha: 0.15,
                        ),
                        child: Icon(n.type.icon, color: AppColors.copticGold),
                      ),
                      title: Text(
                        n.title,
                        style: TextStyle(
                          fontWeight: n.isRead
                              ? FontWeight.normal
                              : FontWeight.w700,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(n.body),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM hh:mm a', 'ar').format(n.time),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      isThreeLine: true,
                      onTap: () {
                        setState(() {
                          _notifications[i] = n.copyWith(isRead: true);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
