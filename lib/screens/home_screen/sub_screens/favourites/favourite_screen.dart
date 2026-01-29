import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/home_screen/home_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/product_display_screen/WishlistController.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/product_display_screen/product_display_screen.dart';
import 'package:organic_saga/shared_pref/shared_pref.dart';
import 'package:shimmer/shimmer.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  final WishlistController wishlistController = Get.put(WishlistController());
  final RxList<dynamic> favData = <dynamic>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final homeController = Get.find<HomeController>();
      if ((homeController.userModel.value.id ?? '').isEmpty) {
        await homeController.fetchUser();
      }
      await loadWishlist();
    } catch (_) {
      errorMessage.value = 'Failed to load favorites. Please try again.';
      isLoading.value = false;
    }
  }

  Future<void> loadWishlist() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final userId = await SharedPref.getUserId();
      if (userId == null) {
        errorMessage.value = 'Please login to view favorites';
        favData.clear();
        wishlistController.wishlistCount.value = 0; // keep synced
        return;
      }

      // ✅ Call controller method so count updates
      await wishlistController.getWishlist(userId);

      // ✅ Assign controller’s list locally too
      favData.value = wishlistController.favList;
    } catch (e) {
      errorMessage.value = 'Network error: ${e.toString()}';
      favData.clear();
      wishlistController.wishlistCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteWishListProduct(String wishlistId) async {
    try {
      final userId = await SharedPref.getUserId();
      if (userId == null) return;

      final response = await http.post(
        Uri.parse('$baseUrl/Auth/remove_wishlist'),
        body: {'wishlist_id': wishlistId, 'uid': userId},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 204) {
        // ✅ Remove item locally
        favData.removeWhere((item) => item['wid'].toString() == wishlistId);

        // ✅ Refresh from server to stay in sync
        await wishlistController.getWishlist(userId);

        // ✅ User feedback
        if (Get.context != null) {
          ScaffoldMessenger.of(Get.context!).showSnackBar(
            const SnackBar(content: Text("Removed from favorites")),
          );
        }

        print("✅ Wishlist item $wishlistId removed successfully");
      } else {
        print('❌ Failed to remove wishlist: ${response.statusCode}');
      }
    } on TimeoutException {
      print("⏳ Request timed out while removing wishlist item");
    } catch (e) {
      print('❌ Error removing wishlist: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: ThemedAppBar(
          title: 'Favorites',
          onCartTap: () {
            Get.to(() => FavouriteScreen());
          },
        ),
        body: Obx(() {
          if (isLoading.value) {
            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: 6,
              itemBuilder: (context, index) {
                return FavouriteItemShimmer(screenWidth: screenWidth);
              },
            );
          }

          // Remove errorMessage check entirely

          if (favData.isEmpty) {
            // <-- Paste your pulsing heart code here
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.9, end: 1.1),
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) {
                      return Transform.scale(
                        scale: scale,
                        child: child,
                      );
                    },
                    onEnd: () {
                      setState(() {});
                    },
                    child: Icon(
                      Icons.favorite,
                      size: 80.sp,
                      color: Colors.redAccent,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'Your favorites are empty!',
                    style: TextStyle(fontSize: 20.sp, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Tap the heart on a product to add it here',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  SizedBox(height: 20.h),
                  // ElevatedButton.icon(
                  //   onPressed: () {
                  //     Get.to(() => SubHomeScreen());
                  //   },
                  //   icon: const Icon(Icons.shopping_bag),
                  //   label: const Text('Explore Products'),
                  //   style: ElevatedButton.styleFrom(
                  //     padding: const EdgeInsets.symmetric(
                  //         horizontal: 20, vertical: 12),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(30),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          }

          // Otherwise, show the favorites list
          return RefreshIndicator(
            onRefresh: loadWishlist,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: favData.length,
              itemBuilder: (context, index) {
                final item = favData[index];
                return FavouriteItem(
                  screenWidth: screenWidth,
                  productId: item['product_id']?.toString() ?? '',
                  imageUrl: item['image']?.toString() ?? '',
                  productName: item['name']?.toString() ?? 'Unknown Product',
                  cost: item['special_price']?.toString() ?? '0',
                  wishlistId: item['wid']?.toString() ?? '',
                  onDelete: () =>
                      deleteWishListProduct(item['wid']?.toString() ?? ''),
                  onTap: () => _navigateToProduct(item),
                );
              },
            ),
          );
        }));
  }

  Future<void> _navigateToProduct(Map<String, dynamic> item) async {
    final productId = item['product_id']?.toString();
    if (productId == null || productId.isEmpty) return;

    await Get.to(() => ProductDisplayScreen(id: productId));
    await loadWishlist();
  }
}

class FavouriteItem extends StatelessWidget {
  final double screenWidth;
  final String productId, imageUrl, productName, cost, wishlistId;
  final VoidCallback onDelete, onTap;

  const FavouriteItem({
    super.key,
    required this.screenWidth,
    required this.productId,
    required this.imageUrl,
    required this.productName,
    required this.cost,
    required this.wishlistId,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    "$baseProductImageUrl$imageUrl",
                    height: screenWidth / 5,
                    width: screenWidth / 5,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: screenWidth / 5,
                        width: screenWidth / 5,
                        color: Colors.grey[300],
                      );
                    },
                    errorBuilder: (_, __, ___) => Container(
                      height: screenWidth / 5,
                      width: screenWidth / 5,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: screenWidth / 30),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        "$indianRupeeSymbol $cost",
                        style: TextStyle(
                          fontSize: screenWidth / 35,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FavouriteItemShimmer extends StatelessWidget {
  final double screenWidth;
  const FavouriteItemShimmer({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: screenWidth / 5,
                  width: screenWidth / 5,
                  color: Colors.grey[300],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 16.h,
                        width: double.infinity,
                        color: Colors.grey[300],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 14.h,
                        width: screenWidth / 4,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Icon(Icons.favorite, color: Colors.grey[300]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
