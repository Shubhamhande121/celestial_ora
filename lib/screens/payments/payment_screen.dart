

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:organic_saga/screens/payments/order_accepted.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import 'phone_pay.dart';

// Dummy imports – replace with your real ones
// import 'phonepe_payment_screen.dart';
// import 'order_accepted.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleRazorpaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleRazorpayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // ---------------- PHONEPE ----------------
  void openPhonePe() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhonePePaymentScreen(
          pePg: "PHONEPE_PG_OBJECT",
          paymentRequest: _paymentRequest(),
          onPaymentComplete: (paymentResponse, paymentError) {
            Navigator.pop(context);

            if (paymentResponse != null &&
                paymentResponse.code == PaymentStatus.success) {
              _onPaymentSuccess();
            } else {
              // ❌ PhonePe failed → open Razorpay
              openRazorpay();
            }
          },
        ),
      ),
    );
  }

  Map<String, dynamic> _paymentRequest() {
    return {
      "amount": 500, // ₹500
      "orderId": "ORDER_${DateTime.now().millisecondsSinceEpoch}",
    };
  }

  // ---------------- RAZORPAY ----------------
  void openRazorpay() {
    var options = {
      'key': 'rzp_test_xxxxxxxx', // 🔑 YOUR KEY
      'amount': 500 * 100, // in paise
      'name': 'My App',
      'description': 'Order Payment',
      'prefill': {
        'contact': '9999999999',
        'email': 'test@email.com',
      },
      'theme': {
        'color': '#E91E63',
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay error: $e");
    }
  }

  void _handleRazorpaySuccess(PaymentSuccessResponse response) {
    _onPaymentSuccess();
  }

  void _handleRazorpayError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transaction Failed")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  // ---------------- COMMON SUCCESS ----------------
  void _onPaymentSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transaction Successful")),
    );

    Get.offAll(() => const OrderAccepted());
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: openPhonePe,
              child: const Text("Pay with PhonePe"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: openRazorpay,
              child: const Text("Pay with Razorpay"),
            ),
          ],
        ),
      ),
    );
  }
}
