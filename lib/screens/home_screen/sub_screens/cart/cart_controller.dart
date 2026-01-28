import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/screens/home_screen/home_controller.dart';
import 'package:organic_saga/shared_pref/shared_pref.dart';

class CartController extends GetxController {
  // Loading states
  var isAddToCartLoading = false.obs;
  var isBuyNowLoading = false.obs;
  var isRemovingFromCart = false.obs;

  // Cart & wishlist data
  var cartList = <dynamic>[].obs;
  var cartItemCount = 0.obs;
  var cartTotalPrice = 0.0.obs;
  var isCartCount = 0.obs;

  final RxList<dynamic> favList = <dynamic>[].obs;
  var wishlistCount = 0.obs;

  var selectedAddress = <String, dynamic>{}.obs;
  var selectedPromoCode = <String, dynamic>{}.obs;
  var isChecked = false.obs;

  // UPDATED: Simple reactive local cart state for immediate UI updates
  var localCartItems = <String, int>{}.obs;

  /// UPDATED: Check if product is in cart (reactive)
  bool isInCart(String productId, String variantId) {
    final key = '$productId-$variantId';
    return localCartItems.containsKey(key) && localCartItems[key]! > 0;
  }

  /// UPDATED: Get quantity for product (reactive)
  int getQuantity(String productId, String variantId) {
    final key = '$productId-$variantId';
    return localCartItems[key] ?? 0;
  }

  /// NEW: Add to cart with immediate reactive update
  void addToCartReactive(
      String productId, int qty, String variantId, BuildContext context) async {
    final key = '$productId-$variantId';
    final currentQuantity = localCartItems[key] ?? 0;
    final newQuantity = currentQuantity + qty;

    // Immediate UI update
    localCartItems[key] = newQuantity;

    // Update cart count
    updateCartCountOptimistically();

    // Sync with server in background
    _syncWithServerCart(productId, newQuantity, variantId);

    // Show success message
    // Get.snackbar(
    //   "Success",
    //   "Product added to cart",
    //   backgroundColor: Colors.green.shade100,
    //   colorText: Colors.black,
    //   snackPosition: SnackPosition.BOTTOM,
    //   duration: const Duration(seconds: 1),
    // );
  }

  /// UPDATED: Update quantity with immediate reactive update
  /// UPDATED: Update quantity with proper removal handling
  void updateQuantity(
      String productId, String variantId, int newQuantity) async {
    final key = '$productId-$variantId';

    if (newQuantity <= 0) {
      // Remove from local state
      localCartItems.remove(key);

      // Find and remove from server cart
      final existingItem = cartList.firstWhereOrNull(
        (item) =>
            item['product_id']?.toString() == productId &&
            item['pv_id']?.toString() == variantId,
      );

      if (existingItem != null) {
        // Remove from server cart
        removeFromCart(existingItem['cart_id'].toString());
      }
    } else {
      localCartItems[key] = newQuantity;
      // Update server cart
      await _syncWithServerCart(productId, newQuantity, variantId);
    }

    // Update counts and totals
    updateCartCountOptimistically();

    // Update total price
    cartTotalPrice.value = getCartTotalPrice();
  }

  /// NEW: Remove product from local cart (for when removing from cart/order summary)
  void removeFromLocalCart(String productId, String variantId) {
    final key = '$productId-$variantId';
    localCartItems.remove(key);
    updateCartCountOptimistically();
  }

  /// NEW: Remove all products from local cart
  void clearLocalCart() {
    localCartItems.clear();
    updateCartCountOptimistically();
  }

