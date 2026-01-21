// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/components/utils.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/cart_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/sub_screens/order_summary.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/product_display_screen/product_display_screen.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  final CartController cartController = Get.find();
  @override
  void initState() {
    super.initState();

    // Refresh cart when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartController.getCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    CartController cartController = Get.find();
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: ThemedAppBar(title: 'My Cart'),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (cartController.cartList.isEmpty) {
                return _buildEmptyCart();
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                itemCount: cartController.cartList.length,
                itemBuilder: (context, index) {
                  var item = cartController.cartList[index];

                  return ModernCartItem(
                    qty: int.tryParse(item["cart_qty"] ?? "1") ?? 1,
                    // In the onRemove callback in Cart screen
                    // In your Cart screen, update the onRemove callback:
// In your Cart screen, update the onRemove callback:
                    onRemove: () {
                      showWarningDialog(
                        () {
                          Navigator.of(context).pop();

                          // Get product info before removing
                          final productId = item["product_id"]?.toString();
                          final variantId = item["pv_id"]?.toString();

                          // ✅ FIX: Update local cart state IMMEDIATELY
                          if (productId != null && variantId != null) {
                            // Remove from localCartItems
                            final key = '$productId-$variantId';
                            cartController.localCartItems.remove(key);

                            // Update the cart count immediately
                            cartController.updateCartCountOptimistically();

                            // Update total price
                            cartController.recalculateTotal();
                          }

                          // ✅ FIX: Then remove from server
                          cartController.removeFromCart(item["cart_id"] ?? "");
                        },
                        "Remove Product",
                        "Are you sure you want to remove this item from cart?",
                        context,
                        () {
                          Navigator.of(context).pop();
                        },
                      );
                    },
                    imageURL: item["image"] ?? "",
                    productName: item["name"] ?? "Product Name",
                    description: item["description"] ?? "",
                    cost: item["special_price"] ?? "0",
                    originalPrice: item["price"] ?? "",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDisplayScreen(
                              id: item["product_id"] ?? ""),
                        ),
                      );
                    },
                    onPlusPressed: () {
                      int currentQty =
                          int.tryParse(item["cart_qty"] ?? "1") ?? 1;

                      // Update UI immediately
                      cartController.cartList[index]["cart_qty"] =
                          (currentQty + 1).toString();
                      cartController.cartList.refresh();
                      cartController.recalculateTotal();

                      // ✅ FIX: Also update localCartItems
                      final productId = item["product_id"]?.toString();
                      final variantId = item["pv_id"]?.toString();
                      if (productId != null && variantId != null) {
                        final key = '$productId-$variantId';
                        cartController.localCartItems[key] = currentQty + 1;
                        cartController.updateCartCountOptimistically();
                      }

                      // Update server
                      cartController
                          .updateCart(
                        item["product_id"] ?? "",
                        currentQty + 1,
                        item["pv_id"] ?? "",
                        item["cart_id"] ?? "",
                      )
                          .then((success) {
                        if (!success) {
                          // Rollback
                          cartController.cartList[index]["cart_qty"] =
                              currentQty.toString();
                          cartController.cartList.refresh();
                          cartController.recalculateTotal();

                          if (productId != null && variantId != null) {
                            final key = '$productId-$variantId';
                            cartController.localCartItems[key] = currentQty;
                            cartController.updateCartCountOptimistically();
                          }
                        }
                      });
                    },
                    onMinusPressed: () {
                      int currentQty =
                          int.tryParse(item["cart_qty"] ?? "1") ?? 1;

                      if (currentQty > 1) {
                        // Update UI immediately
                        cartController.cartList[index]["cart_qty"] =
                            (currentQty - 1).toString();
                        cartController.cartList.refresh();
                        cartController.recalculateTotal();

                        // ✅ FIX: Also update localCartItems
                        final productId = item["product_id"]?.toString();
                        final variantId = item["pv_id"]?.toString();
                        if (productId != null && variantId != null) {
                          final key = '$productId-$variantId';
                          cartController.localCartItems[key] = currentQty - 1;
                          cartController.updateCartCountOptimistically();
                        }

                        // Update server
                        cartController
                            .updateCart(
                          item["product_id"] ?? "",
                          currentQty - 1,
                          item["pv_id"] ?? "",
                          item["cart_id"] ?? "",
                        )
                            .then((success) {
                          if (!success) {
                            // Rollback
                            cartController.cartList[index]["cart_qty"] =
                                currentQty.toString();
                            cartController.cartList.refresh();
                            cartController.recalculateTotal();

                            if (productId != null && variantId != null) {
                              final key = '$productId-$variantId';
                              cartController.localCartItems[key] = currentQty;
                              cartController.updateCartCountOptimistically();
                            }
                          }
                        });
                      } else {
                        // When quantity is 1 and we click minus, remove the item
                        final productId = item["product_id"]?.toString();
                        final variantId = item["pv_id"]?.toString();

                        // ✅ FIX: Update local state first
                        if (productId != null && variantId != null) {
                          final key = '$productId-$variantId';
                          cartController.localCartItems.remove(key);
                          cartController.updateCartCountOptimistically();
                          cartController.recalculateTotal();
                        }

                        // Then remove from server
                        cartController.removeFromCart(item["cart_id"] ?? "");
                      }
                    },
                  );
                },
              );
            }),
          ),
          Obx(() {
            if (cartController.cartTotalPrice.value == 0 ||
                cartController.isAddToCartLoading.value) {
              return const SizedBox();
            }

            return _buildCheckoutSection(cartController, screenWidth);
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80.sp,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16.h),
          Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Add some organic goodness!",
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 24.h),
          // ElevatedButton(
          //   onPressed: () {
          //     Get.back();
          //   },
          //   style: ElevatedButton.styleFrom(
          //     backgroundColor: primaryColor,
          //     padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(24.r),
          //     ),
          //   ),
          //   child: Text(
          //     "Start Shopping",
          //     style: TextStyle(
          //       fontSize: 16.sp,
          //       fontWeight: FontWeight.w600,
          //       color: Colors.white,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(
      CartController cartController, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total:",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "$indianRupeeSymbol ${cartController.cartTotalPrice.value.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.to(() => OrderSummary(orderList: cartController.cartList));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "Proceed to Checkout",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModernCartItem extends StatelessWidget {
  const ModernCartItem({
    Key? key,
    required this.qty,
    required this.onRemove,
    required this.imageURL,
    required this.productName,
    required this.description,
    required this.cost,
    required this.onPressed,
    required this.onPlusPressed,
    required this.onMinusPressed,
    this.originalPrice = "",
  }) : super(key: key);

  final int qty;
  final String imageURL, productName, description, cost, originalPrice;
  final VoidCallback onPressed, onPlusPressed, onMinusPressed, onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Stack(
        children: [
          InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.network(
                      "$baseProductImageUrl${Uri.encodeComponent(imageURL)}",
                      width: 80.w,
                      height: 80.h,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80.w,
                        height: 80.h,
                        color: Colors.grey[100],
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 30.sp,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Details + Price + Actions
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name
                        Text(
                          productName,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),

                        // Description
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        // Price + Actions Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Price
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$indianRupeeSymbol $cost",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightGreen,
                                    ),
                                  ),
                                  if (originalPrice.isNotEmpty &&
                                      originalPrice != cost)
                                    Text(
                                      "$indianRupeeSymbol $originalPrice",
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Quantity Controls
                            Card(
                              elevation: 3,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.grey.shade100
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14.r),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Minus
                                    InkWell(
                                      onTap: onMinusPressed,
                                      borderRadius: BorderRadius.circular(30.r),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: qty == 1
                                              ? Colors.grey.shade200
                                              : Colors.red.shade50,
                                        ),
                                        padding: EdgeInsets.all(6.w),
                                        child: Icon(
                                          Icons.remove,
                                          size: 20.sp,
                                          color: qty == 1
                                              ? Colors.grey
                                              : Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.w),
                                      child: Text(
                                        qty.toString(),
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    // Plus
                                    InkWell(
                                      onTap: onPlusPressed,
                                      borderRadius: BorderRadius.circular(30.r),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green.shade50,
                                        ),
                                        padding: EdgeInsets.all(6.w),
                                        child: Icon(Icons.add,
                                            size: 20.sp, color: Colors.green),
                                      ),
                                    ),
                                  ],
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

          // Positioned Remove Button
          Positioned(
            top: 6.h,
            right: 10.w,
            child: InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 18.sp,
                  color: Colors.black26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
