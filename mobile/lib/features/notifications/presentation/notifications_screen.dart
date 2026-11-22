import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../grievances/widgets/grievance_header.dart';
import '../logic/notification_controller.dart';
import '../models/notification_model.dart';

/// Screen 17 — Notifications.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
    this.controller,
  });

  final NotificationController? controller;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late final NotificationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? NotificationController.instance;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final notifications = _controller.notifications;

        // Group notifications by date group
        final Map<String, List<AppNotificationItem>> grouped = {};
        for (final item in notifications) {
          grouped.putIfAbsent(item.dateGroup, () => []).add(item);
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      GrievanceHeader(
                        title: 'Notifications',
                        onBack: () => Navigator.of(context).maybePop(),
                        action: _controller.unreadCount > 0
                            ? TextButton(
                                onPressed: () => _controller.markAllAsRead(),
                                child: const Text(
                                  'Mark all read',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Expanded(
                  child: notifications.isEmpty
                      ? const Center(
                          child: Text(
                            'No notifications yet',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: grouped.keys.length,
                          itemBuilder: (context, groupIndex) {
                            final groupName = grouped.keys.elementAt(groupIndex);
                            final items = grouped[groupName]!;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    groupName,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                                ...items.map((item) => _NotificationTile(
                                      item: item,
                                      onTap: () {
                                        _controller.markAsRead(item.id);
                                        Navigator.of(context).pushNamed(
                                          '/grievance-details',
                                          arguments: item.grievanceId,
                                        );
                                      },
                                    )),
                                const SizedBox(height: 6),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.item,
    required this.onTap,
  });

  final AppNotificationItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isRead ? AppColors.border : AppColors.accent.withValues(alpha: 0.35),
          width: item.isRead ? 1 : 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.isRead
                        ? AppColors.secondarySurface
                        : const Color(0xFFFDEEE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.type.icon,
                    size: 18,
                    color: item.isRead ? AppColors.primary : AppColors.accent,
                  ),
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
                              item.title,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w600,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                          Text(
                            item.timeAgo,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.description,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5,
                          color: AppColors.secondaryText,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!item.isRead)
                  Container(
                    margin: const EdgeInsets.only(left: 6, top: 4),
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
