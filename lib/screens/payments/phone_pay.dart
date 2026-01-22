import 'package:flutter/material.dart';

enum PaymentStatus { success, failed }

class PaymentResponse {
  final PaymentStatus code;
  PaymentResponse(this.code);
}

class PhonePePaymentScreen extends StatelessWidget {
  final dynamic pePg;
  final Map<String, dynamic> paymentRequest;
  final Function(PaymentResponse?, String?) onPaymentComplete;

  const PhonePePaymentScreen({
    super.key,
    required this.pePg,
    required this.paymentRequest,
    required this.onPaymentComplete,
  });

  @override
  Widget build(BuildContext context) {
    // MOCK PhonePe payment
    Future.delayed(const Duration(seconds: 2), () {
      onPaymentComplete(PaymentResponse(PaymentStatus.success), null);
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
