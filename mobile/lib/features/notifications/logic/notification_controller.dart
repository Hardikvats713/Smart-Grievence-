import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationController extends ChangeNotifier {
  NotificationController() {
    _initSampleNotifications();
  }

  static final NotificationController instance = NotificationController();

  final List<AppNotificationItem> _notifications = [];

  List<AppNotificationItem> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void _initSampleNotifications() {
    if (_notifications.isNotEmpty) return;

    _notifications.addAll([
      const AppNotificationItem(
        id: 'n-1',
        type: NotificationType.statusUpdated,
        title: 'Status Updated: SG2503180001',
        description: 'Your grievance "Pothole on main road" is now In Progress.',
        timeAgo: '10m ago',
        grievanceId: 'g-1',
        isRead: false,
        dateGroup: 'Today',
      ),
      const AppNotificationItem(
        id: 'n-2',
        type: NotificationType.grievanceAssigned,
        title: 'Officer Assigned',
        description: 'Officer Ramesh Kumar has been assigned to your grievance.',
        timeAgo: '2h ago',
        grievanceId: 'g-1',
        isRead: false,
        dateGroup: 'Today',
      ),
      const AppNotificationItem(
        id: 'n-3',
        type: NotificationType.grievanceResolved,
        title: 'Grievance Resolved: SG2503170005',
        description: '"Streetlight not working" has been marked as resolved.',
        timeAgo: 'Yesterday',
        grievanceId: 'g-2',
        isRead: true,
        dateGroup: 'Yesterday',
      ),
      const AppNotificationItem(
        id: 'n-4',
        type: NotificationType.submissionConfirmed,
        title: 'Grievance Registered',
        description: 'Grievance SG2503150009 has been successfully submitted.',
        timeAgo: '2 days ago',
        grievanceId: 'g-3',
        isRead: true,
        dateGroup: 'Earlier',
      ),
    ]);
  }

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifications[idx].isRead) {
      _notifications[idx] = _notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }
}
