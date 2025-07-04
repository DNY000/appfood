import 'package:flutter/foundation.dart';
import 'package:foodapp/data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _countNotification = 0;
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get countNotification => _countNotification;
  int _countOrder = 0;
  int get countOrder => _countOrder;
  Future<void> loadNotifications(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _repository.getNotifications(id);
    } catch (e) {
      _error = 'Failed to load notifications';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index].isRead = true;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      // Update local state
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  Future<void> createNotification(NotificationModel notification) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      await _repository.createNotification(notification);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to create notification';
      notifyListeners();
    }
  }

  Future<void> getUnreadNotificationsCount(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _countNotification =
          await _repository.getUnreadNotificationsCount(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed notification';
      notifyListeners();
    }
  }
}
