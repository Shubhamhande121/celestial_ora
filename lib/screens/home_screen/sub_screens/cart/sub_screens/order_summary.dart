// ignore_for_file: invalid_use_of_protected_member

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/components/utils.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/screens/address_screens/address_screens.dart';
import 'package:organic_saga/screens/home_screen/home_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/promocode/promocode.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/cart_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/sub_screens/order_accepted.dart';
import 'package:organic_saga/shared_pref/shared_pref.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../../../../constants/constants.dart';

class OrderSummary extends StatefulWidget {
  OrderSummary({Key? key, required this.orderList}) : super(key: key);

  final List orderList;

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  final cartController = Get.find<CartController>();
  final homeController = Get.find<HomeController>();
  late Razorpay _razorpay;

  bool _hasShownInvalidCouponWarning = false;
  var isLoading = false.obs;

  // Razorpay API Keys - Replace with your actual keys
  // For testing, you can use these test keys
  static const String razorpayKey =
      "rzp_test_1DP5mmOlF5G5ag"; // Replace with your key_id
  static const String razorpaySecret =
      "YOUR_SECRET_KEY"; // Replace with your secret key

  double getPrice() {
    double price = 0;
    for (int i = 0; i < widget.orderList.length; i++) {
      price += double.parse(widget.orderList[i]["special_price"]) *
          int.parse(widget.orderList[i]["cart_qty"]);
    }
    return price;
  }

  double getDiscount() {
    if (cartController.selectedPromoCode.isEmpty) return 0.0;

    final code = cartController.selectedPromoCode.value;
    double discountAmount = 0.0;
    double cartTotal = getPrice();

    if (code["type"] == "percentage") {
      discountAmount =
          (cartTotal * double.parse(code["value"].toString())) / 100;
    } else {
      discountAmount = double.tryParse(code["value"].toString()) ?? 0.0;
    }

    if (discountAmount > cartTotal) {
      if (!_hasShownInvalidCouponWarning) {
        _hasShownInvalidCouponWarning = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    "Coupon value exceeds cart total. Coupon not applied."),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
      return 0.0;
    }

    _hasShownInvalidCouponWarning = false;
    return discountAmount;
  }

  double getFinalAmount() {
    double cartTotal = getPrice();
    double discount = getDiscount();
    double finalAmount = cartTotal - discount;

    // Convert to rupees (Razorpay expects amount in paise)
    return finalAmount;
  }

  bool isCouponValid() {
    if (cartController.selectedPromoCode.isEmpty) return true;

    final code = cartController.selectedPromoCode.value;
    double discountAmount = 0.0;
    double cartTotal = getPrice();

    if (code["type"] == "percentage") {
      discountAmount =
          (cartTotal * double.parse(code["value"].toString())) / 100;
    } else {
      discountAmount = double.tryParse(code["value"].toString()) ?? 0.0;
    }

    return discountAmount <= cartTotal;
  }

