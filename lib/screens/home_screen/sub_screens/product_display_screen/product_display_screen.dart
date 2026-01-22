import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
import 'package:cached_network_image/cached_network_image.dart';

String cleanText(String text) {
  final withoutHtml = text.replaceAll(RegExp(r'<[^>]*>'), '');
  return withoutHtml.replaceAll(RegExp(r'\r|\n'), '').trim();
}

class ProductDisplayScreen extends StatefulWidget {
  final String id;
  const ProductDisplayScreen({super.key, required this.id});

  @override
  State<ProductDisplayScreen> createState() => _ProductDisplayScreenState();
}

class _ProductDisplayScreenState extends State<ProductDisplayScreen> {
  final HomeController homeController = Get.find();
  final faqController = TextEditingController();
  late final WishlistController wishlistController;
  late final ProductController controller;

  // ✅ FIX: Get CartController without permanent registration
  CartController get cartController => Get.find<CartController>();

  var isLoading = true.obs;
  var productDetails = {}.obs;
  var selectedVariantIndex = 0.obs;
  var faqs = <dynamic>[].obs;
  var isFaqLoading = true.obs;
  var showDescription = true.obs;

  // ✅ FIX: Removed relatedProducts and isLoadingRelated to reduce memory
  PageController _pageController = PageController();
  var currentPage = 0.obs;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProductController(productId: widget.id));
    wishlistController = Get.find<WishlistController>();
    fetchProductDetails();
    fetchWishlistData();
    fetchFaqs();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    faqController.dispose();
    super.dispose();
  }

  void startAutoScroll(List<String> images) {
    _timer?.cancel();
    if (images.isEmpty) return;
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_pageController.hasClients) {
        int nextPage = (currentPage.value + 1) % images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        currentPage.value = nextPage;
      }
    });
  }

  Future<void> fetchProductDetails() async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/Auth/product_details_fetch"),
        body: {"product_id": widget.id},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final details = data["product_details"] ?? {};

        if (details["variant"] != null &&
            details["variant"] is List &&
            details["variant"].isNotEmpty) {
          final extraImages =
              (details["variant"][0]["extra_images"] ?? "").split(",");
          if (extraImages.isNotEmpty) startAutoScroll(extraImages);
        }

        productDetails.value = details;
      }
    } catch (e) {
      debugPrint("Error fetching product details: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWishlistData() async {
    final userId = await SharedPref.getUserId();
    if (userId != null) {
      await wishlistController.getWishlist(userId);
    }
  }

  Future<void> fetchFaqs() async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/Auth/faqs_list_fetch"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        faqs.value = data["faqs_list"] ?? [];
      }
    } catch (e) {
      debugPrint("Error fetching FAQs: $e");
    } finally {
      isFaqLoading.value = false;
    }
  }

  Future<void> sendFaq(String productId, String question) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/Auth/faqs_save'),
    );

    request.fields.addAll({
      "name": homeController.userModel.value.username ?? "",
      "email": homeController.userModel.value.email ?? "",
      "mobile_no": homeController.userModel.value.mobile ?? "",
      "question": question,
      "product_id": productId,
    });

    try {
      var response = await request.send();
      var res = await response.stream.bytesToString();
      var data = jsonDecode(res);

      if (response.statusCode == 200 && data["status"] == 200) {
        Get.snackbar(
            "Success", data["message"] ?? "Your question has been sent");
        fetchFaqs();
        faqController.clear();
      } else {
        Get.snackbar("Error", "Failed to send FAQ");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to send FAQ");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThemedAppBar(
        title: "Product Details",
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.r)),
                ),
                builder: (context) {
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.9,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: SearchBottomSheet(),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (isLoading.value) return _buildShimmerUI();

        final variantList = productDetails["variant"] ?? [];
        final selectedVariant = (variantList.isNotEmpty &&
                selectedVariantIndex.value < variantList.length)
            ? variantList[selectedVariantIndex.value]
            : null;

        final extraImages = selectedVariant?["extra_images"]?.split(",") ?? [];
        final price = double.tryParse(selectedVariant?["price"] ?? "0") ?? 0;
        final specialPrice =
            double.tryParse(selectedVariant?["special_price"] ?? "0") ?? 0;
        final unitPrice = (specialPrice > 0) ? specialPrice : price;
        final totalPrice = unitPrice * controller.quantity.value;

        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 15.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ FIX: Product name without unnecessary Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 4.w,
                      height: 24.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        productDetails['productname'] ?? '',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ FIX: Optimized Image Carousel
              _buildImageCarousel(extraImages),

              SizedBox(height: 16.h),

              // ✅ FIX: Price section with simple layout
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (specialPrice > 0) ...[
                          Text(
                            "$indianRupeeSymbol${specialPrice.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "Save ₹${(price - specialPrice).toStringAsFixed(0)}",
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ] else
                          Text(
                            "$indianRupeeSymbol${price.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "MRP: $indianRupeeSymbol${price.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),

              // ✅ FIX: Optimized Quantity Selector
              _buildQuantitySelector(controller),

              SizedBox(height: 10.h),

              // ✅ FIX: Tabs with efficient rendering
              _buildDescriptionFaqTabs(),

              SizedBox(height: 12.h),

              // ✅ FIX: Efficient Description/FAQ content
              Obx(() => showDescription.value
                  ? _buildDescriptionContent()
                  : _buildFaqContent()),

              SizedBox(height: 20.h),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  // ✅ FIX: Separated image carousel to its own method
  Widget _buildImageCarousel(List<String> extraImages) {
    return Column(
      children: [
        Stack(
          children: [
            if (extraImages.isNotEmpty)
              SizedBox(
                height: 260.h,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => currentPage.value = index,
                  itemCount: extraImages.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: CachedNetworkImage(
                          imageUrl: baseProductImageUrl + extraImages[index],
                          fit: BoxFit.contain,
                          width: double.infinity,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 1),
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.broken_image,
                            size: 40.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 260.h,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Text(
                    "No Image Available",
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ),

            // Wishlist Button
            Positioned(
              top: 16.h,
              right: 16.w,
              child: Obx(() {
                final isInWishlist = wishlistController.isInWishlist(widget.id);
                return Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.9),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: () async {
                        final userId = await SharedPref.getUserId();
                        if (userId == null) {
                          Get.snackbar("Login Required",
                              "Please login to manage wishlist");
                          return;
                        }
                        if (isInWishlist) {
                          final item =
                              wishlistController.favList.firstWhereOrNull(
                            (e) => e['product_id'].toString() == widget.id,
                          );
                          if (item != null) {
                            await wishlistController.removeFromWishlist(
                                item['wid'].toString(), userId);
                          }
                        } else {
                          await wishlistController.addToWishlist(
                              widget.id, userId);
                        }
                        await wishlistController.getWishlist(userId);
                      },
                      child: Center(
                        child: Icon(
                          isInWishlist ? Icons.favorite : Icons.favorite_border,
                          color: isInWishlist ? Colors.red : Colors.grey,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            // Dot Indicators
            if (extraImages.isNotEmpty)
              Positioned(
                bottom: 20.h,
                left: 0,
                right: 0,
                child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        extraImages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          margin: EdgeInsets.symmetric(horizontal: 3.w),
                          width: currentPage.value == index ? 24.w : 6.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            color: currentPage.value == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(3.r),
                            border: currentPage.value == index
                                ? Border.all(color: primaryColor, width: 1.w)
                                : null,
                          ),
                        ),
                      ),
                    )),
              ),
          ],
        ),
      ],
    );
  }

  // ✅ FIX: Separated quantity selector
  Widget _buildQuantitySelector(ProductController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Quantity",
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.r,
                        offset: Offset(0, 2.h),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove, size: 18.sp),
                        onPressed: () {
                          if (controller.quantity.value > 1) {
                            controller.quantity.value--;
                          }
                        },
                      ),
                      SizedBox(
                        width: 30.w,
                        child: Center(
                          child: Obx(
                            () => Text(
                              controller.quantity.value.toString(),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.add, size: 18.sp),
                        onPressed: () => controller.quantity.value++,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          // Total Price Display
          Obx(() {
            final variantList = productDetails["variant"] ?? [];
            final selectedVariant = (variantList.isNotEmpty &&
                    selectedVariantIndex.value < variantList.length)
                ? variantList[selectedVariantIndex.value]
                : null;
            final unitPrice =
                double.tryParse(selectedVariant?["special_price"] ?? "0") ?? 0;
            final totalPrice = unitPrice * controller.quantity.value;

            return Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(vertical: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shopping_cart_outlined,
                          color: Colors.grey[700], size: 18.sp),
                      SizedBox(width: 10.w),
                      Text(
                        "Total Price",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "$indianRupeeSymbol${totalPrice.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[900],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ✅ FIX: Separated tabs
  Widget _buildDescriptionFaqTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabButton("Description", true),
          SizedBox(width: 16.w),
          _buildTabButton("FAQs", false),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, bool isDescription) {
    return GestureDetector(
      onTap: () => showDescription.value = isDescription,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: showDescription.value == isDescription
                  ? Colors.green
                  : Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            height: 2.h,
            width: isDescription ? 100.w : 60.w,
            color: showDescription.value == isDescription
                ? Colors.green
                : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // ✅ FIX: Separated description content
  Widget _buildDescriptionContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade400, width: 1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          productDetails["description"] != null &&
                  productDetails["description"]!.isNotEmpty
              ? cleanText(productDetails["description"]!)
              : "No description available.",
          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
        ),
      ),
    );
  }

  // ✅ FIX: CRITICAL - Optimized FAQ content with efficient ListView
  Widget _buildFaqContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // FAQ Input
          TextField(
            controller: faqController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: "Ask a question...",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: Colors.green),
                onPressed: () {
                  final questionText = faqController.text.trim();
                  if (questionText.isEmpty) {
                    Get.snackbar("Error", "Please enter your question");
                    return;
                  }
                  sendFaq(widget.id, questionText);
                },
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // FAQ List - ✅ FIXED: Using ListView.builder with proper constraints
          Obx(() {
            if (isFaqLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (faqs.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  "No FAQs yet",
                  style: TextStyle(fontSize: 12.sp),
                ),
              );
            }

            // ✅ FIX: Limited height for FAQ list to prevent infinite rendering
            return SizedBox(
              height: 300.h, // Fixed height prevents infinite rendering
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  final faq = faqs[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Q: ${faq['question'] ?? ''}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "A: ${faq['answer']?.isNotEmpty == true ? faq['answer'] : 'No answer yet'}",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  // ✅ FIX: Separated bottom buttons
  Widget _buildBottomButtons() {
    return Obx(() {
      if (isLoading.value) return const SizedBox.shrink();

      return SafeArea(
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Row(
            children: [
              // Add to Cart button
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 55.h,
                  child: Obx(() {
                    return ElevatedButton.icon(
                      icon: cartController.isAddToCartLoading.value
                          ? SizedBox(
                              width: 20.sp,
                              height: 20.sp,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.shopping_cart,
                              size: 20.sp,
                              color: Colors.white,
                            ),
                      onPressed: cartController.isAddToCartLoading.value
                          ? null
                          : () async {
                              final userId = await SharedPref.getUserId();
                              if (userId == null) {
                                Get.snackbar("Login Required",
                                    "Please login to add product to cart");
                                return;
                              }

                              final selectedVariantId =
                                  productDetails["variant"]
                                          [selectedVariantIndex.value]["id"]
                                      .toString();

                              final success = await cartController.addToCart(
                                widget.id,
                                controller.quantity.value,
                                selectedVariantId,
                                context,
                              );

                              if (success) {
                                Get.snackbar(
                                  "Success",
                                  "Product added to cart",
                                  snackPosition: SnackPosition.BOTTOM,
                                  duration: const Duration(seconds: 3),
                                  icon: const Icon(
                                    Icons.shopping_cart,
                                    color: Colors.white,
                                  ),
                                  mainButton: TextButton.icon(
                                    onPressed: () {
                                      Get.to(() => Cart()); // navigate to cart
                                    },
                                    icon: const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "Go to Cart",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );

                                // Get.snackbar(
                                //     "Success", "Product added to cart");
                                controller.quantity.value = 1;
                              } else {
                                Get.snackbar("Error", "Failed to add product");
                              }
                            },
                      label: Text(
                        "Add to Cart",
                        style: TextStyle(fontSize: 14.sp, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(width: 8.w),
              // Buy Now button
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 55.h,
                  child: Obx(() {
                    return ElevatedButton.icon(
                      icon: cartController.isBuyNowLoading.value
                          ? SizedBox(
                              width: 18.sp,
                              height: 18.sp,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Icon(
                              Icons.flash_on,
                              size: 18.sp,
                              color: Colors.white,
                            ),
                      onPressed: cartController.isBuyNowLoading.value
                          ? null
                          : () async {
                              final userId = await SharedPref.getUserId();
                              if (userId == null) {
                                Get.snackbar("Login Required",
                                    "Please login to buy product");
                                return;
                              }

                              final selectedVariantId =
                                  productDetails["variant"]
                                          [selectedVariantIndex.value]["id"]
                                      .toString();

                              final success = await cartController.buyNow(
                                widget.id,
                                controller.quantity.value,
                                selectedVariantId,
                                context,
                              );

                              if (success) {
                                controller.quantity.value = 1;
                                Get.to(() => OrderSummary(
                                    orderList: cartController.cartList));
                              }
                            },
                      label: Text(
                        "Buy Now",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ✅ FIX: Optimized Shimmer UI
  Widget _buildShimmerUI() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 80.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  width: 4.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Container(
                    height: 20.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Image placeholder
          Container(
            height: 260.h,
            margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),

          SizedBox(height: 16.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 24.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  height: 18.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 24.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                Container(
                  height: 24.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
