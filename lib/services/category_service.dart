import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/model/category_model.dart';

class CategoryService {
  Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse(categoryListApi), // Use the constant from base_url.dart
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List list = data['category_list'];
      return list.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }
}
