import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/components/section_header.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/home_screen/home_controller.dart';
import 'package:organic_saga/screens/home_screen/search_screens/search_screen.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/notifications/notification_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/notifications/notifications.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/cart_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/sub_screens/order_summary.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/product_display_screen/product_display_screen.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/product_list_screen/product_list_screen.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/sub_home_screen/best_seller_screen.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marquee/marquee.dart';

class OptimizedSubHomeScreen extends StatefulWidget {
  const OptimizedSubHomeScreen({Key? key}) : super(key: key);

  @override
  State<OptimizedSubHomeScreen> createState() => _OptimizedSubHomeScreenState();
}

class _OptimizedSubHomeScreenState extends State<OptimizedSubHomeScreen> {
  late Timer _searchTextTimer;
  int _currentSearchIndex = 0;
  final List<String> _searchPlaceholders = [
    "Search For Products",
    "Search For Categories",
  ];

  // ✅ FIX: Safe controller access
  final HomeController homeController = Get.find<HomeController>();
  final CartController cartController = Get.find<CartController>();
  final NotificationController notificationController =
      Get.find<NotificationController>();

  // ✅ FIX: Remove heavy state variables
  var isLoadingBest = false.obs;
  var isLoadingTrending = false.obs;
  var _exclusiveData = <dynamic>[].obs;
  var _bestSellingData = <dynamic>[].obs;

