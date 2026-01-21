import 'package:flutter/material.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/orders/sub_screens/track_order.dart';

class OrderCancel extends StatefulWidget {
  const OrderCancel({Key? key}) : super(key: key);

  @override
  State<OrderCancel> createState() => _OrderCancelState();
}

class _OrderCancelState extends State<OrderCancel> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      bottomNavigationBar: Container(
        color: Colors.transparent,
        margin: EdgeInsets.only(
            bottom: screenWidth / 17.25,
            left: screenWidth / 16.63,
            right: screenWidth / 16.63),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth / 21.789),
          child: InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => TrackOrder()));
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                  alignment: Alignment.center,
                  child: Text("Check Status",
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontSize: screenWidth / 24.35),
                      textAlign: TextAlign.center),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(screenWidth / 21.789),
                      color: primaryColor),
                  width: screenWidth,
                  height: screenWidth / 6.179),
            ),
          ),
        ),
      ),
      body: Stack(children: [
        Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/images/Mask_Group.png"))),
          height: screenHeight,
          width: screenWidth,
        ),
        SafeArea(
            child: Column(
          children: [
            SizedBox(
              width: screenWidth,
              height: screenWidth / 2.79,
            ),
            SizedBox(
              height: screenWidth / 1.72,
              width: screenWidth / 1.53,
              child: Image.asset("assets/images/cancel.png",
                  height: screenWidth / 1.72, width: screenWidth / 1.53),
            ),
            SizedBox(
              height: screenWidth / 5.914,
            ),
            Text(
              "Your Order has been\nFailed",
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: screenWidth / 16.56),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: screenWidth / 20.7,
            ),
            Text(
              "Something went wrong",
              style: TextStyle(
                  fontSize: screenWidth / 25.875, color: Color(0xFF7C7C7C)),
              textAlign: TextAlign.center,
            ),
          ],
        ))
      ]),
    );
  }
}
