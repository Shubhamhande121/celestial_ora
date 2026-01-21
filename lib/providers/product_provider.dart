import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:organic_saga/model/product_model.dart';
import 'package:organic_saga/services/product_service.dart';

final selectedCategoryProvider = StateProvider<List<String>>((ref) => []);

final productProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  final selectedCategories = ref.watch(selectedCategoryProvider);
  return ProductService().fetchProductsByCategories(selectedCategories);
});
