import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:organic_saga/screens/home_screen/home_controller.dart';
import 'package:organic_saga/screens/home_screen/root_home_screen.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/orders/orders.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/cart_controller.dart';

import '../../../../../constants/constants.dart';

class OrderAccepted extends StatefulWidget {
  const OrderAccepted({Key? key}) : super(key: key);

  @override
  State<OrderAccepted> createState() => _OrderAcceptedState();
}

class _OrderAcceptedState extends State<OrderAccepted> {
  CartController _cartController = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cartController.removeFromCart('');
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.transparent,
            margin: EdgeInsets.only(
                left: screenWidth / 16.63, right: screenWidth / 16.63),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth / 21.789),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => RootHomeScreen()),
                      (route) => false);

                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => Orders()));
                },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                      alignment: Alignment.center,
                      child: Text("Track Order",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontSize: screenWidth / 23),
                          textAlign: TextAlign.center),
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(screenWidth / 21.789),
                          color: primaryColor),
                      width: screenWidth,
                      height: screenWidth / 6.179),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.transparent,
            margin: EdgeInsets.only(
                bottom: screenWidth / 17.25,
                left: screenWidth / 16.63,
                right: screenWidth / 16.63),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth / 21.789),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => RootHomeScreen()),
                      (route) => false);
                },
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                      alignment: Alignment.center,
                      child: Text("Back to Home",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: screenWidth / 23),
                          textAlign: TextAlign.center),
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(screenWidth / 21.789),
                          color: Colors.white),
                      width: screenWidth,
                      height: screenWidth / 6.179),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(children: [
        Container(
          color: Colors.white,
          height: screenHeight,
          width: screenWidth,
        ),
        Container(
          child: Column(children: [
            SizedBox(
              width: screenWidth,
              height: screenWidth / 2.79,
            ),
            SizedBox(
              height: screenWidth / 1.72,
              width: screenWidth / 1.53,
              child: Image.asset("assets/images/tick.png",
                  height: screenWidth / 1.72, width: screenWidth / 1.53),
            ),
            SizedBox(
              height: screenWidth / 5.914,
            ),
            Text(
              "Your Order has been\nAccepted",
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: screenWidth / 16.56),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: screenWidth / 20.7,
            ),
            Text(
              "Your items has been placed and is on\nit's way to being processed",
              style: TextStyle(
                  fontSize: screenWidth / 25.875, color: Color(0xFF7C7C7C)),
              textAlign: TextAlign.center,
            ),
          ]),
        )
      ]),
    );
  }
}
