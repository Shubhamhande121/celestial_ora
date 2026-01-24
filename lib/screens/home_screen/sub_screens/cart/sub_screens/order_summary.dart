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

import '../../../../../constants/constants.dart';
import 'package:phone_pe_pg/phone_pe_pg.dart' hide PaymentStatus;

import '../../../../payments/phone_pay.dart';

class OrderSummary extends StatefulWidget {
  OrderSummary({Key? key, required this.orderList}) : super(key: key);

  final List orderList;

  @override
  State<OrderSummary> createState() => _OrderSummaryState();
}


class _OrderSummaryState extends State<OrderSummary> {
  final cartController = Get.find<CartController>();
  final homeController = Get.find<HomeController>();
  bool _hasShownInvalidCouponWarning = false;

  String body = "";
  String callback = "organicSaga";
  String checksum = "c2FndWVzZ2E=";
  String merchantId = "PGTESTPAYUAT";
  Map<String, String> headers = {
    "Content-Type": "application/json",
    "X-VERIFY": "true"
  };
  Map<String, String> pgHeaders = {"Content-Type": "application/json"};

  String apiEndPoint = "/pg/v1/pay";
  bool enableLogs = true;
  Object? result;
  String dropdownValue = 'PG';
  String environmentValue = 'UAT_SIM';
  String appId = "";
  String packageName = "com.organic.organic_saga_app";

  

  String getBody({
    required String merchantTransactionId,
    required String merchantUserId,
    required double amount,
    required String mobileNumber,
    bool useWallet = false,
    double walletBalance = 0.0,
    String targetApp = "com.phonepe.app",
  }) {
    double finalAmount = amount;
    if (useWallet && walletBalance > 0) {
      finalAmount = amount - walletBalance;
      if (finalAmount < 0) {
        finalAmount = 0;
      }
    }

    var body = {
      "merchantId": "PGTESTPAYUAT",
      "merchantTransactionId": merchantTransactionId,
      "merchantUserId": merchantUserId,
      "amount": (finalAmount * 100).round(),
      "mobileNumber": mobileNumber,
      "callbackUrl": "https://your-backend.com/api/payment/callback",
      "paymentInstrument": {
        "type": "UPI_INTENT",
        "targetApp": targetApp,
      },
      "deviceContext": {"deviceOS": "ANDROID"}
    };

    String jsonBody = jsonEncode(body);
    String base64EncodedBody = base64Encode(utf8.encode(jsonBody));
    return base64EncodedBody;
  }

  PhonePePg pePg = PhonePePg(
    isUAT: true,
    saltKey: "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399",
    saltIndex: "1",
  );

