import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

enum NotificationType {
  message,
  project_update,
  payment,
  system,
  promotion,
  reminder,
  review,
  milestone,
}

enum NotificationPriority {
  low,
  normal,
  high,
  urgent,
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final NotificationPriority priority;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String? imageUrl;
  final String? actionUrl;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.expiresAt,
    this.data,
    this.isRead = false,
    this.imageUrl,
    this.actionUrl,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    NotificationPriority? priority,
    DateTime? createdAt,
    DateTime? expiresAt,
    Map<String, dynamic>? data,
    bool? isRead,
    String? imageUrl,
    String? actionUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'priority': priority.name,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'data': data,
      'isRead': isRead,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values.firstWhere((e) => e.name == json['type']),
      priority: NotificationPriority.values.firstWhere((e) => e.name == json['priority']),
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
      data: json['data'],
      isRead: json['isRead'] ?? false,
      imageUrl: json['imageUrl'],
      actionUrl: json['actionUrl'],
    );
  }
}

class NotificationSettings {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool inAppEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final Map<NotificationType, bool> typeSettings;
  final Map<NotificationPriority, bool> prioritySettings;
  final String? fcmToken;
  final DateTime? lastSyncAt;

  const NotificationSettings({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.inAppEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.typeSettings = const {},
    this.prioritySettings = const {},
    this.fcmToken,
    this.lastSyncAt,
  });

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? inAppEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    Map<NotificationType, bool>? typeSettings,
    Map<NotificationPriority, bool>? prioritySettings,
    String? fcmToken,
    DateTime? lastSyncAt,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      typeSettings: typeSettings ?? this.typeSettings,
      prioritySettings: prioritySettings ?? this.prioritySettings,
      fcmToken: fcmToken ?? this.fcmToken,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pushEnabled': pushEnabled,
      'emailEnabled': emailEnabled,
      'inAppEnabled': inAppEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'typeSettings': typeSettings.map((k, v) => MapEntry(k.name, v)),
      'prioritySettings': prioritySettings.map((k, v) => MapEntry(k.name, v)),
      'fcmToken': fcmToken,
      'lastSyncAt': lastSyncAt?.toIso8601String(),
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['pushEnabled'] ?? true,
      emailEnabled: json['emailEnabled'] ?? true,
      inAppEnabled: json['inAppEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      typeSettings: (json['typeSettings'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(NotificationType.values.firstWhere((e) => e.name == k), v)),
      prioritySettings: (json['prioritySettings'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(NotificationPriority.values.firstWhere((e) => e.name == k), v)),
      fcmToken: json['fcmToken'],
      lastSyncAt: json['lastSyncAt'] != null ? DateTime.parse(json['lastSyncAt']) : null,
    );
  }
}

class NotificationState {
  final bool isLoading;
  final String? error;
  final List<AppNotification> notifications;
  final NotificationSettings settings;
  final int unreadCount;
  final StreamController<AppNotification> notificationStream;

  const NotificationState({
    this.isLoading = false,
    this.error,
    this.notifications = const [],
    this.settings = const NotificationSettings(),
    this.unreadCount = 0,
    required this.notificationStream,
  });

  NotificationState copyWith({
    bool? isLoading,
    String? error,
    List<AppNotification>? notifications,
    NotificationSettings? settings,
    int? unreadCount,
    StreamController<AppNotification>? notificationStream,
  }) {
    return NotificationState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      notifications: notifications ?? this.notifications,
      settings: settings ?? this.settings,
      unreadCount: unreadCount ?? unreadCount,
      notificationStream: notificationStream ?? this.notificationStream,
    );
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref.read(notificationServiceProvider));
});

