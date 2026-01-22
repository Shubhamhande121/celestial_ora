import 'package:flutter/material.dart';

class OrderAccepted extends StatelessWidget {
  const OrderAccepted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "🎉 Order Accepted!",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
