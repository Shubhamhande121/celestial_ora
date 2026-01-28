import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/home_screen/home_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/cart_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/product_display_screen/product_display_screen.dart';

class BestSellerWithCategoryScreen extends StatefulWidget {
  // final List<dynamic> categories;
  // final Map<String, List<dynamic>> categoryWiseProducts;

  const BestSellerWithCategoryScreen({
    Key? key,
    // required this.categories,
    // required this.categoryWiseProducts,
  }) : super(key: key);

  @override
  State<BestSellerWithCategoryScreen> createState() =>
      _BestSellerWithCategoryScreenState();
}

class _BestSellerWithCategoryScreenState
    extends State<BestSellerWithCategoryScreen> {
  final cartController = Get.find<CartController>();
  final homeController = Get.find<HomeController>();

  // @override
  // void didUpdateWidget(covariant BestSellerWithCategoryScreen oldWidget) {
  //   super.didUpdateWidget(oldWidget);

  //   if (oldWidget.categoryWiseProducts != widget.categoryWiseProducts) {
  //     final selectedCategoryId =
  //         widget.categories[selectedCategoryIndex]['category_id'].toString();

  //     if (!widget.categoryWiseProducts.containsKey(selectedCategoryId)) {
  //       setState(() {
  //         selectedCategoryIndex = 0;
  //       });
  //     }
  //   }
  // }

  @override
  void initState() {
    super.initState();

    homeController.fetchCategories().then((_) {
      if (homeController.baseCategoriesList.isNotEmpty) {
        final firstCategoryId =
            homeController.baseCategoriesList.first['id'].toString();

        homeController.fetchProducts(firstCategoryId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ThemedAppBar(
        title: 'Best Selling Products',
        showBack: true,
      ),
      body: Row(
        children: [
          /// 🔹 LEFT CATEGORY LIST
          Container(
            width: MediaQuery.of(context).size.width * 0.28,
            color: Colors.grey[100],
            child: ListView.builder(
              itemCount: homeController.baseCategoriesList.length,
              itemBuilder: (context, index) {
                final category = homeController.baseCategoriesList[index];

                return Obx(() {
                  final isSelected =
                      index == homeController.selectedCategoryIndex.value;

                  return InkWell(
                    onTap: () {
                      if (homeController.selectedCategoryIndex.value == index)
                        return;

                      homeController.selectedCategoryIndex.value = index;
                      homeController.changeCategory(category['id']);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.transparent,
                        border: Border.all(
                          color:
                              isSelected ? Colors.orange : Colors.transparent,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 10),
                      child: Column(
                        children: [
                          if (isSelected)
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(
                                baseCategoryImageUrl + category['image'],
                              ),
                              onBackgroundImageError: (_, __) {},
                            ),
                          if (isSelected) const SizedBox(height: 8),
                          Text(
                            category['name'] ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.green : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),

          /// 🔹 RIGHT PRODUCT LIST
          Expanded(
            child: Obx(() {
              // 🔄 Loading state
              if (homeController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // 📭 Empty state
              if (homeController.products.isEmpty) {
                return const Center(
                  child: Text("No products found"),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(
                    bottom: 35, left: 5, right: 5, top: 5),
                itemCount: homeController.products.length,
                itemBuilder: (context, index) {
                  final item = homeController.products[index];
                  final variants = item['variant'] ?? [];
                  final variant = variants.isNotEmpty ? variants[0] : null;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        final pid = item['id']?.toString() ?? '';
                        if (pid.isNotEmpty) {
                          Get.to(() => ProductDisplayScreen(id: pid));
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              child: Image.network(
                                item['productimage'] != null
                                    ? baseProductImageUrl + item['productimage']
                                    : '',
                                width: 100.w,
                                height: 130.h,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  "assets/images/logo.png",
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['productname'] ?? 'Product',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (variant != null)
                                      Text(
                                        item['variant_text'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text(
                                          "$indianRupeeSymbol ${variant?['special_price'] ?? 'N/A'}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        if (variant?['price'] != null &&
                                            variant['special_price'] !=
                                                variant['price'])
                                          Text(
                                            "$indianRupeeSymbol ${variant['price']}",
                                            style: const TextStyle(
                                              fontSize: 13,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              color: Colors.grey,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    /// 🔥 Cart Controls
                                    Obx(() {
                                      final cartItem = cartController.cartList
                                          .firstWhereOrNull(
                                        (c) =>
                                            c['product_id'].toString() ==
                                            item['productid'].toString(),
                                      );

                                      if (cartItem == null) {
                                        // Not in cart → Show Add button
                                        return SizedBox(
                                          height: 35,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              cartController.addToCart(
                                                item['productid'].toString(),
                                                1,
                                                variant?['id']?.toString() ??
                                                    "0",
                                                context,
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                            ),
                                            child: const Text("Add"),
                                          ),
                                        );
                                      } else {
                                        // Already in cart → Show quantity controls
                                        final qty = int.tryParse(
                                                cartItem['cart_qty']
                                                    .toString()) ??
                                            1;

                                        return Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove,
                                                  size: 20),
                                              onPressed: () async {
                                                if (qty > 1) {
                                                  final newQty = qty - 1;
                                                  final success =
                                                      await cartController
                                                          .updateCart(
                                                    item['productid']
                                                        .toString(),
                                                    newQty,
                                                    variant?['id']
                                                            ?.toString() ??
                                                        "0",
                                                    cartItem['cart_id']
                                                        .toString(),
                                                  );
                                                  if (success) {
                                                    cartItem['cart_qty'] =
                                                        newQty.toString();
                                                    cartController
                                                        .recalculateTotal();
                                                    cartController.cartList
                                                        .refresh();
                                                  }
                                                } else {
                                                  await cartController
                                                      .removeFromCart(
                                                          cartItem['cart_id']);
                                                }
                                              },
                                            ),
                                            Text(
                                              qty.toString(),
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add,
                                                  size: 20),
                                              onPressed: () async {
                                                final newQty = qty + 1;
                                                final success =
                                                    await cartController
                                                        .updateCart(
                                                  item['productid'].toString(),
                                                  newQty,
                                                  variant?['id']?.toString() ??
                                                      "0",
                                                  cartItem['cart_id']
                                                      .toString(),
                                                );
                                                if (success) {
                                                  cartItem['cart_qty'] =
                                                      newQty.toString();
                                                  cartController
                                                      .recalculateTotal();
                                                  cartController.cartList
                                                      .refresh();
                                                }
                                              },
                                            ),
                                          ],
                                        );
                                      }
                                    }),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ),
    );
  }
}
