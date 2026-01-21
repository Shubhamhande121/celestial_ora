import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class TrendingProductsSection extends StatelessWidget {
  final RxBool isLoadingTrending;
  final List<dynamic> exclusiveData;
  final String baseProductImageUrl;
  final Function(dynamic) onProductTap;
  final Function(dynamic) onAddToCart;

  const TrendingProductsSection({
    Key? key,
    required this.isLoadingTrending,
    required this.exclusiveData,
    required this.baseProductImageUrl,
    required this.onProductTap,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Obx(() {
      if (isLoadingTrending.value) {
        return _buildLoadingShimmers(screenWidth);
      }

      if (exclusiveData.isEmpty) {
        return SizedBox(
          height: 200,
          child: Center(
            child: Text(
              'No trending products',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        );
      }

      return _buildProductsList(screenWidth);
    });
  }

  Widget _buildLoadingShimmers(double screenWidth) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: 100,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 12,
                          width: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsList(double screenWidth) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: exclusiveData.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final product = exclusiveData[index];
          final productName = product["productname"] ?? "";
          final productImage = product["productimage"] ?? "";
          final productId = product["productid"]?.toString() ?? "";
          final variants = product["variant"] as List?;

          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onProductTap(product),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Expanded(
                        flex: 6,
                        child: Container(
                          width: double.infinity,
                          color: Colors.grey.shade100,
                          child: (productImage.isNotEmpty)
                              ? Image.network(
                                  baseProductImageUrl + productImage,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      child: Container(
                                        color: Colors.grey.shade300,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.error_outline,
                                          color: Colors.grey.shade400),
                                )
                              : Icon(Icons.image_not_supported,
                                  color: Colors.grey.shade400),
                        ),
                      ),

                      // Product Info
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name with ellipsis for overflow
                            Text(
                              productName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 6),

                            // Price and Add to Cart button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Price placeholder - replace with actual price data
                                Text(
                                  "\$XX.XX",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),

                                // Add to Cart button
                                InkWell(
                                  onTap: () => onAddToCart(product),
                                  child: Container(
                                    height: 28,
                                    width: 28,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
