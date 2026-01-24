import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

class FilterScreen extends ConsumerStatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends ConsumerState<FilterScreen> {
  @override
  void initState() {
    super.initState();
    // Pre-fetch categories when screen loads
    Future.delayed(Duration.zero, () {
      ref.read(categoryProvider.future);
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryAsync = ref.watch(categoryProvider);
    final selectedCategories = ref.watch(listOfSelectedCategoriesProvider);
    final productsAsync = ref.watch(filteredProductsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: ThemedAppBar(
        title: "Filters",
        showBack: true,
        onBack: () => Navigator.of(context).pop(),
        actions: selectedCategories.selectedCategoryIds.isNotEmpty
            ? [
                TextButton(
                  onPressed: () {
                    ref.read(listOfSelectedCategoriesProvider).clearItems();
                  },
                  child: Text(
                    "Clear All",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: Container(
        width: double.infinity,
        height: screenHeight,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 20.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categories Section
              _buildSectionTitle("Categories", screenWidth),
              SizedBox(height: 16.h),

              categoryAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return _buildEmptyState("No categories available");
                  }
                  return _buildCategoryChips(
                    categories,
                    selectedCategories.selectedCategoryIds,
                    ref,
                  );
                },
                loading: () => _buildLoadingIndicator(),
                error: (error, _) =>
                    _buildErrorState("Failed to load categories"),
              ),

              SizedBox(height: 30.h),

              // Products Section
              if (selectedCategories.selectedCategoryIds.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle("Products", screenWidth),
                    if (productsAsync.value?.isNotEmpty == true)
                      Text(
                        "${productsAsync.value?.length ?? 0} items",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16.h),
                productsAsync.when(
                  data: (products) {
                    if (products.isEmpty) {
                      return _buildEmptyState(
                          "No products found for selected categories");
                    }
                    return _buildProductGrid(products, screenWidth);
                  },
                  loading: () => _buildLoadingIndicator(),
                  error: (e, _) => _buildErrorState("Failed to load products"),
                ),
              ] else ...[
                // Empty State
                Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.1),
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    children: [
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFF53B175).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.filter_alt_outlined,
                          size: 60.w,
                          color: const Color(0xFF53B175),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        "Select Categories",
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF181725),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Choose categories from above to see matching products",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 32.h),
                      Container(
                        width: double.infinity,
                        height: 48.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF53B175), Color(0xFF4CAF50)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF53B175).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12.r),
                            onTap: () {
                              // Scroll to categories section
                            },
                            child: Center(
                              child: Text(
                                "Browse Categories",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildCategoryChips(
    List<Category> categories,
    List<String> selectedIds,
    WidgetRef ref,
  ) {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: categories.map((Category category) {
        final isSelected = selectedIds.contains(category.id);
        return GestureDetector(
          onTap: () {
            final notifier = ref.read(listOfSelectedCategoriesProvider);
            if (isSelected) {
              notifier.removeItem(category.id);
            } else {
              notifier.addItem(category.id);
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 12.h,
            ),
            decoration: BoxDecoration(
              color:
                  isSelected ? const Color(0xFF53B175) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(25.r),
              border: Border.all(
                color:
                    isSelected ? const Color(0xFF53B175) : Colors.grey.shade300,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF53B175).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    size: 16.w,
                    color: Colors.white,
                  ),
                if (isSelected) SizedBox(width: 6.w),
                Text(
                  category.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF181725),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductGrid(List<Product> products, double screenWidth) {
    final crossAxisCount = screenWidth > 600 ? 3 : 2;
    final itemSpacing = 12.w;
    final aspectRatio = 0.60;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      addAutomaticKeepAlives: true, // Add this line
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: itemSpacing,
        mainAxisSpacing: itemSpacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(product: product); // Use the new ProductCard widget
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Column(
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor:
                  AlwaysStoppedAnimation<Color>(const Color(0xFF53B175)),
            ),
            SizedBox(height: 16.h),
            Text(
              "Loading...",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 60.w,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 60.w,
            color: Colors.orange.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(categoryProvider);
              ref.invalidate(filteredProductsProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF53B175),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 12.h,
              ),
            ),
            child: Text(
              "Retry",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Separate Stateful Widget for Product Card with AutomaticKeepAliveClientMixin
class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true; // This keeps the widget alive when scrolling

  @override
  Widget build(BuildContext context) {
    super.build(context); // Important: call super.build

    final product = widget.product;
    final hasVariants = product.variant != null && product.variant!.isNotEmpty;
    final price = hasVariants ? product.variant!.first.price : '0';
    final specialPrice =
        hasVariants ? product.variant!.first.specialPrice : null;
    final displayPrice =
        specialPrice?.isNotEmpty == true ? specialPrice! : price;
    final isOnSale = specialPrice?.isNotEmpty == true && specialPrice != price;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDisplayScreen(id: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Container
            Container(
              height: 170.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16.r),
                ),
                color: Colors.grey.shade100,
              ),
              child: Stack(
                children: [
                  // Product Image with CachedNetworkImage
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16.r),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: "$baseProductImageUrl${product.productimage}",
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF53B175)),
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            size: 40.w,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      fadeInDuration: const Duration(milliseconds: 300),
                      fadeOutDuration: const Duration(milliseconds: 300),
                    ),
                  ),

                  // Sale Badge
                  if (isOnSale)
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          "SALE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Category Tag
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF53B175).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        product.catname,
                        style: TextStyle(
                          color: const Color(0xFF53B175),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Product Name
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize:
                            12.sp, // Slightly larger for better readability
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF181725),
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Price Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Price
                        Text(
                          "₹$displayPrice",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF181725),
                          ),
                        ),

                        // Original Price if on sale
                        if (isOnSale)
                          Text(
                            "₹$price",
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
