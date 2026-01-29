import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/home_screen/home_controller.dart';
import 'package:organic_saga/screens/home_screen/search_screens/search_screen.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/cart_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/cart_screen.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/sub_screens/order_summary.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/product_display_screen/WishlistController.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/product_display_screen/product_controller.dart';
import 'package:organic_saga/shared_pref/shared_pref.dart';

String cleanText(String text) {
  return text.replaceAll(RegExp(r'<[^>]*>|[\r\n]'), '').trim();
}

class ProductDisplayScreen extends StatefulWidget {
  final String id;
  const ProductDisplayScreen({super.key, required this.id});

  @override
  State<ProductDisplayScreen> createState() => _ProductDisplayScreenState();
}

class _ProductDisplayScreenState extends State<ProductDisplayScreen> {
  final HomeController _homeController = Get.find();
  final CartController _cartController = Get.find<CartController>();
  final WishlistController _wishlistController = Get.find<WishlistController>();

  late ProductController _productController;
  final _faqController = TextEditingController();

  final _productDetails = {}.obs;
  final _selectedVariantIndex = 0.obs;
  final _faqs = <dynamic>[].obs;
  final _isLoading = true.obs;
  final _isFaqLoading = true.obs;
  final _showDescription = true.obs;
  final _currentPage = 0.obs;
  final _isFavorite = false.obs;
  final _selectedTabIndex = 0.obs; // 0: Description, 1: FAQs