  @override
  void initState() {
    super.initState();
    _startSearchTextTimer();
    _loadInitialData();

    ever(cartController.cartItemCount, (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _searchTextTimer.cancel();
    super.dispose();
  }

  void _startSearchTextTimer() {
    _searchTextTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentSearchIndex =
              (_currentSearchIndex + 1) % _searchPlaceholders.length;
        });
      }
    });
  }

  Future<void> _loadInitialData() async {
    await homeController.getBannerApi();
    await getTrendingProducts();
    await getBestSeller();
    await cartController.getCart();
  }

  Future<void> getBestSeller() async {
    try {
      isLoadingBest.value = true;
      final response =
          await http.get(Uri.parse('$baseUrl/Auth/best_seller_product'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final temp = data["bestseller_list"] as List;
        // ✅ FIX: Limit to 10 items for performance
        _bestSellingData.value = temp.take(10).toList();
      }
    } catch (e) {
      debugPrint("Error loading best sellers: $e");
    } finally {
      isLoadingBest.value = false;
    }
  }

  Future<void> getTrendingProducts() async {
    try {
      isLoadingTrending.value = true;
      final response =
          await http.get(Uri.parse('$baseUrl/Auth/trending_product'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final temp = data["trending_list"] as List;
        // ✅ FIX: Limit to 10 items for performance
        _exclusiveData.value = temp.take(10).toList();
      }
    } catch (e) {
      debugPrint("Error loading trending products: $e");
    } finally {
      isLoadingTrending.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // ✅ FIX: Prevents unnecessary resizing
      appBar: ThemedAppBar(
        title: "Celestial Ora",
        actions: [_buildNotificationIcon()],
      ),
      body: Stack(
        children: [
          Container(color: Colors.white),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: 15.h),
                _buildSearchBar(),
                SizedBox(height: 10.h),
                Expanded(
                  child: _buildMainContent(),
                ),
              ],
            ),
          ),
          _buildCartBottomBar(),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Obx(() {
      final count = notificationController.notificationCount.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          IconButton(
            icon: Icon(
              Icons.notifications_none,
              color: Colors.white,
              size: 25.sp,
            ),
            onPressed: () async {
              await Get.to(() => NotificationScreen());
              notificationController.clearNotificationCount();
            },
          ),
          if (count > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                width: 18.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 9 ? '9+' : '$count',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildSearchBar() {
    final screenWidth = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        // ✅ FIX: Use showModalBottomSheet instead of Get.to
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                ),
              ),
              child: SearchBottomSheet(),
            );
          },
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth / 24.35),
        padding: EdgeInsets.symmetric(horizontal: screenWidth / 50),
        height: screenWidth / 8.28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth / 27.6),
          color: const Color(0xFFF2F3F2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: screenWidth / 20,
              color: Colors.grey.shade800,
            ),
            SizedBox(width: screenWidth / 90),
            Flexible(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                child: Text(
                  _searchPlaceholders[_currentSearchIndex],
                  key: ValueKey<int>(_currentSearchIndex),
                  style: TextStyle(
                    color: const Color(0xFF7C7C7C),
                    fontSize: screenWidth / 29.57,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadInitialData();
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ✅ FIX: Marquee Banner
          SliverToBoxAdapter(child: _buildMarqueeBanner()),

          // ✅ FIX: Shop by Category
          SliverToBoxAdapter(child: _buildCategoriesSection()),

          // ✅ FIX: Banner Carousel
          SliverToBoxAdapter(child: _buildBannerCarousel()),

          // ✅ FIX: View More Button for Banner
          SliverToBoxAdapter(child: _buildViewMoreButton()),

          // ✅ FIX: Trending Products (Horizontal)
          SliverToBoxAdapter(child: _buildTrendingProductsSection()),

          // ✅ FIX: Best Selling (Horizontal)
          SliverToBoxAdapter(child: _buildBestSellingSection()),

          // ✅ FIX: All Products Grid (WITH PAGINATION)
          SliverToBoxAdapter(
            child: SectionHeader(
              screenWidth: MediaQuery.of(context).size.width,
              title: 'All Products',
              onPressed: () {},
            ),
          ),
          _buildAllProductsGrid(),

          // ✅ FIX: Shop by Category (Rectangle)
          SliverToBoxAdapter(child: _buildRectangleCategoriesSection()),

          // Add some bottom padding
          SliverToBoxAdapter(child: SizedBox(height: 80.h)),
        ],
      ),
    );
  }

  Widget _buildMarqueeBanner() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF8E1), // soft gold
            Color(0xFFFFECB3), // warm glow
          ],
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFD54F),
          width: 1,
        ),
      ),
      child: SizedBox(
        height: 28.h,
        child: Marquee(
          text:
              '✨ Celestial Ora — Elevate your beauty with luxurious skincare & makeup. Feel celestial every day ✨',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13.5.sp,
            letterSpacing: 0.4,
            color: Colors.brown.shade800,
          ),
          scrollAxis: Axis.horizontal,
          blankSpace: 60.0,
          velocity: 35.0,
          pauseAfterRound: const Duration(seconds: 1),
          startPadding: 10.0,
        ),
      ),
    );
  }

  // Widget _buildMarqueeBanner() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
  //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFFFFF3E0),
  //       borderRadius: BorderRadius.circular(10.r),
  //       border: Border.all(color: const Color(0xFFFFE0B2), width: 1.2),
  //     ),
  //     child: SizedBox(
  //       height: 25.h,
  //       child: Marquee(
  //         text:
  //             '💎 Celestial Ora 💎 Elevate your beauty with luxurious skincare & makeup ✨ Feel celestial every day',
  //         style: TextStyle(
  //           fontWeight: FontWeight.w600,
  //           fontSize: 14.sp,
  //           color: Colors.green.shade800,
  //         ),
  //         scrollAxis: Axis.horizontal,
  //         blankSpace: 50.0,
  //         velocity: 40.0,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildCategoriesSection() {
    return Obx(() {
      if (homeController.isLoadingCategories.value) {
        return _buildCategoriesShimmer();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            screenWidth: MediaQuery.of(context).size.width,
            title: "Shop by Category",
            onPressed: () {},
          ),
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: homeController.baseCategoriesList.length,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              itemBuilder: (context, index) {
                final category = homeController.baseCategoriesList[index];
                return _buildCategoryItem(category);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCategoriesShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          screenWidth: MediaQuery.of(context).size.width,
          title: "Shop From Wallet",
          onPressed: () {},
        ),
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: 70.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget _buildCategoryItem(Map<String, dynamic> category) {
  //   final imageUrl = baseCategoryImageUrl + category["image"];
  //   final screenWidth = MediaQuery.of(context).size.width;

  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 6),
  //     child: Column(
  //       children: [
  //         GestureDetector(
  //           onTap: () {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (_) => ProductListScreen(categoryDetails: category),
  //               ),
  //             );
  //           },
  //           child: Container(
  //             width: 55.w,
  //             height: 55.h,
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               border: Border.all(color: Colors.grey.shade400, width: 1.8.w),
  //             ),
  //             child: ClipOval(
  //               child: CachedNetworkImage(
  //                 imageUrl: imageUrl,
  //                 fit: BoxFit.cover,
  //                 placeholder: (context, url) => Container(
  //                   color: Colors.grey.shade300,
  //                 ),
  //                 errorWidget: (context, url, error) => const Icon(
  //                   Icons.broken_image,
  //                   color: Colors.grey,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //         SizedBox(height: 1.h),
  //         SizedBox(
  //           width: 60.w,
  //           child: Text(
  //             category["name"] ?? "",
  //             maxLines: 1,
  //             overflow: TextOverflow.ellipsis,
  //             textAlign: TextAlign.center,
  //             style: TextStyle(fontSize: 10.sp),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildCategoryItem(Map<String, dynamic> category) {
    final imageUrl = baseCategoryImageUrl + category["image"];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductListScreen(categoryDetails: category),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(2.5.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFE082),
                    Color(0xFFFFCC80),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                width: 54.w,
                height: 54.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          SizedBox(
            width: 68.w,
            child: Text(
              category["name"] ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2C2C2C),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return Obx(() {
      final banners = homeController.bestSellerList;

      return Container(
        width: MediaQuery.of(context).size.width,
        height: 200.h,
        margin: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: banners.isEmpty
            // 🌿 Elegant Empty State
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined,
                          size: 40, color: Colors.grey.shade400),
                      SizedBox(height: 8.h),
                      Text(
                        "No banners available",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              )

            // 🌸 Banner Carousel
            : ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.95),
                  itemCount: banners.length,
                  itemBuilder: (context, index) {
                    final banner = banners[index];
                    final imageUrl = banner['image'] != null
                        ? baseSliderImageUrl + banner['image']
                        : null;

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            imageUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.fill,
                                    height: double.infinity,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey.shade200,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.grey.shade100,
                                      child: const Center(
                                        child: Icon(Icons.broken_image,
                                            color: Colors.grey),
                                      ),
                                    ),
                                  )
                                : Container(color: Colors.grey.shade100),

                            // ✨ Soft gradient overlay (luxury feel)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.15),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      );
    });
  }

  // Widget _buildBannerCarousel() {
  //   return Obx(() {
  //     final banners = homeController.bestSellerList;

  //     return Container(
  //       width: MediaQuery.of(context).size.width,
  //       height: 200.h,
  //       margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
  //       child: banners.isEmpty
  //           ? Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.grey.shade200,
  //                 borderRadius: BorderRadius.circular(12.r),
  //               ),
  //               child: Center(
  //                 child: Text(
  //                   "No banners available",
  //                   style: TextStyle(color: Colors.grey.shade600),
  //                 ),
  //               ),
  //             )
  //           : ClipRRect(
  //               borderRadius: BorderRadius.circular(12.r),
  //               child: PageView.builder(
  //                 itemCount: banners.length,
  //                 itemBuilder: (context, index) {
  //                   final banner = banners[index];
  //                   final imageUrl = banner['image'] != null
  //                       ? baseSliderImageUrl + banner['image']
  //                       : null;

  //                   return imageUrl != null
  //                       ? CachedNetworkImage(
  //                           imageUrl: imageUrl,
  //                           fit: BoxFit.fill,
  //                           placeholder: (context, url) => Container(
  //                             color: Colors.grey.shade300,
  //                           ),
  //                           errorWidget: (context, url, error) => Container(
  //                             color: Colors.grey.shade200,
  //                             child: const Center(
  //                               child: Icon(Icons.broken_image,
  //                                   color: Colors.grey),
  //                             ),
  //                           ),
  //                         )
  //                       : Container(
  //                           color: Colors.grey.shade200,
  //                           child: const Center(
  //                             child: Text("No image"),
  //                           ),
  //                         );
  //                 },
  //               ),
  //             ),
  //     );
  //   });
  // }

  Widget _buildViewMoreButton() {
    return Padding(
      padding: EdgeInsets.only(right: 12.w, top: 8.h),
      child: Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton(
          onPressed: () {
            // if (homeController.baseCategoriesList.isEmpty ||
            //     homeController.categoryWiseProductMap.isEmpty) {
            //   Get.snackbar(
            //     "Loading",
            //     "Please wait while loading categories...",
            //     backgroundColor: Colors.orange,
            //     colorText: Colors.white,
            //   );
            //   return;
            // }

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => BestSellerWithCategoryScreen(
                  // categories: homeController.baseCategoriesList,
                  // categoryWiseProducts: homeController.categoryWiseProductMap,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          ),
          child: Text(
            "View More",
            style: TextStyle(fontSize: 12.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          screenWidth: MediaQuery.of(context).size.width,
          title: 'Trending Products',
          onPressed: () {},
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 250.h,
          child: Obx(() {
            if (isLoadingTrending.value) {
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                padding: EdgeInsets.only(left: 15.w),
                itemBuilder: (context, index) => _buildTrendingProductShimmer(),
              );
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _exclusiveData.length,
              padding: EdgeInsets.only(left: 15.w),
              itemBuilder: (context, index) {
                final product = _exclusiveData[index];
                return _buildTrendingProductItem(product);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTrendingProductShimmer() {
    return Container(
      width: 180.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            height: 140.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12.h,
                  width: 100.w,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 12.h,
                  width: 60.w,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingProductItem(Map<String, dynamic> product) {
    final productId = product["productid"]?.toString();
    final variants = product["variant"];
    final variantId =
        variants != null && variants is List && variants.isNotEmpty
            ? variants[0]["id"]?.toString()
            : null;
    final imageUrl = product["productimage"] != null
        ? baseProductImageUrl + product["productimage"]
        : null;

    return SizedBox(
      width: 180.w,
      child: Container(
        margin: EdgeInsets.only(right: 14.w, bottom: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌸 Product Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (productId != null && productId.isNotEmpty) {
                        Get.to(() => ProductDisplayScreen(id: productId));
                      }
                    },
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16.r)),
                      child: imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              placeholder: (context, url) => Container(
                                color: Colors.grey.shade200,
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: Icon(Icons.image_not_supported,
                                      color: Colors.grey),
                                ),
                              ),
                            )
                          : Container(
                              color: Colors.grey.shade100,
                            ),
                    ),
                  ),

                  // ✨ Optional badge (NEW / HOT)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "NEW",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🌿 Product Info
            Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["productname"] ?? "Product",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    variants != null && variants.isNotEmpty
                        ? "$indianRupeeSymbol ${variants[0]["special_price"]}"
                        : "N/A",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: secondaryColor,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // 🛒 Add to cart
                  Align(
                    alignment: Alignment.centerRight,
                    child: (variantId != null && productId != null)
                        ? _buildCartButton(productId, variantId)
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestSellingSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌿 Section Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: SectionHeader(
              screenWidth: MediaQuery.of(context).size.width,
              title: 'Best Selling',
              onPressed: () {},
            ),
          ),

          SizedBox(height: 10.h),

          // ✨ Optional soft divider
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Divider(
              thickness: 1,
              height: 1,
              color: Colors.grey.shade200,
            ),
          ),

          SizedBox(height: 12.h),

          // 🛍️ Product List
          SizedBox(
            height: 210.h,
            child: Obx(() {
              if (isLoadingBest.value) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  itemCount: 3,
                  itemBuilder: (_, index) => _buildBestSellingShimmer(),
                );
              }

              if (_bestSellingData.isEmpty) {
                return Center(
                  child: Text(
                    "No best selling products",
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 13.sp,
                    ),
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                itemCount: _bestSellingData.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final product = _bestSellingData[index];
                  return Padding(
                    padding: EdgeInsets.only(right: 10.w),
                    child: _buildBestSellingItem(product),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // Widget _buildBestSellingSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       SectionHeader(
  //         screenWidth: MediaQuery.of(context).size.width,
  //         title: 'Best Selling',
  //         onPressed: () {},
  //       ),
  //       SizedBox(height: 8.h),
  //       SizedBox(
  //         height: 200.h,
  //         child: Obx(() {
  //           if (isLoadingBest.value) {
  //             return ListView.builder(
  //               scrollDirection: Axis.horizontal,
  //               itemCount: 3,
  //               padding: EdgeInsets.symmetric(horizontal: 8.w),
  //               itemBuilder: (_, index) => _buildBestSellingShimmer(),
  //             );
  //           }

  //           return ListView.builder(
  //             scrollDirection: Axis.horizontal,
  //             itemCount: _bestSellingData.length,
  //             padding: EdgeInsets.symmetric(horizontal: 8.w),
  //             itemBuilder: (context, index) {
  //               final product = _bestSellingData[index];
  //               return _buildBestSellingItem(product);
  //             },
  //           );
  //         }),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildBestSellingShimmer() {
    return Container(
      width: 160.w,
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 12.h,
                  width: 100.w,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: 6.h),
                Container(
                  height: 10.h,
                  width: 60.w,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBestSellingItem(Map<String, dynamic> product) {
    final imageUrl = product['productimage'] != null &&
            product['productimage'].toString().isNotEmpty
        ? baseProductImageUrl + product['productimage']
        : null;

    final variants = product["variant"] ?? [];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDisplayScreen(id: product["productid"]),
          ),
        );
      },
      child: Container(
        width: 165.w,
        margin: EdgeInsets.only(right: 12.w, top: 10.h, bottom: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🌸 IMAGE + WISHLIST
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(18.r)),
                  child: Container(
                    height: 110.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.pink.shade50,
                          Colors.orange.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.grey.shade200,
                            ),
                            errorWidget: (_, __, ___) => const Center(
                              child: Icon(Icons.image_not_supported,
                                  color: Colors.grey),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.image_not_supported,
                                color: Colors.grey),
                          ),
                  ),
                ),
              ],
            ),

            // 🌿 CONTENT
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["productname"] ?? "Product",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        variants.isNotEmpty
                            ? "$indianRupeeSymbol ${variants[0]["special_price"]}"
                            : "Price N/A",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),

                      // 🛍️ Mini CTA
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          "View",
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildBestSellingItem(Map<String, dynamic> product) {
  //   final imageUrl = product['productimage'] != null &&
  //           product['productimage'].toString().isNotEmpty
  //       ? baseProductImageUrl + product['productimage']
  //       : null;
  //   final variants = product["variant"] ?? [];

  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) =>
  //               ProductDisplayScreen(id: product["productid"]),
  //         ),
  //       );
  //     },
  //     child: Container(
  //       width: 160.w,
  //       margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(12.r),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.08),
  //             blurRadius: 5,
  //             offset: const Offset(0, 3),
  //           ),
  //         ],
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Image
  //           ClipRRect(
  //             borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
  //             child: Container(
  //               height: 90.h,
  //               width: double.infinity,
  //               color: Colors.grey.shade100,
  //               child: imageUrl != null
  //                   ? CachedNetworkImage(
  //                       imageUrl: imageUrl,
  //                       fit: BoxFit.cover,
  //                       placeholder: (context, url) => Container(
  //                         color: Colors.grey.shade300,
  //                       ),
  //                       errorWidget: (context, url, error) => const Center(
  //                         child: Icon(Icons.image_not_supported,
  //                             color: Colors.grey),
  //                       ),
  //                     )
  //                   : const Center(
  //                       child:
  //                           Icon(Icons.image_not_supported, color: Colors.grey),
  //                     ),
  //             ),
  //           ),

  //           // Content
  //           Padding(
  //             padding: EdgeInsets.all(8.r),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   product["productname"] ?? "Product",
  //                   maxLines: 1,
  //                   overflow: TextOverflow.ellipsis,
  //                   style: TextStyle(
  //                     fontSize: 12.sp,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //                 SizedBox(height: 4.h),
  //                 Text(
  //                   variants.isNotEmpty
  //                       ? "$indianRupeeSymbol ${variants[0]["special_price"]}"
  //                       : "Price N/A",
  //                   style: TextStyle(
  //                     fontSize: 13.sp,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.green[700],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildAllProductsGrid() {
    return Obx(() {
      final products = homeController.trendingList;

      // 🌙 LOADING STATE
      if (homeController.isLoading.value) {
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, __) => _buildProductShimmer(),
              childCount: 6,
            ),
          ),
        );
      }

      // 🌿 EMPTY STATE
      if (products.isEmpty) {
        return SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: Column(
              children: [
                Icon(
                  Icons.spa_outlined,
                  size: 48.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 10.h),
                Text(
                  "No beauty products available",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // ✨ SHOW FIRST 20 PRODUCTS
      final displayProducts = products.take(20).toList();

      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.72,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return AnimatedScale(
                scale: 1,
                duration: const Duration(milliseconds: 300),
                child: _buildProductGridItem(displayProducts[index]),
              );
            },
            childCount: displayProducts.length,
          ),
        ),
      );
    });
  }

  // ✅ FIX: CRITICAL - Use SliverGrid for All Products with fixed heights
  // Widget _buildAllProductsGrid() {
  //   return Obx(() {
  //     final products = homeController.trendingList;

  //     if (homeController.isLoading.value) {
  //       return SliverGrid(
  //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //           crossAxisCount: 2,
  //           crossAxisSpacing: 8.w,
  //           mainAxisSpacing: 12.h,
  //           childAspectRatio: 0.6,
  //         ),
  //         delegate: SliverChildBuilderDelegate(
  //           (context, index) => _buildProductShimmer(),
  //           childCount: 4,
  //         ),
  //       );
  //     }

  //     if (products.isEmpty) {
  //       return SliverToBoxAdapter(
  //         child: Center(
  //           child: Padding(
  //             padding: EdgeInsets.symmetric(vertical: 20.h),
  //             child: Text(
  //               "No products available",
  //               style: TextStyle(fontSize: 14.sp, color: Colors.grey),
  //             ),
  //           ),
  //         ),
  //       );
  //     }

  //     // ✅ FIX: Limit to first 20 products for initial load
  //     final displayProducts = products.take(20).toList();

  //     return SliverPadding(
  //       padding: EdgeInsets.all(10.w),
  //       sliver: SliverGrid(
  //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //           crossAxisCount: 2,
  //           crossAxisSpacing: 8.w,
  //           mainAxisSpacing: 12.h,
  //           childAspectRatio: 0.75, // ✅ FIX: Better aspect ratio
  //         ),
  //         delegate: SliverChildBuilderDelegate(
  //           (context, index) {
  //             final product = displayProducts[index];
  //             return _buildProductGridItem(product);
  //           },
  //           childCount: displayProducts.length,
  //           addAutomaticKeepAlives: true,
  //           addRepaintBoundaries: true,
  //         ),
  //       ),
  //     );
  //   });
  // }

  Widget _buildProductShimmer() {
    return Container(
      margin: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110.h, // ✅ FIX: Reduced height
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12.r),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14.h,
                  width: 100.w,
                  color: Colors.grey.shade300,
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 14.h,
                  width: 60.w,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGridItem(Map<String, dynamic> product) {
    final productId = product["productid"]?.toString();
    final variants = product["variant"] ?? [];
    final variant = variants.isNotEmpty ? variants[0] : null;
    final variantId = variant?["id"]?.toString();
    final imageUrl = product["productimage"] != null
        ? baseProductImageUrl + product["productimage"]
        : "";

    // Calculate price
    final originalPrice =
        double.tryParse(variant?["price"]?.toString() ?? "0") ?? 0;
    final discountedPrice =
        double.tryParse(variant?["special_price"]?.toString() ?? "0") ?? 0;
    final hasDiscount = originalPrice > discountedPrice && discountedPrice > 0;

    return Container(
      margin: EdgeInsets.all(6.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          GestureDetector(
            onTap: () {
              if (productId != null) {
                Get.to(() => ProductDisplayScreen(id: productId));
              }
            },
            child: SizedBox(
              height: 110.h,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12.r),
                ),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                      )
                    : Icon(Icons.image_not_supported),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(8.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  product["productname"] ?? "Product",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: 4.h),

                // Price
                if (hasDiscount)
                  Text(
                    "₹${originalPrice.toInt()}",
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),

                Text(
                  "₹${discountedPrice.toInt()}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 5.h),

                // Add to cart
                SizedBox(
                  height: 32.h,
                  width: double.infinity,
                  child: productId != null && variantId != null
                      ? _buildCartButton(productId, variantId, isGrid: true)
                      : Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            "Unavailable",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRectangleCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          screenWidth: MediaQuery.of(context).size.width,
          title: "Shop by Category",
          onPressed: () {},
        ),
        SizedBox(
          height: 180.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: homeController.baseCategoriesList.length,
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            itemBuilder: (context, index) {
              final category = homeController.baseCategoriesList[index];
              return _buildRectangleCategoryItem(category);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRectangleCategoryItem(Map<String, dynamic> category) {
    final imageUrl = baseCategoryImageUrl + category["image"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Get.to(() => ProductListScreen(categoryDetails: category));
            },
            child: Container(
              width: 130.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade300,
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Icon(
                      Icons.category,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          SizedBox(
            width: 120.w,
            child: Text(
              category["name"] ?? "",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartButton(String productId, String variantId,
      {bool isGrid = false}) {
    return Obx(() {
      final isInCart = cartController.isInCart(productId, variantId);
      final quantity = cartController.getQuantity(productId, variantId);

      if (isInCart && quantity > 0) {
        return Container(
          height: isGrid ? 32.h : 36.h,
          //  width: isGrid ? double.infinity : 80.w,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isGrid ? 8.r : 16.r),
            border: Border.all(color: primaryColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () async {
                  if (quantity == 1) {
                    // Find cart ID from cartList
                    final cartItem = cartController.cartList.firstWhereOrNull(
                      (item) =>
                          item['product_id']?.toString() == productId &&
                          item['pv_id']?.toString() == variantId,
                    );

                    if (cartItem != null) {
                      await cartController
                          .removeFromCart(cartItem['cart_id'].toString());
                    } else {
                      // If not found in cartList, just update local state to 0
                      cartController.updateQuantity(productId, variantId, 0);
                    }
                  } else {
                    cartController.updateQuantity(
                        productId, variantId, quantity - 1);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.remove,
                    size: isGrid ? 16.sp : 18.sp,
                    color: primaryColor,
                  ),
                ),
              ),
              Text(
                quantity.toString(),
                style: TextStyle(
                  fontSize: isGrid ? 14.sp : 15.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  cartController.updateQuantity(
                      productId, variantId, quantity + 1);
                },
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.add,
                    size: isGrid ? 16.sp : 18.sp,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return InkWell(
          onTap: () {
            cartController.addToCartReactive(productId, 1, variantId, context);
          },
          child: Container(
            height: isGrid ? 32.h : 36.h,
            width: isGrid ? double.infinity : 36.w,
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(isGrid ? 8.r : 12.r),
            ),
            child: Center(
              child: isGrid
                  ? Text(
                      "Add to Cart",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 18.sp,
                    ),
            ),
          ),
        );
      }
    });
  }

  Widget _buildCartBottomBar() {
    return Positioned(
      bottom: 20.h,
      left: 30.w,
      right: 30.w,
      child: Obx(() {
        // FIX: Use the most accurate count
        final count = cartController.cartItemCount.value;
        final total = cartController.cartTotalPrice.value;

        if (count == 0) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () async {
            // Refresh cart before going to order summary
            await cartController.refreshCartWithRetry();
            Get.to(() => OrderSummary(orderList: cartController.cartList));
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart, color: Colors.white, size: 18.sp),
                SizedBox(width: 8.w),
                Text(
                  "$count items | ₹${total.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
