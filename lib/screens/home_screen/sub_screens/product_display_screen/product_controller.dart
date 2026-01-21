import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/product_display_screen/WishlistController.dart';
import 'package:organic_saga/shared_pref/shared_pref.dart';

class ProductController extends GetxController {
  final String? productId;

  ProductController({this.productId});

  // Reactive variables
  var isLoading = true.obs;
  var productDetails = <String, dynamic>{}.obs;
  var selectedVariantIndex = 0.obs;
  var quantity = 1.obs;
  var faqs = <dynamic>[].obs;
  var isFaqLoading = true.obs;
  var extraImages = <String>[].obs;

  PageController pageController = PageController();
  RxInt currentPage = 0.obs;
  Timer? _timer;

  WishlistController? wishlistController;

  @override
  void onInit() {
    super.onInit();

    // Reset quantity to 1 when controller is created
    resetQuantity();

    // Try to get WishlistController if it exists
    try {
      wishlistController = Get.find<WishlistController>();
    } catch (_) {
      // Ignore if not found
    }

    if (productId != null && productId!.isNotEmpty) {
      print("📌 ProductController initialized with productId: $productId");
      fetchProductDetails();
      fetchFaqs();
    } else {
      isLoading.value = false;
      isFaqLoading.value = false;
      print("⚠️ ProductController: productId is null or empty, skipping fetch");
    }
  }

  /// Reset quantity to 1 - call this when product changes
  void resetQuantity() {
    quantity.value = 1;
    print("🔄 Quantity reset to 1 for product: $productId");
  }

  /// Auto-scroll for image carousel
  void startAutoScroll(List<String> images) {
    _timer?.cancel();
    if (images.isEmpty) return;

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (pageController.hasClients) {
        int nextPage = (currentPage.value + 1) % images.length;
        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        currentPage.value = nextPage;
      }
    });
  }

  /// Fetch product details
  Future<void> fetchProductDetails() async {
    if (productId == null || productId!.isEmpty) return;

    isLoading.value = true;
    final apiUrl = "$baseUrl/Auth/product_details_fetch";
    print("🌐 Calling API: $apiUrl with product_id=$productId");

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {"product_id": productId},
      );

      print("📥 API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final details = data["product_details"] ?? {};
        productDetails.value = details;

        // Update images for the selected variant
        _updateImagesForVariant(selectedVariantIndex.value);
      } else {
        print("⚠️ ProductController: Failed to fetch product details, statusCode=${response.statusCode}");
      }
    } catch (e) {
      print("❌ ProductController: Error fetching product details - $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Update images when variant changes
  void _updateImagesForVariant(int variantIndex) {
    final variantList = productDetails["variant"] ?? [];
    if (variantList.isNotEmpty && variantIndex < variantList.length) {
      final images =
          (variantList[variantIndex]["extra_images"] ?? "").split(",");
      extraImages.value = images;
      if (images.isNotEmpty) startAutoScroll(images);
    } else {
      extraImages.clear();
    }
  }

  /// Change selected variant
  void selectVariant(int index) {
    selectedVariantIndex.value = index;
    _updateImagesForVariant(index);
  }

  /// Fetch FAQs
  Future<void> fetchFaqs() async {
    if (productId == null || productId!.isEmpty) return;

    isFaqLoading.value = true;
    final apiUrl = "$baseUrl/Auth/faqs_list_fetch";
    print("🌐 Calling API for FAQs: $apiUrl");

    try {
      final response = await http.get(Uri.parse(apiUrl));
      print("📥 FAQs API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        faqs.value = data["faqs_list"] ?? [];
      }
    } catch (e) {
      print("❌ ProductController: Error fetching FAQs - $e");
    } finally {
      isFaqLoading.value = false;
    }
  }

  /// Send a new FAQ
  Future<void> sendFaq(String question) async {
    final userId = await SharedPref.getUserId();
    if (userId == null) {
      Get.snackbar("Login Required", "Please login to send FAQ");
      return;
    }

    final name = "User"; // Replace with actual user info
    final apiUrl = "$baseUrl/Auth/faqs_save";
    print("🌐 Sending FAQ to: $apiUrl with question=$question");

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.fields.addAll({
        "name": name,
        "email": "",
        "mobile_no": "",
        "question": question,
        "product_id": productId ?? "",
      });

      var response = await request.send();
      var res = await response.stream.bytesToString();
      var data = jsonDecode(res);

      print("📥 FAQ API Response: $res");

      if (response.statusCode == 200 && data["status"] == 200) {
        Get.snackbar("Success", data["message"] ?? "Your question has been sent");
        fetchFaqs();
      } else {
        Get.snackbar("Error", "Failed to send FAQ");
      }
    } catch (e) {
      print("❌ ProductController: Error sending FAQ - $e");
      Get.snackbar("Error", "Failed to send FAQ");
    }
  }

  /// Quantity management
  void incrementQuantity() => quantity.value++;
  void decrementQuantity() {
    if (quantity.value > 1) quantity.value--;
  }

  /// Get product name for sharing
  String get productName {
    return productDetails['productname'] ?? 'Amazing Product';
  }

  /// Get product description for sharing
  String get productDescription {
    final description = productDetails["description"] ?? "";
    final withoutHtml = description.replaceAll(RegExp(r'<[^>]*>'), '');
    return withoutHtml.replaceAll(RegExp(r'\r|\n'), '').trim();
  }

  /// Generate shareable deep links
  Map<String, String> generateShareLinks() {
    return {
      'web_url': "https://sadiyaenterprises.in/product/$productId",
      'app_url': "organicsaga://product/$productId",
    };
  }

  /// Generate share message
  String generateShareMessage() {
    final links = generateShareLinks();
    final description = productDescription.isNotEmpty && productDescription.length > 100 
      ? productDescription.substring(0, 100) + '...' 
      : productDescription;

    return '''
🌟 Check out "$productName" on Organic Saga! 🌟

$description

🛒 Get it now: ${links['web_url']}
📱 Open in app: ${links['app_url']}

#OrganicSaga #HealthyLiving
    ''';
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }
}