  /// UPDATED: Sync with server (background process)
  Future<void> _syncWithServerCart(
      String productId, int qty, String variantId) async {
    try {
      final userId = await SharedPref.getUserId();
      if (userId == null) return;

      // Check if item exists in server cart
      final existingCartItem = cartList.firstWhereOrNull((item) =>
          item['product_id']?.toString() == productId &&
          item['pv_id']?.toString() == variantId);

      String apiEndpoint;
      Map<String, String> fields;

      if (existingCartItem != null) {
        // Update existing item
        apiEndpoint = '$baseUrl/Auth/update_cart';
        fields = {
          'cart_id': existingCartItem['cart_id'].toString(),
          'qty': qty.toString(),
          'user_id': userId,
          'product_id': productId,
          'variant': variantId,
        };
      } else {
        // Add new item
        apiEndpoint = '$baseUrl/Auth/add_to_cart';
        fields = {
          'product_id': productId,
          'user_id': userId,
          'qty': qty.toString(),
          'variant': variantId,
        };
      }

      var request = http.MultipartRequest('POST', Uri.parse(apiEndpoint));
      request.fields.addAll(fields);

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(resBody);
        if (responseData["status"] == 200) {
          // Refresh cart from server to ensure consistency
          //   await getCart();
        }
      }
    } catch (e) {
      log("Sync with server error: $e");
      // Even if sync fails, keep local state for better UX
    }
  }

  /// NEW: Refresh cart with retry logic
  Future<void> refreshCartWithRetry({int maxRetries = 2}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        log("🔄 Attempting to refresh cart (attempt $attempt/$maxRetries)");
        await getCart();
        break; // Success, exit loop
      } catch (e) {
        log("❌ Cart refresh attempt $attempt failed: $e");
        if (attempt == maxRetries) {
          log("❌ All cart refresh attempts failed");
          // Optionally show error to user
          Get.snackbar(
            "Warning",
            "Unable to sync cart with server",
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          );
        }
        await Future.delayed(const Duration(seconds: 1)); // Wait before retry
      }
    }
  }

  /// UPDATED: Remove from server cart
  Future<void> _removeFromServerCart(String productId, String variantId) async {
    try {
      final existingCartItem = cartList.firstWhereOrNull((item) =>
          item['product_id']?.toString() == productId &&
          item['pv_id']?.toString() == variantId);

      if (existingCartItem != null) {
        await removeFromCart(existingCartItem['cart_id'].toString());
      }
    } catch (e) {
      log("Remove from server cart error: $e");
    }
  }

  void updateCartCountOptimistically() {
    // Use localCartItems as the single source of truth
    int count = 0;

    // Count items with quantity > 0
    for (final quantity in localCartItems.values) {
      if (quantity > 0) {
        count++;
      }
    }

    // Also count items in cartList that might not be in localCartItems
    for (final item in cartList) {
      final productId = item['product_id']?.toString();
      final variantId = item['pv_id']?.toString();
      if (productId != null && variantId != null) {
        final key = '$productId-$variantId';
        if (!localCartItems.containsKey(key) || localCartItems[key] == 0) {
          count++;
        }
      }
    }

    cartItemCount.value = count;
    isCartCount.value = count;

    log("🛒 Cart count updated: $count items");
  }

  /// UPDATED: Add product to cart (original method - keep for compatibility)
  Future<bool> addToCart(
      String productId, int qty, String variantId, BuildContext context) async {
    try {
      isAddToCartLoading.value = true;

      final userId = await SharedPref.getUserId();
      if (userId == null) {
        Get.snackbar("Login Required", "Please login to add product to cart");
        return false;
      }

      // Use reactive update for immediate UI response
      addToCartReactive(productId, qty, variantId, context);
      return true;
    } catch (e) {
      log("Exception in addToCart: $e");
      Get.snackbar(
        "Error",
        "Failed to update cart: ${e.toString()}",
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return false;
    } finally {
      isAddToCartLoading.value = false;
    }
  }

  /// Buy Now (separate from Add to Cart)
  Future<bool> buyNow(
      String productId, int qty, String variantId, BuildContext context) async {
    try {
      isBuyNowLoading.value = true;

      final userId = await SharedPref.getUserId();
      if (userId == null) {
        Get.snackbar("Login Required", "Please login to buy product");
        return false;
      }

      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/Auth/add_to_cart'));
      request.fields.addAll({
        'product_id': productId,
        'user_id': userId,
        'qty': qty.toString(),
        'variant': variantId,
      });

      http.StreamedResponse response = await request.send();
      final resBody = await response.stream.bytesToString();
      log("Buy Now response: $resBody");

      if (response.statusCode == 200) {
        await getCart();
        return true;
      } else {
        Get.snackbar(
          "Error",
          "Could not proceed with purchase",
          backgroundColor: Colors.red.shade100,
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      log("Buy Now Exception: $e");
      Get.snackbar(
        "Error",
        "Something went wrong",
        backgroundColor: Colors.red.shade100,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isBuyNowLoading.value = false;
    }
  }

  /// Get cart item count directly from local state (most accurate)
  int getAccurateCartCount() {
    int count = 0;
    for (final quantity in localCartItems.values) {
      if (quantity > 0) {
        count++;
      }
    }
    return count;
  }

  /// Get cart total from local state
  double getCartTotalPrice() {
    double total = 0.0;

    // We need to calculate total based on both local and server data
    for (final entry in localCartItems.entries) {
      if (entry.value > 0) {
        // Find the product in cartList to get price
        final parts = entry.key.split('-');
        if (parts.length == 2) {
          final productId = parts[0];
          final variantId = parts[1];

          final product = cartList.firstWhereOrNull(
            (item) =>
                item['product_id']?.toString() == productId &&
                item['pv_id']?.toString() == variantId,
          );

          if (product != null) {
            final price =
                double.tryParse(product["special_price"]?.toString() ?? "0") ??
                    0.0;
            total += price * entry.value;
          }
        }
      }
    }

    return total;
  }

  /// Update cart quantity
  Future<bool> updateCart(
      String productId, int qty, String variantId, String cartId) async {
    try {
      final userId = await SharedPref.getUserId();
      if (userId == null) return false;

      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/Auth/update_cart'));
      request.fields.addAll({
        'product_id': productId,
        'user_id': userId,
        'qty': qty.toString(),
        'variant': variantId,
        'cart_id': cartId,
      });

      http.StreamedResponse response = await request.send();
      final resBody = await response.stream.bytesToString();
      log("Update Cart Response: $resBody");

      if (response.statusCode == 200) {
        recalculateTotal();
        return true;
      } else {
        log("Update Cart Failed: ${response.reasonPhrase}");
        return false;
      }
    } catch (e) {
      log("Update Cart Exception: $e");
      return false;
    }
  }

  /// UPDATED: Remove item from cart - SIMPLIFIED VERSION
  Future<bool> removeFromCart(String cartId) async {
    try {
      isRemovingFromCart.value = true;

      // 1. REMOVE FROM LOCAL STATE IMMEDIATELY
      // Find and remember the item BEFORE removing
      final itemToRemove =
          cartList.firstWhereOrNull((item) => item['cart_id'] == cartId);

      if (itemToRemove != null) {
        final productId = itemToRemove['product_id']?.toString();
        final variantId = itemToRemove['pv_id']?.toString();

        // Remove from localCartItems immediately
        if (productId != null && variantId != null) {
          final key = '$productId-$variantId';
          localCartItems.remove(key);
        }

        // Remove from cartList immediately
        cartList.removeWhere((item) => item['cart_id'] == cartId);

        // Update counts IMMEDIATELY
        cartItemCount.value = cartList.length;
        isCartCount.value = cartList.length;

        // Recalculate total IMMEDIATELY
        recalculateTotal();
      }

      // 2. Try to remove from server (background process)
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/Auth/remove_cart'));
      request.fields.addAll({'cart_id': cartId});

      http.StreamedResponse response = await request.send();
      final resBody = await response.stream.bytesToString();
      log("Remove from cart response: $resBody");

      if (response.statusCode == 200) {
        log("✅ Item removed successfully from server");
        return true;
      } else {
        log("⚠️ Server remove failed, but item removed from local state");
        // Item is already removed from local state, so UI updates immediately
        return false;
      }
    } catch (e) {
      log("❌ Remove from cart exception: $e");
      // Even if exception occurs, item is already removed from local state
      return false;
    } finally {
      isRemovingFromCart.value = false;
    }
  }

  /// DEBUG: Print current cart state
// void debugCartState() {
//   log("🛒 DEBUG CART STATE:");
//   log("  - cartList length: ${cartList.length}");
//   log("  - localCartItems: ${localCartItems.length} items");
//   log("  - cartItemCount: $cartItemCount");
//   log("  - localCartItems details: $localCartItems");
//   log("  - cartTotalPrice: $cartTotalPrice");
// }

  /// EMERGENCY: Force reset cart state
  void forceResetCart() {
    cartList.clear();
    localCartItems.clear();
    cartItemCount.value = 0;
    isCartCount.value = 0;
    cartTotalPrice.value = 0.0;
    log("🛒 Cart force reset completed");
  }

  /// FIXED: Get accurate cart item count
// int getAccurateCartCount() {
//   int count = 0;
//   for (final quantity in localCartItems.values) {
//     if (quantity > 0) {
//       count++;
//     }
//   }
//   return count;
// }
  /// UPDATED: Fetch cart data - also sync local cart
  /// UPDATED: Fetch cart data - with error handling for HTTP 500
  Future<void> getCart() async {
    try {
      final userId = await SharedPref.getUserId();
      if (userId == null) {
        log("❌ User ID is null - cannot fetch cart");
        return;
      }

      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/Auth/get_cart_list'));
      request.fields.addAll({'uid': userId});

      http.StreamedResponse response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        if (data["status"] == 200) {
          final cartData = data["cart_list"] as List? ?? [];
          cartList.value = cartData;

          // Sync local cart items with server data
          _syncLocalWithServerCart(cartData);

          cartItemCount.value = cartData.length;
          isCartCount.value = cartData.length;

          recalculateTotal();
          log("✅ Cart synced successfully: ${cartData.length} items");
        } else {
          log("⚠️ Server returned error status: ${data["status"]} - ${data["message"]}");
          // Don't throw exception, just log
        }
      } else {
        log("❌ HTTP ${response.statusCode} when fetching cart - Body: $body");
        // If server returns error, keep existing cart data
        // Don't clear cart on server error
        throw Exception("HTTP ${response.statusCode} - Server error");
      }
    } catch (e) {
      log("⚠️ Get Cart Exception: $e");
      // Don't clear cart on exception - keep existing data
      // Just log the error
    }
  }

  /// Clean up local cart by removing items with zero quantity
  void cleanupLocalCart() {
    localCartItems.removeWhere((key, quantity) => quantity <= 0);
    updateCartCountOptimistically();
    cartTotalPrice.value = getCartTotalPrice();
  }

  /// FIXED: Sync local cart with server data
  void _syncLocalWithServerCart(List<dynamic> serverCart) {
    log("🔄 Syncing local cart with server cart: ${serverCart.length} items");

    // Clear local items first
    localCartItems.clear();

    // Add server items to local state
    for (final item in serverCart) {
      final productId = item['product_id']?.toString();
      final variantId = item['pv_id']?.toString();
      final serverQty = int.tryParse(item['cart_qty']?.toString() ?? '1') ?? 1;

      if (productId != null && variantId != null && serverQty > 0) {
        final key = '$productId-$variantId';
        localCartItems[key] = serverQty;
      }
    }

    // Update counts
    cartItemCount.value = localCartItems.length;
    isCartCount.value = localCartItems.length;

    // Update total price
    cartTotalPrice.value = getCartTotalPrice();
  }

  /// Fetch wishlist data
  Future<void> getWishList() async {
    try {
      final homeController = Get.find<HomeController>();
      final userId = homeController.userModel.value.id ?? "";
      if (userId.isEmpty) return;

      var request = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/Auth/get_wishlist'));
      request.fields.addAll({'uid': userId});

      http.StreamedResponse response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(resBody);
        favList.value = data["wishlist"] as List? ?? [];
        wishlistCount.value = favList.length;
        log("Wishlist fetched: ${favList.length} items");
      } else {
        favList.clear();
        wishlistCount.value = 0;
      }
    } catch (e) {
      log("Get Wishlist Exception: $e");
      favList.clear();
      wishlistCount.value = 0;
    }
  }

  /// Recalculate total price
  void recalculateTotal() {
    double total = 0.0;
    for (var item in cartList) {
      final price = double.tryParse(item["special_price"] ?? "0") ?? 0.0;
      final qty = int.tryParse(item["cart_qty"] ?? "1") ?? 1;
      total += price * qty;
    }
    cartTotalPrice.value = total;
  }

  @override
  void onInit() {
    super.onInit();
    getCart();
    getWishList();
  }

  /// UPDATED: Clear cart - also clear local cart
  void clearCart() {
    cartList.clear();
    cartItemCount.value = 0;
    isCartCount.value = 0;
    cartTotalPrice.value = 0.0;
    localCartItems.clear();
  }
}
