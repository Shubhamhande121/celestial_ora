import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;
  final RxInt notificationCount = 0.obs;
  final RxSet<String> viewedIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadViewedIds().then((_) {
      fetchNotificationData();
    });
  }

  Future<void> _loadViewedIds() async {
    final prefs = await SharedPreferences.getInstance();
    viewedIds.addAll(prefs.getStringList('viewedNotifications') ?? []);
    print("🔹 Loaded viewed IDs: $viewedIds");
  }

  Future<void> _saveViewedIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('viewedNotifications', viewedIds.toList());
    print("🔹 Saved viewed IDs: $viewedIds");
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? "1";
  }

  /// Fetch notifications and calculate unread count
  Future<void> fetchNotificationData() async {
    isLoading.value = true;
    try {
      final userId = await _getUserId();
      final response = await http.post(
        Uri.parse(notificationListApi),
        body: {'user_id': userId},
      );

      print("📡 Notification API status: ${response.statusCode}");
      print("📄 Notification API body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> fetchedNotifications = data['count'] ?? [];

        notifications.value = fetchedNotifications
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        // Calculate unread count based on status and viewedIds
        _calculateUnreadCount();
        
        print("✅ Loaded ${notifications.length} notifications");
        print("📊 Unread count: ${notificationCount.value}");
      } else {
        notifications.value = [];
        notificationCount.value = 0;
        print("❌ Failed to load notifications: ${response.statusCode}");
      }
    } catch (e) {
      notifications.value = [];
      notificationCount.value = 0;
      print("❌ Exception fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Calculate unread count from notifications
  void _calculateUnreadCount() {
    int unreadCount = 0;
    
    for (final notification in notifications) {
      final id = notification['id']?.toString() ?? '';
      final status = notification['status']?.toString() ?? '0';
      
      // Count as unread if:
      // 1. status is "0" (unread) AND
      // 2. not in viewedIds (locally marked as read)
      if (status == "0" && !viewedIds.contains(id)) {
        unreadCount++;
      }
    }
    
    notificationCount.value = unreadCount;
  }

  /// Mark as viewed - UPDATED FOR IMMEDIATE UI UPDATE
  Future<void> markAsViewed(String id) async {
    // Add to viewed set
    viewedIds.add(id);
    
    // Force UI update by refreshing the notifications list
    notifications.refresh();
    
    // Also update the notification status in the list for immediate visual feedback
    final index = notifications.indexWhere((n) => n['id']?.toString() == id);
    if (index != -1) {
      // Create a new map to ensure reactivity
      final updatedNotification = Map<String, dynamic>.from(notifications[index]);
      updatedNotification['status'] = '1';
      notifications[index] = updatedNotification;
    }

    // Save locally
    _saveViewedIds();

    try {
      final userId = await _getUserId();
      await http.post(
        Uri.parse(notificationStatusChangeApi),
        body: {'user_id': userId, 'nid': id},
      );
      print("✅ Marked notification $id as viewed on server");
    } catch (e) {
      print("❌ Exception updating notification status: $e");
    }

    // Recalculate unread count
    _calculateUnreadCount();
    
    // Force another refresh to ensure UI updates
    notifications.refresh();
    update(); // This triggers GetX to rebuild observers
  }

  /// Optional: Keep this if you still want to use the count API
  /// but use it only as a fallback
  Future<void> fetchNotificationCount() async {
    try {
      final userId = await _getUserId();
      final response = await http.post(
        Uri.parse(notificationCountApi),
        body: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Use this only if you can't calculate from notifications
        notificationCount.value = data['count'] ?? 0;
      }
    } catch (e) {
      print("❌ Exception fetching notification count: $e");
      // If count API fails, calculate from local data
      _calculateUnreadCount();
    }
  }

  void clearNotificationCount() => notificationCount.value = 0;
}