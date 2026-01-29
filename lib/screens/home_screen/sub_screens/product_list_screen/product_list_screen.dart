import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/home_screen/search_screens/search_screen.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/cart_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/product_display_screen/product_display_screen.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/product_list_screen/sub_screens/filter_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductListScreen extends StatefulWidget {
  final dynamic categoryDetails;
  const ProductListScreen({Key? key, required this.categoryDetails})
      : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // ✅ FIX: Use pagination variables
  bool isLoading = true;
  bool isLoadingMore = false;
  List _productList = [];
  int _currentPage = 1;
  bool _hasMore = true;
  final int _itemsPerPage = 20; // Load 20 at a time
  final ScrollController _scrollController = ScrollController();

  // ✅ FIX: Get CartController
  CartController get cartController => Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    _loadProducts();

    // ✅ FIX: Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadProducts({bool loadMore = false}) async {
    if (loadMore) {
      if (isLoadingMore || !_hasMore) return;
      setState(() => isLoadingMore = true);
    } else {
      setState(() => isLoading = true);
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/Auth/product_list_fetch'),
      );

      // ✅ FIX: Add pagination parameters
      request.fields.addAll({
        'category_id': widget.categoryDetails['id'],
        'page': _currentPage.toString(),
        'limit': _itemsPerPage.toString(),
      });

      final response = await request.send();

      if (response.statusCode == 200) {
        final res = await response.stream.bytesToString();
        final data = jsonDecode(res);
        final newProducts = data['product_list'] ?? [];

        setState(() {
          if (loadMore) {
            _productList.addAll(newProducts);
          } else {
            _productList = newProducts;
          }

          // Check if there are more products
          _hasMore = newProducts.length == _itemsPerPage;
          if (loadMore) _currentPage++;
        });
      }
    } catch (e) {
      debugPrint("Error loading products: $e");
    } finally {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (isLoadingMore || !_hasMore) return;

    await _loadProducts(loadMore: true);
  }

  Future<void> _refreshProducts() async {
    _currentPage = 1;
    _hasMore = true;
    await _loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThemedAppBar(
        title: widget.categoryDetails['name'],
        showBack: true,
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       showModalBottomSheet(
        //         context: context,
        //         isScrollControlled: true,
        //         backgroundColor: Colors.transparent,
        //         builder: (context) {
        //           return FractionallySizedBox(
        //             heightFactor: 0.9,
        //             child: Container(
        //               decoration: const BoxDecoration(
        //                 color: Colors.white,
        //                 borderRadius: BorderRadius.vertical(
        //                   top: Radius.circular(20),
        //                 ),
        //               ),
        //               child: SafeArea(
        //                 child: SearchBottomSheet(
        //                   scrollController: ScrollController(),
        //                 ),
        //               ),
        //             ),
        //           );
        //         },
        //       );
        //     },
        //     icon: const Icon(Icons.search, color: Colors.white),
        //   ),
        //   IconButton(
        //     onPressed: () {
        //       Navigator.of(context).push(
        //         MaterialPageRoute(
        //           builder: (context) => const FilterScreen(),
        //         ),
        //       );
        //     },
        //     icon: const Icon(Icons.tune, color: Colors.white),
        //   ),
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProducts,
        child: _buildProductGrid(),
      ),
    );
  }

  Widget _buildProductGrid() {
    if (isLoading && _productList.isEmpty) {
      return _buildShimmerGrid();
    }

    if (_productList.isEmpty) {
      return const Center(
        child: Text(
          "No products found",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ✅ FIX: Using SliverGrid for better performance
        SliverPadding(
          padding: EdgeInsets.all(12.w),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.70,
              mainAxisSpacing: 12.w,
              crossAxisSpacing: 12.w,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // ✅ FIX: Only build visible items + loading indicator
                if (index < _productList.length) {
                  return _buildProductCard(_productList[index]);
                }
                return null;
              },
              childCount: _productList.length + (_hasMore ? 1 : 0),
              addAutomaticKeepAlives: true,
              addRepaintBoundaries: true,
            ),
          ),
        ),

        // ✅ FIX: Loading indicator for pagination
        if (isLoadingMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),
            ),
          ),

        // ✅ FIX: No more items indicator
        if (!_hasMore && _productList.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: Text(
                  "No more products",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final variantList = product["variant"] ?? [];
    final hasStock = variantList.isNotEmpty;
    final variant = hasStock ? variantList[0] : null;
    final productId = product["productid"]?.toString();
    final variantId = variant?["id"]?.toString();
    final imageUrl = product["productimage"] != null
        ? baseProductImageUrl + product["productimage"]
        : "";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👇 IMAGE CLICK ONLY
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                if (productId != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductDisplayScreen(id: productId),
                    ),
                  );
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12.r),
                ),
                child: Container(
                  color: Colors.grey.shade100,
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 1,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.broken_image),
                        )
                      : Icon(
                          Icons.image_not_supported,
                          size: 40.sp,
                          color: Colors.grey.shade400,
                        ),
                ),
              ),
            ),
          ),

          // 👇 TEXT + BUTTON (NOT CLICKABLE)
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product["productname"]?.toString() ?? "Product",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (variant != null)
                          Text(
                            "$indianRupeeSymbol ${variant['special_price'] ?? variant['price']}",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (!hasStock)
                          Text(
                            "Out of Stock",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.red,
                            ),
                          ),
                      ],
                    ),
                    if (hasStock && productId != null && variantId != null)
                      _buildAddToCartButton(
                          productId: productId, variantId: variantId),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartButton({
    required String productId,
    required String variantId,
    bool isGrid = false,
  }) {
    return Obx(() {
      // ✅ Direct reactive check that Obx can track
      final key = '$productId-$variantId';
      final isInCart = cartController.localCartItems.containsKey(key) &&
          (cartController.localCartItems[key] ?? 0) > 0;

      final height = isGrid ? 28.h : 36.h;

      return GestureDetector(
          onTap: () async {
            // Get fresh value
            final currentKey = '$productId-$variantId';
            final currentIsInCart =
                cartController.localCartItems.containsKey(currentKey) &&
                    (cartController.localCartItems[currentKey] ?? 0) > 0;

            if (currentIsInCart) {
              // Remove from cart
              cartController.localCartItems.remove(currentKey);
              // The .obs map will automatically notify Obx

              // Also remove from server cart if exists
              final cartItem = cartController.cartList.firstWhereOrNull(
                (item) =>
                    item['product_id']?.toString() == productId &&
                    item['pv_id']?.toString() == variantId,
              );

              if (cartItem != null && cartItem['cart_id'] != null) {
                await cartController
                    .removeFromCart(cartItem['cart_id'].toString());
              }
            } else {
              // Add to cart
              await cartController.addToCart(productId, 1, variantId, context);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: height,
            width: isGrid ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: isGrid ? 10.w : 14.w,
              vertical: isGrid ? 6.h : 8.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isGrid ? 10.r : 14.r),

              // ---- Background ----
              gradient: isInCart
                  ? null
                  : LinearGradient(
                      colors: [
                        primaryColor,
                        primaryColor.withOpacity(0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),

              color: isInCart ? Colors.red.shade50 : null,

              // ---- Border ----
              border: Border.all(
                color: isInCart ? Colors.red.shade300 : Colors.transparent,
                width: 1.4,
              ),

              // ---- Shadow ----
              boxShadow: [
                BoxShadow(
                  color: isInCart
                      ? Colors.red.withOpacity(0.12)
                      : primaryColor.withOpacity(0.35),
                  blurRadius: isInCart ? 6 : 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isInCart
                      ? Icons.check_circle_rounded
                      : Icons.add_shopping_cart_outlined,
                  size: isGrid ? 14.sp : 16.sp,
                  color: isInCart ? Colors.red.shade600 : Colors.white,
                ),
                6.w.horizontalSpace,
                Text(
                  isInCart ? "Added" : "Add",
                  style: TextStyle(
                    fontSize: isGrid ? 10.sp : 11.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                    color: isInCart ? Colors.red.shade600 : Colors.white,
                  ),
                ),
              ],
            ),
          )

          //  Container(
          //     height: height,
          //     width: isGrid ? double.infinity : null,
          //     decoration: BoxDecoration(
          //       gradient: isInCart
          //           ? LinearGradient(
          //               colors: [Colors.red.shade50, Colors.white],
          //               begin: Alignment.topLeft,
          //               end: Alignment.bottomRight,
          //             )
          //           : LinearGradient(
          //               colors: [primaryColor, primaryColor.withOpacity(0.8)],
          //               begin: Alignment.topLeft,
          //               end: Alignment.bottomRight,
          //             ),
          //       borderRadius: BorderRadius.circular(isGrid ? 8.r : 10.r),
          //       border: isInCart
          //           ? Border.all(color: Colors.red.shade300, width: 1.5)
          //           : null,
          //       boxShadow: isInCart
          //           ? [
          //               BoxShadow(
          //                 color: Colors.red.withOpacity(0.1),
          //                 blurRadius: 6,
          //                 offset: Offset(0, 2),
          //               ),
          //             ]
          //           : [
          //               BoxShadow(
          //                 color: primaryColor.withOpacity(0.3),
          //                 blurRadius: 8,
          //                 offset: Offset(0, 3),
          //               ),
          //             ],
          //     ),
          //     child: Container(
          //       padding: EdgeInsets.symmetric(
          //         horizontal: isGrid ? 10.w : 14.w,
          //         vertical: isGrid ? 6.h : 8.h,
          //       ),
          //       decoration: BoxDecoration(
          //         color: isInCart ? Colors.red.shade50 : primaryColor,
          //         borderRadius: BorderRadius.circular(30.r),
          //         border: Border.all(
          //           color: isInCart ? Colors.red.shade300 : primaryColor,
          //           width: 1,
          //         ),
          //         boxShadow: [
          //           if (!isInCart)
          //             BoxShadow(
          //               color: primaryColor.withOpacity(0.35),
          //               blurRadius: 8,
          //               offset: const Offset(0, 4),
          //             ),
          //         ],
          //       ),
          //       child: Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Icon(
          //             isInCart
          //                 ? Icons.remove_shopping_cart_outlined
          //                 : Icons.add_shopping_cart_outlined,
          //             size: isGrid ? 14.sp : 16.sp,
          //             color: isInCart ? Colors.red.shade600 : Colors.white,
          //           ),
          //           6.w.horizontalSpace,
          //           Text(
          //             isInCart ? "Remove" : "Add",
          //             style: TextStyle(
          //               fontSize: isGrid ? 10.sp : 11.sp,
          //               fontWeight: FontWeight.w600,
          //               color: isInCart ? Colors.red.shade600 : Colors.white,
          //               letterSpacing: 0.4,
          //             ),
          //           ),
          //         ],
          //       ),
          //     )

          //     //  Center(
          //     //   child: Row(
          //     //     mainAxisAlignment: MainAxisAlignment.center,
          //     //     children: [
          //     //       Icon(
          //     //         isInCart
          //     //             ? Icons.remove_shopping_cart
          //     //             : Icons.add_shopping_cart,
          //     //         color: isInCart ? Colors.red.shade600 : Colors.white,
          //     //         size: isGrid ? 12.sp : 16.sp,
          //     //       ),
          //     //       SizedBox(width: 6.w),
          //     //       Text(
          //     //         isInCart ? "Remove" : "Add to cart",
          //     //         style: TextStyle(
          //     //           color: isInCart ? Colors.red.shade600 : Colors.white,
          //     //           fontSize: isGrid ? 10.sp : 10.sp,
          //     //           fontWeight: FontWeight.w600,
          //     //           letterSpacing: 0.3,
          //     //         ),
          //     //       ),
          //     //     ],
          //     //   ),
          //     // ),
          //     ),

          );
    });
  }
  // Widget _buildAddToCartButton(String productId, String variantId) {
  //   return Obx(() {
  //     final isInCart = cartController.isInCart(productId, variantId);
  //     final quantity = cartController.getQuantity(productId, variantId);

  //     if (isInCart && quantity > 0) {
  //       return Container(
  //         width: 80.w,
  //         height: 32.h,
  //         decoration: BoxDecoration(
  //           color: primaryColor.withOpacity(0.1),
  //           borderRadius: BorderRadius.circular(16.r),
  //           border: Border.all(color: primaryColor),
  //         ),
  //         child: Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //           children: [
  //             GestureDetector(
  //               onTap: () {
  //                 cartController.updateQuantity(
  //                     productId, variantId, quantity - 1);
  //               },
  //               child: Icon(
  //                 Icons.remove,
  //                 size: 16.sp,
  //                 color: primaryColor,
  //               ),
  //             ),
  //             Text(
  //               quantity.toString(),
  //               style: TextStyle(
  //                 fontSize: 14.sp,
  //                 fontWeight: FontWeight.bold,
  //                 color: primaryColor,
  //               ),
  //             ),
  //             GestureDetector(
  //               onTap: () {
  //                 cartController.updateQuantity(
  //                     productId, variantId, quantity + 1);
  //               },
  //               child: Icon(
  //                 Icons.add,
  //                 size: 16.sp,
  //                 color: primaryColor,
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     } else {
  //       return InkWell(
  //         onTap: () {
  //           cartController.addToCartReactive(productId, 1, variantId, context);
  //         },
  //         child: Container(
  //           height: 36.h,
  //           width: 36.w,
  //           decoration: BoxDecoration(
  //             color: primaryColor,
  //             borderRadius: BorderRadius.circular(12.r),
  //           ),
  //           child: Icon(
  //             Icons.add,
  //             color: Colors.white,
  //             size: 18.sp,
  //           ),
  //         ),
  //       );
  //     }
  //   });
  // }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(12.w),
      itemCount: 6, // Show only 6 shimmer items
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70,
        mainAxisSpacing: 12.w,
        crossAxisSpacing: 12.w,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image shimmer
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                  ),
                ),
              ),
              // Content shimmer
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 12.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      Container(
                        height: 12.h,
                        width: 80.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 16.h,
                            width: 50.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          Container(
                            height: 30.h,
                            width: 30.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
