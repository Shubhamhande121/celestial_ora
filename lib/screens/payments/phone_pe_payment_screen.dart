import 'package:flutter/material.dart';
import 'package:phone_pe_pg/phone_pe_pg.dart';

class PhonePePaymentScreen extends StatelessWidget {
  final PhonePePg pePg;
  final PaymentRequest paymentRequest;
  final Function(PaymentStatusReponse?, dynamic) onPaymentComplete;

  const PhonePePaymentScreen({
    Key? key,
    required this.pePg,
    required this.paymentRequest,
    required this.onPaymentComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pePg.startPayPageTransaction(
        paymentRequest: paymentRequest,
        onPaymentComplete: onPaymentComplete,
        appBar: AppBar(
          title: Text("Payment tt"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
    );
  }
}
