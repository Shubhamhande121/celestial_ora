import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/notifications/notification_controller.dart';
import 'package:shimmer/shimmer.dart';

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final NotificationController controller = Get.put(NotificationController());

  // Format date without time
  String formatDate(String rawDate) {
    try {
      final dateTime = DateTime.parse(rawDate);
      return DateFormat("MMM d, yyyy").format(dateTime);
    } catch (_) {
      return rawDate;
    }
  }

  // Build notification image with fallback
  Widget _buildNotificationImage(String? imgName) {
    if (imgName == null || imgName.isEmpty) {
      return _imageFallback();
    }

    final url = baseNotificationImageUrl + imgName;

    return Image.network(
      url,
      width: 80.w,
      height: 80.h,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => _imageFallback(),
    );
  }

  // Fallback widget
  Widget _imageFallback() {
    return Container(
      width: 80.w,
      height: 80.h,
      color: Colors.orange.shade100,
      child: Icon(Icons.image_not_supported, size: 30.sp),
    );
  }

  // Sort notifications by date (newest first)
  List<Map<String, dynamic>> _getSortedNotifications(
      List<Map<String, dynamic>> notifications) {
    notifications.sort((a, b) {
      final dateA = DateTime.tryParse(a['created'] ?? '');
      final dateB = DateTime.tryParse(b['created'] ?? '');

      if (dateA == null || dateB == null) return 0;

      // Sort in descending order (newest first)
      return dateB.compareTo(dateA);
    });

    return notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThemedAppBar(
        title: 'Notifications',
        showBack: true,
      ),
      body: SafeArea(
        maintainBottomViewPadding: true,
        child: Obx(() {
          if (controller.isLoading.value) return _buildShimmerList();

          final notifications = controller.notifications;
          if (notifications.isEmpty) return _buildEmptyState(context);

          // Get sorted notifications (newest first)
          final sortedNotifications =
              _getSortedNotifications(notifications.toList());

          return RefreshIndicator(
            onRefresh: () async {
              await controller.fetchNotificationData();
            },
            child: ListView.builder(
              padding: EdgeInsets.all(12.w),
              itemCount: sortedNotifications.length,
              itemBuilder: (context, index) {
                final item = sortedNotifications[index];
                final id = item['id']?.toString() ?? '';
                final msg = item['msg']?.trim() ?? 'No message';
                final date = formatDate(item['created'] ?? '');
                final imgName = item['image'];
                final isRead = controller.viewedIds.contains(id);

                return GestureDetector(
                  onTap: () {
                    controller.markAsViewed(id);
                    _showNotificationPopup(context, msg, date, imgName);
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isRead ? 1 : 3,
                    color: isRead ? Colors.grey.shade50 : Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildNotificationImage(imgName),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: isRead
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                    color: isRead
                                        ? Colors.grey.shade700
                                        : Colors.black,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  date,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: isRead
                                        ? Colors.grey.shade500
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }

  // Shimmer loading UI
  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.all(12.w),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.white,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80.w,
                    height: 80.h,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 16.h,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: 120.w,
                          height: 12.h,
                          color: Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Empty state UI
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off, size: 50.sp, color: Colors.grey),
            SizedBox(height: 16.h),
            Text(
              "You're up to date!",
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              "No new notifications available.",
              style: TextStyle(fontSize: 13.sp, color: Colors.grey),
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon:
                  const Icon(Icons.shopping_bag_outlined, color: Colors.white),
              label: const Text(
                "Continue Shopping",
                style: TextStyle(color: Colors.white),  
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF597E22),  
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                textStyle: TextStyle(fontSize: 14.sp),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationPopup(
      BuildContext context, String msg, String date, String? imgName) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Removed the top-right close icon
                if (imgName != null && imgName.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      baseNotificationImageUrl + imgName,
                      height: 150.h,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 150.h,
                        color: Colors.orange.shade100,
                        child: Icon(Icons.image_not_supported, size: 40.sp),
                      ),
                    ),
                  ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    msg,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Close'),
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