class NotificationService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final StreamController<AppNotification> _notificationStream = StreamController<AppNotification>.broadcast();

  Stream<AppNotification> get notificationStream => _notificationStream.stream;

  NotificationService() {
    _initializeLocalNotifications();
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    final payload = response.payload;
    if (payload != null) {
      // Parse payload and navigate accordingly
    }
  }

  // Request notification permissions
  Future<bool> requestPermissions() async {
    final android = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      final result = await android.requestNotificationsPermission();
      return result ?? false;
    }
    
    final ios = _localNotifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    
    if (ios != null) {
      final result = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }
    
    return true;
  }

  // Show local notification
  Future<void> showNotification(AppNotification notification) async {
    if (!await _hasPermissions()) return;

    const androidDetails = AndroidNotificationDetails(
      'appmarket_channel',
      'AppMarket Notifications',
      channelDescription: 'Notifications from AppMarket',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      details,
      payload: notification.actionUrl,
    );

    // Add to stream for in-app handling
    _notificationStream.add(notification);
  }

  Future<bool> _hasPermissions() async {
    final android = _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    
    return true;
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required AppNotification notification,
    required DateTime scheduledTime,
  }) async {
    if (!await _hasPermissions()) return;

    const androidDetails = AndroidNotificationDetails(
      'appmarket_channel',
      'AppMarket Notifications',
      channelDescription: 'Notifications from AppMarket',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      notification.id.hashCode,
      notification.title,
      notification.body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      payload: notification.actionUrl,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Cancel notification
  Future<void> cancelNotification(String notificationId) async {
    await _localNotifications.cancel(notificationId.hashCode);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  // Create notification from type
  AppNotification createNotification({
    required NotificationType type,
    required String title,
    required String body,
    NotificationPriority priority = NotificationPriority.normal,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
    DateTime? expiresAt,
  }) {
    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      priority: priority,
      createdAt: DateTime.now(),
      expiresAt: expiresAt,
      data: data,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
    );
  }

  // Predefined notification templates
  AppNotification createMessageNotification({
    required String senderName,
    required String message,
    String? conversationId,
  }) {
    return createNotification(
      type: NotificationType.message,
      title: 'New message from $senderName',
      body: message,
      priority: NotificationPriority.normal,
      data: {'conversationId': conversationId},
      actionUrl: '/chat/$conversationId',
    );
  }

  AppNotification createProjectUpdateNotification({
    required String projectName,
    required String update,
    String? projectId,
  }) {
    return createNotification(
      type: NotificationType.project_update,
      title: 'Project update: $projectName',
      body: update,
      priority: NotificationPriority.normal,
      data: {'projectId': projectId},
      actionUrl: '/project/$projectId',
    );
  }

  AppNotification createPaymentNotification({
    required String description,
    required double amount,
    String? transactionId,
  }) {
    return createNotification(
      type: NotificationType.payment,
      title: 'Payment received',
      body: '$description - \$${amount.toStringAsFixed(2)}',
      priority: NotificationPriority.high,
      data: {'transactionId': transactionId, 'amount': amount},
      actionUrl: '/wallet',
    );
  }

  AppNotification createReviewNotification({
    required String projectName,
    required String reviewerName,
    double? rating,
  }) {
    return createNotification(
      type: NotificationType.review,
      title: 'New review for $projectName',
      body: '$reviewerName left a ${rating != null ? '$rating star' : ''} review',
      priority: NotificationPriority.normal,
      data: {'projectName': projectName, 'reviewerName': reviewerName},
    );
  }

  AppNotification createMilestoneNotification({
    required String projectName,
    required String milestone,
  }) {
    return createNotification(
      type: NotificationType.milestone,
      title: 'Milestone completed',
      body: '$milestone in $projectName',
      priority: NotificationPriority.high,
      data: {'projectName': projectName, 'milestone': milestone},
    );
  }

  // Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    try {
      final settingsJson = await _storage.read(key: 'notification_settings');
      if (settingsJson != null) {
        // In a real app, you'd properly decode JSON
        return const NotificationSettings(); // Simplified
      }
    } catch (e) {
      // Handle error
    }
    return const NotificationSettings();
  }

  // Save notification settings
  Future<void> saveNotificationSettings(NotificationSettings settings) async {
    try {
      // In a real app, you'd properly encode to JSON
      await _storage.write(
        key: 'notification_settings',
        value: 'notification_settings_json', // Simplified
      );
    } catch (e) {
      // Handle error
    }
  }

  // Update FCM token
  Future<void> updateFCMToken(String token) async {
    try {
      final settings = await getNotificationSettings();
      final updatedSettings = settings.copyWith(fcmToken: token);
      await saveNotificationSettings(updatedSettings);
    } catch (e) {
      // Handle error
    }
  }

  // Get notification statistics
  Future<Map<String, dynamic>> getNotificationStats() async {
    // Mock statistics
    return {
      'totalSent': 1234,
      'totalDelivered': 1156,
      'totalRead': 892,
      'totalClicked': 234,
      'byType': {
        'message': 456,
        'project_update': 234,
        'payment': 123,
        'system': 89,
        'promotion': 67,
        'reminder': 45,
        'review': 134,
        'milestone': 86,
      },
      'byPriority': {
        'low': 234,
        'normal': 567,
        'high': 345,
        'urgent': 88,
      },
    };
  }

  void dispose() {
    _notificationStream.close();
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationService _service;

  NotificationNotifier(this._service) 
      : super(NotificationState(
          notificationStream: _service.notificationStream,
        )) {
    _loadNotifications();
    _loadSettings();
    _listenToNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Mock notifications - in a real app, you'd fetch from API
      final mockNotifications = [
        _service.createMessageNotification(
          senderName: 'John Doe',
          message: 'Hey, are you available for a new project?',
          conversationId: 'conv_123',
        ),
        _service.createProjectUpdateNotification(
          projectName: 'Mobile App Development',
          update: 'Project milestone completed successfully',
          projectId: 'proj_456',
        ),
        _service.createPaymentNotification(
          description: 'Project payment received',
          amount: 500.0,
          transactionId: 'txn_789',
        ),
      ];

      final unreadCount = mockNotifications.where((n) => !n.isRead).length;
      
      state = state.copyWith(
        isLoading: false,
        notifications: mockNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load notifications: $e',
      );
    }
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _service.getNotificationSettings();
      state = state.copyWith(settings: settings);
    } catch (e) {
      // Handle error
    }
  }

  void _listenToNotifications() {
    _service.notificationStream.listen((notification) {
      final updatedNotifications = [notification, ...state.notifications];
      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    });
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return notification.copyWith(isRead: true);
        }
        return notification;
      }).toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to mark as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final updatedNotifications = state.notifications.map((notification) {
        return notification.copyWith(isRead: true);
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to mark all as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;
      
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );

      await _service.cancelNotification(notificationId);
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete notification: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      state = state.copyWith(
        notifications: [],
        unreadCount: 0,
      );

      await _service.cancelAllNotifications();
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear notifications: $e');
    }
  }

  Future<void> updateSettings(NotificationSettings settings) async {
    try {
      await _service.saveNotificationSettings(settings);
      state = state.copyWith(settings: settings);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update settings: $e');
    }
  }

  Future<void> sendNotification(AppNotification notification) async {
    try {
      await _service.showNotification(notification);
    } catch (e) {
      state = state.copyWith(error: 'Failed to send notification: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refresh() async {
    await _loadNotifications();
  }
}

// Time zone helper for scheduled notifications
import 'package:timezone/timezone.dart' as tz;
