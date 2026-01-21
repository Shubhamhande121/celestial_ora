// services/product_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/model/product_model.dart';

class ProductService {
  Future<List<Product>> fetchProductsByCategories(List<String> categoryIds) async {
    final url = Uri.parse('$baseUrl$productListByMultipleCategoryApi');

    
    // Build array-style body
    final Map<String, String> body = {};
    for (int i = 0; i < categoryIds.length; i++) {
      body["category_id[$i]"] = categoryIds[i];
    }

    final response = await http.post(url, body: body);

    print("🔵 Response status: ${response.statusCode}");
    print("🔵 Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data["status"] == 200 && data["product_list"] != null) {
        final List<dynamic> productsJson = data["product_list"];
        return productsJson.map((e) => Product.fromJson(e)).toList();
      } else {
        print("⚠️ API returned no products or invalid structure.");
        return [];
      }
    } else {
      throw Exception("Failed to load products (Status ${response.statusCode})");
    }
  }
}
