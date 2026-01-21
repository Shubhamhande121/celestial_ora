import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/constants/baseUrl.dart';

class WishlistController extends GetxController {
  var favList = [].obs;
  var wishlistCount = 0.obs;

  Future<void> getWishlist(String userId) async {
    try {
      final response = await http.post(Uri.parse(getWishlistApi), body: {
        "uid": userId,
      });

      final data = json.decode(response.body);
      if (data['status'] == 200 && data.containsKey('wishlist')) {
        favList.value = data['wishlist'];
        wishlistCount.value = favList.length;
      } else {
        favList.clear();
        wishlistCount.value = 0;
      }
    } catch (e) {
      print("Error fetching wishlist: $e");
      favList.clear();
      wishlistCount.value = 0;
    }
  }

  bool isInWishlist(String productId) {
    return favList.any((item) => item['product_id'].toString() == productId);
  }

  Future<bool> addToWishlist(String productId, String userId) async {
    try {
      final response = await http.post(Uri.parse(addWishlistApi), body: {
        "product_id": productId,
        "uid": userId,
      });

      final data = json.decode(response.body);
      if (data['status'] == 200) {
        // instantly add locally (optimistic update)
        favList.add({
          "product_id": productId,
          "wid": data["wishlist_id"] ?? "",
        });
        wishlistCount.value = favList.length;
        return true;
      }
    } catch (e) {
      print("Add to wishlist error: $e");
    }
    return false;
  }

  Future<bool> removeFromWishlist(String wishlistId, String userId) async {
    try {
      final response = await http.post(Uri.parse(removeWishlistApi), body: {
        "wishlist_id": wishlistId,
        "uid": userId,
      });

      final data = json.decode(response.body);
      if (data['status'] == 200) {
        favList.removeWhere((item) => item['wid'].toString() == wishlistId);
        wishlistCount.value = favList.length;
        return true;
      }
    } catch (e) {
      print("Remove from wishlist error: $e");
    }
    return false;
  }
}