  void _removeInvalidCoupon() {
    if (cartController.selectedPromoCode.isNotEmpty && !isCouponValid()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Coupon value exceeds cart total. Coupon removed."),
              backgroundColor: Colors.red,
            ),
          );
        }
      });
      cartController.selectedPromoCode.value = {};
    }
  }

  getGst() {
    double gst = 18;
    double total = getPrice();
    return (total * gst) / 100;
  }

  void _removeProductFromOrderSummary(int index) {
    showWarningDialog(
      () {
        Navigator.of(context).pop();

        // Get product info before removing
        final removedItem = widget.orderList[index];
        final productId = removedItem["product_id"]?.toString();
        final variantId = removedItem["pv_id"]?.toString();
        final cartId = removedItem["cart_id"]?.toString();

        // 🔥 1. Remove from local cart state IMMEDIATELY
        if (productId != null && variantId != null) {
          final key = '$productId-$variantId';
          cartController.localCartItems.remove(key);
        }

        // 🔥 2. Remove from UI
        setState(() {
          widget.orderList.removeAt(index);
        });

        // 🔥 3. Update cart count - IMPORTANT!
        cartController.cartItemCount.value = cartController.cartList.length;

        // 🔥 4. Also call updateCartCountOptimistically to ensure sync
        cartController.updateCartCountOptimistically();

        // 🔥 5. Recalculate total
        cartController.recalculateTotal();

        // 🔥 6. Remove from server
        if (cartId != null && cartId.isNotEmpty) {
          cartController.removeFromCart(cartId);
        }
      },
      "Remove Product",
      "Are you sure you want to remove this item from your order?",
      context,
      () {
        Navigator.of(context).pop();
      },
    );
  }

  // Initialize Razorpay
  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // Handle successful payment
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Payment Success: ${response.paymentId}");

    // Complete the checkout process
    _completeCheckout(response.paymentId!);

    // Navigate to order accepted page
    Get.off(() => OrderAccepted());
  }

  // Handle payment failure
  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment Error: ${response.code} - ${response.message}");
    isLoading.value = false;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment failed: ${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Handle external wallet
  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet: ${response.walletName}");
    isLoading.value = false;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment via ${response.walletName}"),
      ),
    );
  }

  // Open Razorpay checkout
  void _openRazorpayCheckout() async {
    print("═══════════════════════════════════════════");
    print("🎯 RAZORPAY CHECKOUT STARTED");
    print("═══════════════════════════════════════════");

    try {
      isLoading.value = true;

      // Test with fixed amount first
      final amount = 100; // ₹1 for testing
      print("💰 Amount: $amount paise (₹1)");

      // Use a verified test key
      final String testKey = "rzp_test_1DP5mmOlF5G5ag";
      print("🔑 Using Razorpay key: $testKey");
      print("✅ Key valid: ${testKey.startsWith('rzp_test_')}");

      // Get user info
      final user = homeController.userModel.value;
      final contact = user.mobile ?? '9999999999';
      final email = user.email ?? 'customer@example.com';
      print("👤 User contact: $contact, email: $email");

      // Create options
      var options = {
        'key': testKey,
        'amount': amount,
        'name': 'Celestial Ora',
        'description': 'Test Payment',
        'prefill': {
          'contact': contact,
          'email': email,
        },
        'theme': {
          'color': '#4CAF50',
          'backdrop_color': '#00000080',
        }
      };

      print("⚙️ Options: $options");
      print("🚀 Calling _razorpay.open()...");

      _razorpay.open(options);

      print("✅ _razorpay.open() called successfully!");
    } catch (e, stackTrace) {
      print("❌ ERROR: $e");
      print("📋 Stack trace: $stackTrace");

      isLoading.value = false;

      // Show detailed error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Payment Error",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(e.toString(), style: TextStyle(fontSize: 12)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      print("═══════════════════════════════════════════");
      print("🎯 RAZORPAY CHECKOUT COMPLETED");
      print("═══════════════════════════════════════════");
    }
  }

  // Complete checkout after payment
  void _completeCheckout(String paymentId) async {
    try {
      var userId = await SharedPref.getUserId();
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/Auth/checkout'));

      Map<String, String> data = {
        'address_id': cartController.selectedAddress.value["id"].toString(),
        'user_id': userId!,
        'payment_id': paymentId,
        'payment_method': 'razorpay',
      };

      if (cartController.selectedPromoCode.isNotEmpty) {
        data['coupon_id'] =
            cartController.selectedPromoCode.value["id"].toString();
      }

      request.fields.addAll(data);

      http.StreamedResponse response = await request.send();
      var res = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print("Checkout successful: $res");
        // Clear cart after successful order
        cartController.clearCart();
      } else {
        print("Checkout failed: ${response.reasonPhrase}");
      }

      isLoading.value = false;
    } catch (e) {
      print('Checkout error: $e');
      isLoading.value = false;
    }
  }

  // Place order and initiate payment
  void _placeOrder() {
    if (widget.orderList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Your cart is empty")),
      );
      return;
    }

    if (cartController.selectedAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an address first")),
      );
      return;
    }

    if (!isCouponValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Invalid coupon. Please remove it before placing order."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Open Razorpay payment
    _openRazorpayCheckout();
  }

  @override
  void initState() {
    super.initState();
    _initializeRazorpay();

    cartController.selectedAddress.value = {};
    cartController.selectedPromoCode.value = {};

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _removeInvalidCoupon();
      cartController.getCart();
    });
  }

  @override
  void didUpdateWidget(OrderSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _removeInvalidCoupon();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear(); // Clear listeners
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartController.getCart();
    });

    return Scaffold(
      appBar: const ThemedAppBar(
        title: "Order Summary",
        showBack: true,
      ),
      bottomNavigationBar: _buildBottomButton(screenWidth),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),

            // Products Section
            _buildProductsSection(screenWidth),
            // Order Summary Card
            _buildOrderSummaryCard(screenWidth),

            // Promo Code Section
            _buildPromoCodeSection(screenWidth),
            SizedBox(height: 10.h),

            // Delivery Address Section
            _buildDeliveryAddressSection(screenWidth),
            SizedBox(height: 10.h),

            // Wallet Section
            _buildWalletSection(screenWidth),

            SizedBox(height: 100.h), // Extra space for bottom button
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButton(double screenWidth) {
    return Obx(() {
      final isButtonEnabled = widget.orderList.isNotEmpty &&
          cartController.selectedAddress.isNotEmpty &&
          isCouponValid();

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.all(16.w),
        child: SafeArea(
          child: Material(
            borderRadius: BorderRadius.circular(12.r),
            color: isButtonEnabled ? primaryColor : Colors.grey.shade400,
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: isButtonEnabled ? _placeOrder : null,
              child: Container(
                width: double.infinity,
                height: 56.h,
                alignment: Alignment.center,
                child: Obx(() {
                  if (isLoading.value) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Opening Payment...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  }
                  return Text(
                    "Proceed to Pay",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      );
    });
  }
  // [Rest of your existing widget methods remain the same...]
  // _buildProductsSection, _buildOrderSummaryCard, _buildPromoCodeSection,
  // _buildDeliveryAddressSection, _buildWalletSection, etc.
  // All these methods remain unchanged from your original code

  Widget _buildProductsSection(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 ADD THIS TEST BUTTON (always show for now)
          ElevatedButton(
            onPressed: () {
              print("Test Razorpay button pressed");
              _openRazorpayCheckout();
            },
            child: Text("TEST RAZORPAY"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),

          if (widget.orderList.isEmpty) _buildEmptyCart(),

          if (widget.orderList.isNotEmpty)
            ...widget.orderList
                .asMap()
                .entries
                .map(
                  (entry) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: OrderSummaryInfoBuilder(
                      screenWidth: screenWidth,
                      productName: entry.value["name"],
                      quantity: entry.value["cart_qty"],
                      cost: entry.value["special_price"],
                      imageUrl: entry.value["image"] ?? "",
                      variantText:
                          entry.value["variant_text"] ?? "", // Add variant text
                      onDelete: () => _removeProductFromOrderSummary(entry.key),
                    ),
                  ),
                )
                .toList(),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 64.sp, color: Colors.grey.shade400),
          SizedBox(height: 16.h),
          Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Add some products to continue",
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard(double screenWidth) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order Summary",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.receipt_long, color: primaryColor),
            ],
          ),
          SizedBox(height: 16.h),

          // Subtotal
          _buildSummaryRow("Subtotal", "${getPrice().toStringAsFixed(2)}"),
          SizedBox(height: 8.h),

          // Discount
          Obx(() {
            if (cartController.selectedPromoCode.isNotEmpty &&
                isCouponValid()) {
              return Column(
                children: [
                  _buildSummaryRow(
                      "Discount", "-${getDiscount().toStringAsFixed(2)}",
                      isDiscount: true),
                  SizedBox(height: 8.h),
                ],
              );
            }
            return SizedBox();
          }),

          // Divider
          Container(
            height: 1,
            color: Colors.grey.shade200,
            margin: EdgeInsets.symmetric(vertical: 8.h),
          ),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Amount",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Obx(() {
                double finalAmount = getFinalAmount();
                return Text(
                  "$indianRupeeSymbol${finalAmount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          "$indianRupeeSymbol$value",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDiscount ? Colors.green : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCodeSection(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Promo Code",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.local_offer_outlined, color: primaryColor),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() {
            if (cartController.selectedPromoCode.isNotEmpty &&
                isCouponValid()) {
              return _buildAppliedPromoCode(screenWidth);
            } else if (cartController.selectedPromoCode.isNotEmpty &&
                !isCouponValid()) {
              return _buildInvalidPromoCode(screenWidth);
            } else {
              return _buildApplyPromoCodeButton();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildAppliedPromoCode(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Promo Code Applied",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                    fontSize: 14.sp,
                  ),
                ),
                Text(
                  "You saved $indianRupeeSymbol${getDiscount().toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.green.shade600,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              cartController.selectedPromoCode.value = {};
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green.shade200,
              ),
              child:
                  Icon(Icons.close, color: Colors.green.shade800, size: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvalidPromoCode(double screenWidth) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              "Invalid coupon. Please remove and apply a valid one.",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.red.shade800,
                fontSize: 14.sp,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              cartController.selectedPromoCode.value = {};
            },
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.shade200,
              ),
              child: Icon(Icons.close, color: Colors.red.shade800, size: 16.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyPromoCodeButton() {
    return Material(
      borderRadius: BorderRadius.circular(12.r),
      color: Colors.grey.shade100,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => PromoCode(isApplyCode: true),
          ));
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Apply Promo Code",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: primaryColor, size: 16.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryAddressSection(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Delivery Address",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.location_on_outlined, color: primaryColor),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() {
            if (cartController.selectedAddress.isEmpty) {
              return _buildSelectAddressButton();
            } else {
              return _buildSelectedAddressCard();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildSelectAddressButton() {
    return Material(
      borderRadius: BorderRadius.circular(12.r),
      color: Colors.grey.shade100,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => AddressScreen(isBack: true),
          ));
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Delivery Address",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  color: primaryColor, size: 16.sp),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedAddressCard() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cartController.selectedAddress.value['name'] ?? '',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade800,
                  fontSize: 14.sp,
                ),
              ),
              GestureDetector(
                onTap: () {
                  cartController.selectedAddress.value = {};
                },
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.shade200,
                  ),
                  child: Icon(Icons.close,
                      color: Colors.blue.shade800, size: 16.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            "Mobile: ${cartController.selectedAddress.value['phone'] ?? ''}",
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            "${cartController.selectedAddress.value['address1'] ?? ''}, ${cartController.selectedAddress.value['city'] ?? ''} - ${cartController.selectedAddress.value['pincode'] ?? ''}",
            style: TextStyle(
              color: Colors.blue.shade600,
              fontSize: 12.sp,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSection(double screenWidth) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Wallet Balance",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.account_balance_wallet_outlined, color: primaryColor),
            ],
          ),
          SizedBox(height: 12.h),
          if (homeController.userModel.value.mobile != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Available Balance",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "$indianRupeeSymbol ${homeController.userModel.value.walletBalance ?? '0.00'}",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                Obx(() => Switch(
                      value: cartController.isChecked.value,
                      onChanged: (bool? v) {
                        if (v != null) cartController.isChecked.value = v;
                      },
                      activeColor: primaryColor,
                    )),
              ],
            ),
        ],
      ),
    );
  }
}