  late PageController _pageController;
  Timer? _autoScrollTimer;
  final TransformationController _transformationController =
      TransformationController();
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _productController = Get.put(ProductController(productId: widget.id));
    _pageController = PageController();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _fetchProductDetails(),
      _fetchWishlistData(),
      _fetchFaqs(),
    ]);
  }

  Future<void> _fetchProductDetails() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/Auth/product_details_fetch"),
        body: {"product_id": widget.id},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _productDetails.value = data["product_details"] ?? {};

        final variant = _productDetails["variant"];
        if (variant is List && variant.isNotEmpty) {
          final extraImages = (variant[0]["extra_images"] ?? "").split(",");
          _startAutoScroll(extraImages.where((img) => img.isNotEmpty).toList());
        }
      }
    } catch (e) {
      debugPrint("Error fetching product details: $e");
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _fetchWishlistData() async {
    final userId = await SharedPref.getUserId();
    if (userId != null) {
      await _wishlistController.getWishlist(userId);
      _isFavorite.value = _wishlistController.isInWishlist(widget.id);
    }
  }

  Future<void> _fetchFaqs() async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/Auth/faqs_list_fetch"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _faqs.value = data["faqs_list"] ?? [];
      }
    } catch (e) {
      debugPrint("Error fetching FAQs: $e");
    } finally {
      _isFaqLoading.value = false;
    }
  }

  Future<void> _sendFaq(String question) async {
    if (question.trim().isEmpty) {
      Get.snackbar("Error", "Please enter your question");
      return;
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/Auth/faqs_save'),
      );

      final user = _homeController.userModel.value;
      request.fields.addAll({
        "name": user.username ?? "",
        "email": user.email ?? "",
        "mobile_no": user.mobile ?? "",
        "question": question,
        "product_id": widget.id,
      });

      final response = await request.send();
      final res = await response.stream.bytesToString();
      final data = jsonDecode(res);

      if (response.statusCode == 200 && data["status"] == 200) {
        Get.snackbar(
            "Success", data["message"] ?? "Your question has been sent");
        _faqController.clear();
        await _fetchFaqs();
      } else {
        Get.snackbar("Error", "Failed to send FAQ");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to send FAQ");
    }
  }

  void _startAutoScroll(List<String> images) {
    _autoScrollTimer?.cancel();
    if (images.isEmpty) return;

    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_pageController.hasClients && _currentScale <= 1.1) {
        final nextPage = (_currentPage.value + 1) % images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        _currentPage.value = nextPage;
      }
    });
  }

  Map<String, dynamic>? get _selectedVariant {
    final variantList = _productDetails["variant"] ?? [];
    if (variantList is List &&
        variantList.isNotEmpty &&
        _selectedVariantIndex.value < variantList.length) {
      return variantList[_selectedVariantIndex.value];
    }
    return null;
  }

  double get _unitPrice {
    final variant = _selectedVariant;
    final specialPrice = double.tryParse(variant?["special_price"] ?? "0") ?? 0;
    final price = double.tryParse(variant?["price"] ?? "0") ?? 0;
    return specialPrice > 0 ? specialPrice : price;
  }

  double get _totalPrice => _unitPrice * _productController.quantity.value;

  // Check if product is out of stock
  // Update this getter to properly check variant stock
  bool get _isOutOfStock {
    final variant = _selectedVariant;

    // First check if we have a selected variant
    if (variant != null) {
      final variantStock = variant["stock"]?.toString();
      if (variantStock != null) {
        final variantStockValue = int.tryParse(variantStock) ?? 0;
        // If variant has 0 stock, product is out of stock for this variant
        return variantStockValue <= 0;
      }
    }

    // Fallback to product stock if no variant stock info
    final productStock = _productDetails["stock"]?.toString() ?? "0";
    final stockValue = int.tryParse(productStock) ?? 0;
    return stockValue <= 0;
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _faqController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Obx(() => _isLoading.value ? _buildShimmerUI() : _buildContent()),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return ThemedAppBar(
        title: "Product Details",
        showBack: true,
        onSearchTap: () {},
        onCartTap: () => Get.to(Cart()));

    // AppBar(
    //   backgroundColor: Colors.white,
    //   elevation: 0,
    //   leading: IconButton(
    //     icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
    //     onPressed: () => Get.back(),
    //   ),
    //   title: Text(
    //     "Product Details",
    //     style: TextStyle(
    //       fontSize: 18.sp,
    //       fontWeight: FontWeight.w600,
    //       color: Colors.black,
    //     ),
    //   ),
    //   centerTitle: true,
    //   actions: [
    //     IconButton(
    //       icon: Icon(Icons.search, color: Colors.black, size: 24.sp),
    //       onPressed: _openSearch,
    //     ),
    //     SizedBox(width: 8.w),
    //   ],
    // );
  }

  void _openSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SearchBottomSheet(),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageCarousel(),
          SizedBox(height: 16.h),
          _buildProductInfo(),
          SizedBox(height: 20.h),
          _buildTabsSection(),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    final variant = _selectedVariant;
    final extraImages = (variant?["extra_images"]?.toString() ?? "")
        .split(",")
        .where((img) => img.isNotEmpty)
        .toList();

    return Stack(
      children: [
        Container(
          height: 320.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.shade50,
                Colors.white,
              ],
            ),
          ),
          child: extraImages.isNotEmpty
              ? _buildImagePageView(extraImages)
              : _buildNoImagePlaceholder(),
        ),

        // Product tag
        Positioned(
          top: 20.h,
          left: 20.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              "Organic",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // Out of Stock Badge
        if (_isOutOfStock)
          Positioned(
            top: 20.h,
            left: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                "Out of Stock",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        // Favorite button
        Positioned(
          top: 20.h,
          right: 20.w,
          child: Obx(() => GestureDetector(
                onTap: _isOutOfStock ? null : _toggleFavorite,
                child: Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      _isFavorite.value
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: _isFavorite.value
                          ? Colors.red
                          : (_isOutOfStock
                              ? Colors.grey.shade300
                              : Colors.grey),
                      size: 22.sp,
                    ),
                  ),
                ),
              )),
        ),

        // Page indicators
        if (extraImages.length > 1)
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                extraImages.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: _currentPage.value == index ? 24.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: _currentPage.value == index
                        ? primaryColor
                        : Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImagePageView(List<String> images) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) => _currentPage.value = index,
      itemCount: images.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: InteractiveViewer(
          transformationController: _transformationController,
          onInteractionUpdate: (details) {
            _currentScale = details.scale;
            if (_currentScale > 1.1) {
              _autoScrollTimer?.cancel();
            }
          },
          onInteractionEnd: (details) {
            if (_currentScale <= 1.1) {
              _startAutoScroll(images);
            }
          },
          panEnabled: true,
          scaleEnabled: true,
          minScale: 0.8,
          maxScale: 3.0,
          child: Hero(
            tag: "product_${widget.id}_$index",
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: baseProductImageUrl + images[index],
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.image_not_supported,
                    size: 60.sp,
                    color: Colors.grey.shade300,
                  ),
                ),
                if (_isOutOfStock)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          "Out of Stock",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 80.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            "No Image Available",
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    final variant = _selectedVariant;
    final price = double.tryParse(variant?["price"] ?? "0") ?? 0;
    final specialPrice = double.tryParse(variant?["special_price"] ?? "0") ?? 0;
    final hasDiscount = specialPrice > 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product title
          Text(
            _productDetails['productname']?.toString() ?? 'Product Name',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              height: 1.3,
            ),
          ),

          SizedBox(height: 10.h),

          // Price section
          Row(
            children: [
              Text(
                "$indianRupeeSymbol${hasDiscount ? specialPrice.toStringAsFixed(2) : price.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: _isOutOfStock
                      ? Colors.grey.shade500
                      : Colors.green.shade700,
                ),
              ),
              if (hasDiscount) ...[
                SizedBox(width: 12.w),
                Text(
                  "$indianRupeeSymbol${price.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Text(
                    "${((price - specialPrice) / price * 100).toStringAsFixed(0)}% OFF",
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            "Inclusive of all taxes",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
            ),
          ),

          // Stock status
          SizedBox(height: 8.h),
          _buildStockStatus(),
          SizedBox(height: 16.h),

          // Variant Selection
          _buildVariantSelector(),
          SizedBox(height: 24.h),

          // Quantity selector
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Quantity",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: _isOutOfStock
                              ? Colors.grey.shade100
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Container(
                                width: 36.w,
                                height: 36.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isOutOfStock
                                      ? Colors.grey.shade200
                                      : Colors.grey.shade100,
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 18.sp,
                                  color: _isOutOfStock
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700,
                                ),
                              ),
                              onPressed: _isOutOfStock
                                  ? null
                                  : () {
                                      if (_productController.quantity.value >
                                          1) {
                                        _productController.quantity.value--;
                                      }
                                    },
                            ),
                            Obx(() => Text(
                                  _productController.quantity.value.toString(),
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: _isOutOfStock
                                        ? Colors.grey.shade500
                                        : Colors.black,
                                  ),
                                )),
                            IconButton(
                              icon: Container(
                                width: 36.w,
                                height: 36.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isOutOfStock
                                      ? Colors.grey.shade200
                                      : primaryColor.withOpacity(0.1),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 18.sp,
                                  color: _isOutOfStock
                                      ? Colors.grey.shade400
                                      : primaryColor,
                                ),
                              ),
                              onPressed: _isOutOfStock
                                  ? null
                                  : () => _productController.quantity.value++,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: _isOutOfStock
                            ? Colors.grey.shade100
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                            color: _isOutOfStock
                                ? Colors.grey.shade300
                                : Colors.green.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Obx(() => Text(
                                "$indianRupeeSymbol${_totalPrice.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _isOutOfStock
                                      ? Colors.grey.shade500
                                      : Colors.green.shade800,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockStatus() {
    // Check variant stock first
    final variant = _selectedVariant;
    final variantStock = variant?["stock"]?.toString();

    if (variantStock != null) {
      final variantStockValue = int.tryParse(variantStock) ?? 0;

      if (variantStockValue <= 0) {
        return Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              "Out of Stock",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      } else if (variantStockValue <= 10) {
        return Row(
          children: [
            Icon(Icons.warning_amber, color: Colors.orange, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              "Only $variantStockValue left in stock",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      } else {
        return Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
            SizedBox(width: 6.w),
            Text(
              "In Stock",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }
    }

    // Fallback to product stock if no variant info
    final productStock = _productDetails["stock"]?.toString() ?? "0";
    final stockValue = int.tryParse(productStock) ?? 0;

    if (stockValue <= 0) {
      return Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
          SizedBox(width: 6.w),
          Text(
            "Out of Stock",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else if (stockValue <= 10) {
      return Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange, size: 16.sp),
          SizedBox(width: 6.w),
          Text(
            "Only $stockValue left in stock",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
          SizedBox(width: 6.w),
          Text(
            "In Stock",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildVariantSelector() {
    final variantList = _productDetails["variant"] ?? [];
    if (variantList is! List || variantList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Variant",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: List.generate(variantList.length, (index) {
            final variant = variantList[index];
            final variantText = variant["variant_text"]?.toString() ?? "";
            final isSelected = _selectedVariantIndex.value == index;
            final price =
                double.tryParse(variant["price"]?.toString() ?? "0") ?? 0;
            final specialPrice =
                double.tryParse(variant["special_price"]?.toString() ?? "0") ??
                    0;
            final hasDiscount = specialPrice > 0;

            // Check variant stock - FIXED: Don't call _isOutOfStock here
            final variantStock = variant["stock"]?.toString();
            final variantStockValue = int.tryParse(variantStock ?? "0") ?? 0;
            final isVariantOutOfStock = variantStockValue <= 0;

            return GestureDetector(
              onTap: isVariantOutOfStock
                  ? null
                  : () => _updateStockStatusForVariant(index),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isVariantOutOfStock
                      ? Colors.grey.shade100
                      : (isSelected
                          ? primaryColor.withOpacity(0.1)
                          : Colors.white),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isVariantOutOfStock
                        ? Colors.grey.shade300
                        : (isSelected ? primaryColor : Colors.grey.shade300),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected && !isVariantOutOfStock
                      ? [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      variantText,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isVariantOutOfStock
                            ? Colors.grey.shade400
                            : (isSelected
                                ? primaryColor
                                : Colors.grey.shade800),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      hasDiscount
                          ? "$indianRupeeSymbol${specialPrice.toStringAsFixed(2)}"
                          : "$indianRupeeSymbol${price.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: isVariantOutOfStock
                            ? Colors.grey.shade400
                            : (isSelected
                                ? primaryColor
                                : Colors.green.shade700),
                      ),
                    ),
                    if (hasDiscount)
                      Text(
                        "$indianRupeeSymbol${price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    if (isVariantOutOfStock)
                      Container(
                        margin: EdgeInsets.only(top: 4.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          "Out of Stock",
                          style: TextStyle(
                            fontSize: 8.sp,
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _updateStockStatusForVariant(int index) {
    _selectedVariantIndex.value = index;

    // Update images when variant changes
    final variantList = _productDetails["variant"] ?? [];
    if (variantList is List && index < variantList.length) {
      final variant = variantList[index];
      final extraImages = (variant["extra_images"]?.toString() ?? "")
          .split(",")
          .where((img) => img.isNotEmpty)
          .toList();
      _startAutoScroll(extraImages);
    }

    // Reset to first image when variant changes
    _currentPage.value = 0;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }

    // Trigger UI rebuild for stock status
    setState(() {});
  }

  Widget _buildTabsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          // Tab headers - Only Description and FAQs
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                _buildTabItem("Description", 0),
                _buildTabItem("FAQs", 1),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Tab content
          Obx(() {
            if (_selectedTabIndex.value == 0) {
              return _buildDescription();
            } else {
              return _buildFaqSection();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectedTabIndex.value = index,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: _selectedTabIndex.value == index
                ? primaryColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: _selectedTabIndex.value == index
                    ? Colors.white
                    : Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        _productDetails["description"]?.toString()?.isNotEmpty == true
            ? cleanText(_productDetails["description"].toString())
            : "No description available for this product.",
        style: TextStyle(
          fontSize: 14.sp,
          color: Colors.grey.shade700,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    return Column(
      children: [
        // FAQ Input
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Have a question?",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _faqController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Type your question here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: primaryColor),
                  ),
                  contentPadding: EdgeInsets.all(16.w),
                ),
              ),
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.send, size: 16.sp),
                  onPressed: () => _sendFaq(_faqController.text.trim()),
                  label: Text("Ask Question"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),

        // FAQ List
        if (_faqs.isNotEmpty) ...[
          Text(
            "Frequently Asked Questions",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16.h),
          ..._faqs.map((faq) => _buildFaqItem(faq)).toList(),
        ] else if (!_isFaqLoading.value) ...[
          Container(
            padding: EdgeInsets.all(40.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.question_answer,
                  size: 48.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16.h),
                Text(
                  "No questions yet",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Be the first to ask a question!",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> faq) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                size: 16.sp,
                color: primaryColor,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  faq['question'] ?? '',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 16.sp,
                color: Colors.green,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  faq['answer']?.isNotEmpty == true
                      ? faq['answer']
                      : 'No answer yet',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Obx(() {
      if (_isLoading.value) return const SizedBox.shrink();

      if (_isOutOfStock) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 24.w,
            vertical: 16.h,
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.grey.shade600,
                padding: EdgeInsets.symmetric(vertical: 18.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    "Out of Stock",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 24.w,
          vertical: 16.h,
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Add to Cart button
              Expanded(
                child: ElevatedButton.icon(
                  icon: _cartController.isAddToCartLoading.value
                      ? SizedBox(
                          width: 20.sp,
                          height: 20.sp,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.shopping_cart_outlined,
                          size: 20.sp,
                        ),
                  onPressed: _cartController.isAddToCartLoading.value
                      ? null
                      : () => _addToCart(),
                  label: Text(
                    "Add to Cart",
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),

              // Buy Now button
              Expanded(
                child: ElevatedButton.icon(
                  icon: _cartController.isBuyNowLoading.value
                      ? SizedBox(
                          width: 20.sp,
                          height: 20.sp,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          Icons.flash_on,
                          size: 20.sp,
                        ),
                  onPressed: _cartController.isBuyNowLoading.value
                      ? null
                      : () => _buyNow(),
                  label: Text(
                    "Buy Now",
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isOutOfStock) return;

    final userId = await SharedPref.getUserId();
    if (userId == null) {
      Get.snackbar("Login Required", "Please login to manage wishlist");
      return;
    }

    if (_isFavorite.value) {
      final item = _wishlistController.favList.firstWhereOrNull(
        (e) => e['product_id'].toString() == widget.id,
      );
      if (item != null) {
        await _wishlistController.removeFromWishlist(
            item['wid'].toString(), userId);
      }
    } else {
      await _wishlistController.addToWishlist(widget.id, userId);
    }

    await _wishlistController.getWishlist(userId);
    _isFavorite.value = !_isFavorite.value;
  }

  Future<void> _addToCart() async {
    if (_isOutOfStock) {
      Get.snackbar("Out of Stock", "This product is currently out of stock");
      return;
    }

    final userId = await SharedPref.getUserId();
    if (userId == null) {
      Get.snackbar("Login Required", "Please login to add product to cart");
      return;
    }

    final selectedVariantId = _selectedVariant?["id"]?.toString();
    if (selectedVariantId == null) {
      Get.snackbar("Error", "Please select a variant");
      return;
    }

    final success = await _cartController.addToCart(
      widget.id,
      _productController.quantity.value,
      selectedVariantId,
      context,
    );

    if (success) {
      _showSuccessSnackbar();
      _productController.quantity.value = 1;
    } else {
      Get.snackbar("Error", "Failed to add product");
    }
  }

  void _showSuccessSnackbar() {
    Get.snackbar(
      "Success",
      "Product added to cart",
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      icon: Icon(Icons.check_circle, color: Colors.white),
      mainButton: TextButton.icon(
        onPressed: () => Get.to(() => Cart()),
        icon: Icon(Icons.arrow_forward, color: Colors.white),
        label: Text(
          "Go to Cart",
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.green,
      colorText: Colors.white,
      borderRadius: 12.r,
      margin: EdgeInsets.all(16.w),
    );
  }

  Future<void> _buyNow() async {
    if (_isOutOfStock) {
      Get.snackbar("Out of Stock", "This product is currently out of stock");
      return;
    }

    final userId = await SharedPref.getUserId();
    if (userId == null) {
      Get.snackbar("Login Required", "Please login to buy product");
      return;
    }

    final selectedVariantId = _selectedVariant?["id"]?.toString();
    if (selectedVariantId == null) {
      Get.snackbar("Error", "Please select a variant");
      return;
    }

    final success = await _cartController.buyNow(
      widget.id,
      _productController.quantity.value,
      selectedVariantId,
      context,
    );

    if (success) {
      _productController.quantity.value = 1;
      Get.to(() => OrderSummary(orderList: _cartController.cartList));
    }
  }

  Widget _buildShimmerUI() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 80.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image shimmer
          Container(
            height: 320.h,
            color: Colors.grey.shade200,
          ),
          SizedBox(height: 24.h),

          // Content shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 32.h,
                  width: 200.w,
                  color: Colors.grey.shade200,
                ),
                SizedBox(height: 12.h),
                Container(
                  height: 20.h,
                  width: 150.w,
                  color: Colors.grey.shade200,
                ),
                SizedBox(height: 20.h),
                Container(
                  height: 40.h,
                  width: 120.w,
                  color: Colors.grey.shade200,
                ),
                SizedBox(height: 24.h),
                Container(
                  height: 120.h,
                  color: Colors.grey.shade200,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
