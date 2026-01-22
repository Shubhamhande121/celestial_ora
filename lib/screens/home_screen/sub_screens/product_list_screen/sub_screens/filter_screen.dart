import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/model/product_model.dart';
import 'package:organic_saga/providers/category_provider.dart';
import 'package:organic_saga/providers/list_of_selected_filters.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/product_display_screen/product_display_screen.dart';
import 'package:organic_saga/model/category_model.dart';
import 'package:organic_saga/services/product_service.dart';

/// Keeps track of selected categories
final listOfSelectedCategoriesProvider =
    ChangeNotifierProvider.autoDispose<ListOfSelectedFilters>(
  (ref) => ListOfSelectedFilters(),
);

/// Provides products filtered by selected category IDs
final filteredProductsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) async {
  final selectedCategoryIds =
      ref.watch(listOfSelectedCategoriesProvider).selectedCategoryIds;

  if (selectedCategoryIds.isEmpty) return [];

  try {
    final products =
        await ProductService().fetchProductsByCategories(selectedCategoryIds);
    return products;
  } catch (_) {
    return [];
  }
});

class FilterScreen extends ConsumerWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoryProvider);
    final selectedCategories = ref.watch(listOfSelectedCategoriesProvider);
    final productsAsync = ref.watch(filteredProductsProvider);
    final screenWidth = MediaQuery.of(context).size.width;

// 🔥 Ensure selected category IDs are valid only if categories are loaded
    categoryAsync.whenData((categories) {
      final validIds = categories.map((c) => c.id).toSet();
      final notifier = ref.read(listOfSelectedCategoriesProvider);
      notifier.selectedCategoryIds
          .where((id) => !validIds.contains(id))
          .toList()
          .forEach(notifier.removeItem);
    });

    return Scaffold(
      appBar: ThemedAppBar(
        title: "Filters",
        showBack: true,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Container(
        width: double.infinity,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Categories", screenWidth),
              const SizedBox(height: 10),
              categoryAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Center(
                      child: Text(
                        "No categories available.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: categories.map((Category category) {
                      final isSelected = selectedCategories.selectedCategoryIds
                          .contains(category.id);
                      return FilterChip(
                        label: Text(
                          category.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF53B175),
                        backgroundColor: Colors.grey[200],
                        checkmarkColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF53B175)
                                : Colors.grey.shade400,
                          ),
                        ),
                        onSelected: (selected) {
                          final notifier =
                              ref.read(listOfSelectedCategoriesProvider);
                          if (isSelected) {
                            notifier.removeItem(category.id);
                          } else {
                            notifier.addItem(category.id);
                          }
                        },
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text("Error: $error")),
              ),

              SizedBox(height: 30.h),
              _buildSectionTitle("Products", screenWidth),
              SizedBox(height: 10.h),

              /// Products section
              productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(
                      child: Text(
                        "No products found.",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              "$baseProductImageUrl${product.productimage}",
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, _) =>
                                  const Icon(Icons.broken_image),
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                            ),
                          ),
                          subtitle: Text(
                            product.catname,
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, size: 15.sp),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDisplayScreen(id: product.id),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Center(
                  child: Text(
                    "No products found.",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double screenWidth) {
    return Text(
      title,
      style: TextStyle(
        color: const Color(0xFF181725),
        fontSize: screenWidth / 25,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