class OrderSummaryInfoBuilder extends StatelessWidget {
  const OrderSummaryInfoBuilder({
    Key? key,
    required this.screenWidth,
    required this.productName,
    required this.quantity,
    required this.cost,
    required this.imageUrl,
    required this.variantText, // Add this parameter
    this.onDelete,
  }) : super(key: key);

  final double screenWidth;
  final String productName,
      quantity,
      cost,
      imageUrl,
      variantText; // Add variantText
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    double itemTotal = double.parse(cost) * int.parse(quantity);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          elevation: 4,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Container(
            padding: EdgeInsets.all(12.w),
            child: Row(
              children: [
                // Product Image
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    color: Colors.grey.shade100,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            "$baseProductImageUrl${Uri.encodeComponent(imageUrl)}",
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.shopping_bag_outlined,
                              color: Colors.grey.shade400,
                              size: 24.sp,
                            ),
                          )
                        : Icon(Icons.shopping_bag_outlined,
                            color: Colors.grey.shade400, size: 24.sp),
                  ),
                ),
                SizedBox(width: 12.w),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Add variant text here
                      if (variantText.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          variantText,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          "Qty: $quantity",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Price
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$indianRupeeSymbol${itemTotal.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: Colors.green.shade700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "$indianRupeeSymbol$cost each",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Delete button
        if (onDelete != null)
          Positioned(
            top: -8,
            right: -8,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
