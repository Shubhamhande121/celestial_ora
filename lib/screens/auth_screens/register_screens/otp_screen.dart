// otp_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:organic_saga/constants/constants.dart';
import 'otp_controller.dart';

class OTPScreen extends StatelessWidget {
  OTPScreen({Key? key, required this.mobile, required this.referral})
      : super(key: key);

  final String mobile;
  final String referral;

  @override
  Widget build(BuildContext context) {
     final OTPController controller = Get.put(OTPController(mobile: mobile, referral: referral));
    
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.keyboard_arrow_left, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(width: screenWidth, height: screenWidth / 13.8),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: screenWidth / 16.56),
              child: Text(
                'Enter your 4-digit code',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth / 15.92,
                    fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(height: screenWidth / 14.79),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.symmetric(horizontal: screenWidth / 16.56),
              child: Text(
                "Code",
                style: TextStyle(
                    color: const Color(0xFF7C7C7C),
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth / 25.875),
              ),
            ),
            SizedBox(height: screenWidth / 41.4),
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth / 16.56),
              child: TextField(
                controller: controller.otpController,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(4),
                  FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                ],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "- - - -"),
              ),
            ),
            Expanded(child: Container()),
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth / 16.56),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: controller.resendOtp,
                    child: Text(
                      "Resend Code",
                      style: TextStyle(
                          color: primaryColor,
                          fontSize: screenWidth / 23,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  Obx(() => CircleAvatar(
                    radius: (screenWidth / 6.18) / 2,
                    backgroundColor: primaryColor,
                    child: IconButton(
                      onPressed: () {
                        if (controller.otpController.text.isNotEmpty) {
                          controller.getOtpVerify(controller.otpController.text);
                        } else {
                          Get.snackbar(
                            "Error",
                            "Please enter OTP",
                            backgroundColor: const Color(0xFFEB5757),
                            colorText: Colors.white,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 21.789, vertical: 10.35),
                          );
                        }
                      },
                      icon: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.keyboard_arrow_right,
                              color: Colors.white),
                    ),
                  )),
                ],
              ),
            ),
            SizedBox(height: screenWidth / 13.8),
          ],
        ),
      ),
    );
  }
}