  Map<String, dynamic> _paymentRequest({String? merchantCallBackScheme}) {
    String generateRandomString(int len) {
      const chars =
          'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
      final rnd = Random();
      return String.fromCharCodes(
        Iterable.generate(
          len,
          (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
        ),
      );
    }

    return {
      "merchantId": "PGTESTPAYUAT",
      "merchantTransactionId": generateRandomString(10).toUpperCase(),
      "merchantUserId": generateRandomString(8).toUpperCase(),
      "amount": 100, // paise (₹1)
      "callbackUrl":
          "https://webhook.site/55d95b9b-bec9-491e-b257-cbaf0ff7aa7e",
      "mobileNumber": "9769364928",
      "paymentInstrument": {
        "type": "PAY_PAGE",
      },
    };
  }

  // PaymentRequest _paymentRequest({String? merchantCallBackScheme}) {
  //   String generateRandomString(int len) {
  //     const chars =
  //         'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  //     Random rnd = Random();
  //     return String.fromCharCodes(
  //       Iterable.generate(
  //           len, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
  //     );
  //   }

  //   return PaymentRequest(
  //     amount: 100, // ₹1.00 (amount in paise)
  //     paymentInstrument: PayPagePaymentInstrument(),
  //     callbackUrl: "https://webhook.site/55d95b9b-bec9-491e-b257-cbaf0ff7aa7e",
  //     deviceContext: DeviceContext.getDefaultDeviceContext(
  //       merchantCallBackScheme: merchantCallBackScheme,
  //     ),
  //     merchantId: "PGTESTPAYUAT",
  //     merchantTransactionId: generateRandomString(10).toUpperCase(),
  //     merchantUserId: generateRandomString(8).toUpperCase(),
  //     mobileNumber: "9769364928",
  //   );
  // }

  // PaymentRequest _paymentRequest({String? merchantCallBackScheme}) {
  //   String generateRandomString(int len) {
  //     const chars =
  //         'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  //     Random rnd = Random();
  //     var s = String.fromCharCodes(Iterable.generate(
  //         len, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  //     return s;
  //   }

  //   PaymentRequest paymentRequest = PaymentRequest(
  //     amount: 100,
  //     paymentInstrument: PayPagePaymentInstrument(),
  //     callbackUrl: "https://webhook.site/55d95b9b-bec9-491e-b257-cbaf0ff7aa7e",
  //     deviceContext: DeviceContext.getDefaultDeviceContext(
  //         merchantCallBackScheme: merchantCallBackScheme),
  //     merchantId: "PGTESTPAYUAT",
  //     merchantTransactionId: generateRandomString(10).toUpperCase(),
  //     merchantUserId: generateRandomString(8).toUpperCase(),
  //     mobileNumber: "9769364928",
  //   );
  //   return paymentRequest;
  // }

  void handleError(error) {
    setState(() {
      if (error is Exception) {
        result = error.toString();
      } else {
        result = {"error": error};
      }
    });
  }

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
    return cartTotal - discount;
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

  var isLoading = false.obs;

// In your _removeProductFromOrderSummary method:
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

  checkoutOrder() async {
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

    isLoading.value = true;
    var userId = await SharedPref.getUserId();
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/Auth/checkout'));
    Map<String, String> data = {};
    if (cartController.selectedPromoCode.isEmpty) {
      data = {
        'address_id': cartController.selectedAddress.value["id"].toString(),
        'coupon_id': '',
        'user_id': userId!,
      };
    } else {
      data = {
        'address_id': cartController.selectedAddress.value["id"].toString(),
        'coupon_id': cartController.selectedPromoCode.value["id"].toString(),
        'user_id': userId!,
      };
    }
    request.fields.addAll(data);

    try {
      http.StreamedResponse response = await request.send();
      var res = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        Get.to(() => OrderAccepted());
        isLoading.value = false;
      } else {
        print(response.reasonPhrase);
        isLoading.value = false;
      }
    } catch (e) {
      print('Checkout error: $e');
      isLoading.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
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

  getBase64String(e) {
    var b = e.toString();
    var bytes = utf8.encode(b);
    var base64Str = base64.encode(bytes);
    return base64Str;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
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
            SizedBox(
              height: 10.h,
            ),

            // Delivery Address Section
            _buildDeliveryAddressSection(screenWidth),
            SizedBox(
              height: 10.h,
            ),

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
      // Wrap the entire button in Obx
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
              onTap: isButtonEnabled
                  ? () {
                      if (widget.orderList.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Your cart is empty")),
                        );
                        return;
                      }

                      if (cartController.selectedAddress.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Please select an address first")),
                        );
                        return;
                      }

                      if (!isCouponValid()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Invalid coupon. Please remove it before placing order."),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PhonePePaymentScreen(
                            pePg: pePg,
                            paymentRequest: _paymentRequest(),
                            onPaymentComplete: (paymentResponse, error) {
                              Navigator.pop(context);

                              if (paymentResponse?.code ==
                                  PaymentStatus.success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Transaction Successful")),
                                );
                                Get.to(() => OrderAccepted());
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Transaction Failed")),
                                );
                              }
                            },
                          ),
                        ),
                      );

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => PhonePePaymentScreen(
                      //       pePg: pePg,
                      //       paymentRequest: _paymentRequest(),
                      //       onPaymentComplete: (paymentResponse, paymentError) {
                      //         Navigator.pop(context);
                      //         if (paymentResponse != null &&
                      //             paymentResponse.code ==
                      //                 PaymentStatus.success) {
                      //           ScaffoldMessenger.of(context).showSnackBar(
                      //             const SnackBar(
                      //                 content: Text("Transaction Successful")),
                      //           );
                      //           Get.to(() => OrderAccepted());
                      //         } else {
                      //           ScaffoldMessenger.of(context).showSnackBar(
                      //             const SnackBar(
                      //                 content: Text("Transaction Failed")),
                      //           );
                      //         }
                      //       },
                      //     ),
                      //   ),
                      // );
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (_) => PhonePePaymentScreen(
                      //       pePg: pePg,
                      //       paymentRequest: _paymentRequest(),
                      //       onPaymentComplete: (paymentResponse, paymentError) {
                      //         Navigator.pop(context);
                      //         if (paymentResponse != null &&
                      //             paymentResponse.code ==
                      //                 PaymentStatus.success) {
                      //           ScaffoldMessenger.of(context).showSnackBar(
                      //             const SnackBar(
                      //                 content: Text("Transaction Successful")),
                      //           );
                      //           Get.to(() => OrderAccepted());
                      //         } else {
                      //           ScaffoldMessenger.of(context).showSnackBar(
                      //             const SnackBar(
                      //                 content: Text("Transaction Failed")),
                      //           );
                      //         }
                      //       },
                      //     ),
                      //   ),
                      // );
                    }
                  : null, // Disable onTap when button is not enabled
              child: Container(
                width: double.infinity,
                height: 56.h,
                alignment: Alignment.center,
                child: Obx(
                  () => isLoading.value
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          "Place Order",
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
        ),
      );
    });
  }

  Widget _buildProductsSection(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //SizedBox(height: 12.h),
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
    this.onDelete,
  }) : super(key: key);

  final double screenWidth;
  final String productName, quantity, cost, imageUrl;
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
