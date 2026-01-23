import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/model/product_model.dart';

class ProductService {
  Future<List<Product>> fetchProductsByCategories(List<String> categoryIds) async {
    if (categoryIds.isEmpty) {
      print("⚠️ No category IDs provided");
      return [];
    }

    // Create form data as required by the API
    final Map<String, String> body = {};
    
    // Add each category ID as category_id[] (array format)
    for (int i = 0; i < categoryIds.length; i++) {
      body['category_id[$i]'] = categoryIds[i];
    }

    print("🟡 POST Request to: $productListByMultipleCategoryApi");
    print("🟡 Selected Categories: $categoryIds");
    print("🟡 Request Body: $body");

    try {
      final response = await http.post(
        Uri.parse(productListByMultipleCategoryApi),
        body: body,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      print("🔵 Response status: ${response.statusCode}");
      print("🔵 Response body length: ${response.body.length} chars");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Debug: Print the keys in response
        print("📋 Response keys: ${data.keys.toList()}");
        
        // Check the response structure
        if (data["status"] == 200 || data["status"] == "success" || data["status"] == true) {
          if (data["product_list"] != null) {
            final List<dynamic> productsJson = data["product_list"];
            
            print("✅ Found ${productsJson.length} products");
            
            // Debug: Print first product if available
            if (productsJson.isNotEmpty) {
              print("📦 First product: ${productsJson[0]}");
            }
            
            // Parse products
            final products = productsJson.map((json) {
              try {
                return Product.fromJson(json);
              } catch (e) {
                print("❌ Error parsing product: $e");
                print("❌ Problematic JSON: $json");
                return null;
              }
            }).where((product) => product != null).cast<Product>().toList();
            
            print("✅ Successfully parsed ${products.length} products");
            return products;
          } else {
            print("⚠️ product_list is null or empty");
            return [];
          }
        } else {
          print("⚠️ API returned error status: ${data["status"]}");
          print("⚠️ Message: ${data["message"] ?? 'No message'}");
          return [];
        }
      } else {
        print("❌ Server error: ${response.statusCode}");
        print("❌ Response body: ${response.body}");
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("❌ Network error: $e");
      print("❌ Stack trace: $stackTrace");
      throw Exception("Network error: $e");
    }
  }
}