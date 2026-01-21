import 'package:flutter/material.dart';
import 'package:organic_saga/components/custom_back_button.dart';

class FAQDetail extends StatefulWidget {
  const FAQDetail({Key? key}) : super(key: key);

  @override
  State<FAQDetail> createState() => _FAQDetailState();
}

class _FAQDetailState extends State<FAQDetail> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: CustomBackButton(),
        backgroundColor: Colors.white,
        title: Text(
          "Return & Refund Policy",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(
            top: screenWidth / 27.6,
            left: screenWidth / 27.6,
            right: screenWidth / 27.6),
        height: screenHeight,
        width: screenWidth,
        child: SingleChildScrollView(
          child: Text(
            "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. \n\nLorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. ",
            style: TextStyle(fontSize: screenWidth / 27.6),
          ),
        ),
      ),
    );
  }
}
