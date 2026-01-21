import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:organic_saga/services/category_service.dart';
import 'package:organic_saga/model/category_model.dart';

/// Provides list of categories from the API
final categoryProvider =
    FutureProvider.autoDispose<List<Category>>((ref) async {
  try {
    final categories = await CategoryService().fetchCategories();

    if (categories.isEmpty) {
      return [];
    }
    return categories;
  } catch (e) {
 
    return [];
  }
});
