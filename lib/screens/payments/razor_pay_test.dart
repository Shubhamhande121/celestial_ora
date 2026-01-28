// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// class TestRazorpayPage extends StatefulWidget {
//   @override
//   _TestRazorpayPageState createState() => _TestRazorpayPageState();
// }

// class _TestRazorpayPageState extends State<TestRazorpayPage> {
//   late Razorpay _razorpay;
//   final String _razorpayKey =
//       "rzp_test_1DP5mmOlF5G5ag"; // Test key - replace with yours

//   @override
//   void initState() {
//     super.initState();
//     _initializeRazorpay();
//   }

//   void _initializeRazorpay() {
//     print("Initializing Razorpay...");
//     _razorpay = Razorpay();
//     _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
//     _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
//     _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//     print("Razorpay initialized");
//   }

//   void _handlePaymentSuccess(PaymentSuccessResponse response) {
//     print("Payment Success: ${response.paymentId}");
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Payment Successful"),
//         content: Text("Payment ID: ${response.paymentId}"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handlePaymentError(PaymentFailureResponse response) {
//     print("Payment Error: ${response.code} - ${response.message}");
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Payment Failed"),
//         content: Text("Error: ${response.message ?? 'Unknown error'}"),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     print("External Wallet: ${response.walletName}");
//   }

//   void _openRazorpay() {
//     print("Opening Razorpay...");
//     try {
//       var options = {
//         'key': _razorpayKey,
//         'amount': 10000, // ₹100 in paise
//         'name': 'Test Merchant',
//         'description': 'Test Payment',
//         'prefill': {
//           'contact': '8888888888',
//           'email': 'test@email.com',
//         },
//         'theme': {'color': '#2196F3'}
//       };

//       _razorpay.open(options);
//       print("Razorpay.open() called successfully");
//     } catch (e) {
//       print("Error opening Razorpay: $e");
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text("Error"),
//           content: Text("Failed to open Razorpay: $e"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text("OK"),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _razorpay.clear();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Test Razorpay"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: _openRazorpay,
//               child: Text("Test Razorpay Payment"),
//               style: ElevatedButton.styleFrom(
//                 padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
//               ),
//             ),
//             SizedBox(height: 20),
//             Text(
//               "This will open Razorpay payment gateway",
//               style: TextStyle(color: Colors.grey),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
