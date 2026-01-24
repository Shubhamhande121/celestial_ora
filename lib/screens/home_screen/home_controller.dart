import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/model/user_model.dart';
import 'package:organic_saga/shared_pref/shared_pref.dart';
import 'dart:io';
import 'package:path/path.dart';

class HomeController extends GetxController {
  var count = 0.obs;
  var isLoading = false.obs;
  var userModel = UserModel().obs;
  var currentIndex = 0.obs;
  var location = "";

  var bestSellerList = <dynamic>[].obs;
  var trendingList = <dynamic>[].obs;

  /// ✅ Category state
  final selectedCategoryIndex = 0.obs;
  var isLoadingCategories = false.obs;
  var categoriesList = <dynamic>[].obs;
  var baseCategoriesList = <dynamic>[].obs;
  var categoryWiseProductMap = <String, List<dynamic>>{}.obs;
  var selectedCategoryId = ''.obs;
  var selectedCategoryProducts = <dynamic>[].obs;
  var isLoadingCategoryProducts = false.obs;

  // ✅ NEW: Pagination for products
  var currentProductPage = 1.obs;
  var hasMoreProducts = true.obs;
  var isLoadingMoreProducts = false.obs;

  void increment() => count++;

  // 🔹 Store products per category
  final Map<String, List<dynamic>> categoryProducts = {};

  // 🔹 Pagination state per category

  final Map<String, bool> _hasMore = {};

  // 🔹 UI state

  final products = <dynamic>[].obs;

  final isInitialLoading = false.obs;
  final isLoadingMore = false.obs;

  static const int limit = 20;

  int currentPage = 1;
  bool hasMore = true;

  // ✅ Fetch user profile data
  Future<void> fetchUser() async {
    var userId = await SharedPref.getUserId();
    log(">>>User Id $userId");
    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Auth/profile_fetch'),
        body: {"users_id": userId.toString()},
      );

      if (response.statusCode == 200) {
        final jsonBody = json.decode(response.body);
        if (jsonBody["profile_details"] != null) {
          userModel.value = UserModel.fromJson(jsonBody["profile_details"]);
          userModel.refresh();
          log("✅ User Loaded: ${userModel.value.username}");
        }
      }
    } catch (e) {
      log("Exception in fetchUser: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Fetch trending products WITH LIMIT
  Future<void> fetchTrendingProducts({int limit = 20}) async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('$baseUrl/Auth/trending_product?limit=$limit'), // ✅ ADD LIMIT
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 200 && data.containsKey('trending_list')) {
          trendingList.value = data['trending_list'];
          log("✅ Trending Products Loaded: ${trendingList.length}");
        }
      }
    } catch (e) {
      debugPrint("Exception in fetchTrendingProducts: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Fetch slider banners
  Future<void> getBannerApi() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse('$baseUrl/Auth/slider_fetch'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data.containsKey('slider')) {
          bestSellerList.value = data['slider'];
          log("✅ Slider data loaded: ${bestSellerList.length}");
        }
      }
    } catch (e) {
      debugPrint("Exception in getBannerApi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// ✅ Fetch categories WITHOUT loading all products
  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;

      final response = await http.get(Uri.parse(categoryListApi));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == 200 && data.containsKey('category_list')) {
          final list = data['category_list'] as List;
          categoriesList.value = list;
          baseCategoriesList.value = list;

          // ✅ FIX: DON'T load products for all categories initially
          // Only load when user taps on a category
          log("✅ Categories loaded: ${list.length}");
        }
      }
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // ================= FETCH =================

  Future<void> fetchProducts(String categoryId, {bool loadMore = false}) async {
    final page = loadMore ? currentPage + 1 : 1;

    final response = await http.post(
      Uri.parse(productListByCategoryApi),
      body: {
        "category_id": categoryId,
        "page": page.toString(),
        "limit": "20",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newProducts = data['product_list'] ?? [];

      if (page == 1) {
        products.value = newProducts;
      } else {
        products.addAll(newProducts);
      }

      hasMore = newProducts.length == 20;
      currentPage = page;
    }

    isLoading.value = false;
  }

  // ================= CACHE HIT =================
  void switchCategory(String categoryId) {
    selectedCategoryId.value = categoryId;

    if (categoryProducts.containsKey(categoryId)) {
      products.value = categoryProducts[categoryId]!;
    } else {
      fetchProducts(categoryId);
    }
  }

  bool get hasMoreCurrentCategory => _hasMore[selectedCategoryId.value] ?? true;

  /// ✅ Load more products for category
  Future<void> loadMoreProducts(String categoryId) async {
    if (isLoadingMoreProducts.value || !hasMoreProducts.value) return;

    await fetchProducts(categoryId);
  }

  void changeCategory(String categoryId) {
    products.clear(); // instant UI clear
    currentPage = 1;
    isLoading.value = true;
    hasMore = true;
    fetchProducts(categoryId);
  }

  Future<void> uploadProfileImage(File imageFile) async {
    final uid = await SharedPref.getUserId();
    var request = http.MultipartRequest("POST", Uri.parse(profileUpdateApi));

    request.fields['users_id'] = uid.toString();
    request.fields['username'] = userModel.value.username ?? "";
    request.fields['email'] = userModel.value.email ?? "";

    request.files.add(await http.MultipartFile.fromPath(
      'profile_image',
      imageFile.path,
      filename: basename(imageFile.path),
    ));

    log(">>> Uploading profile for $uid");

    var response = await request.send();

    if (response.statusCode == 200) {
      log("✅ Upload Success");
      await fetchUser();
    } else {
      log("❌ Upload Failed");
    }
  }

  /// ✅ OnInit Lifecycle - OPTIMIZED
  @override
  void onInit() {
    super.onInit();
    // Load user and basic data first
    fetchUser();
    getBannerApi();

    // Load trending with limit
    fetchTrendingProducts(limit: 20);

    // Load categories without products
    fetchCategories();
  }

  /// (Optional) FCM Token
  setToken() async {
    // Add Firebase token logic if needed
  }
}
