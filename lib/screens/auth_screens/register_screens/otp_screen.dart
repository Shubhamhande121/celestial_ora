import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:organic_saga/constants/constants.dart';
import 'otp_controller.dart';

class OTPScreen extends StatelessWidget {
  OTPScreen({Key? key, required this.mobile, required this.referral})
      : super(key: key);

  final String mobile;
  final String referral;

  @override
  Widget build(BuildContext context) {
    final OTPController controller =
        Get.put(OTPController(mobile: mobile, referral: referral));

    final size = MediaQuery.of(context).size;

    /// PIN THEMES
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: size.height * 0.04),

                      /// 🔐 ICON
                      Container(
                        height: 90,
                        width: 90,
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          size: 42,
                          color: primaryColor,
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// TITLE
                      Text(
                        "OTP Verification",
                        style: TextStyle(
                          fontSize: size.width * 0.065,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 10),

                      /// SUBTITLE
                      Text(
                        "Enter the 4-digit code sent to\n+91 $mobile",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: size.width * 0.04,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: size.height * 0.05),

                      /// PIN INPUT
                      Pinput(
                        length: 4,
                        controller: controller.otpController,
                        keyboardType: TextInputType.number,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        showCursor: true,
                        onCompleted: controller.getOtpVerify,
                      ),

                      const SizedBox(height: 24),

                      /// RESEND
                      InkWell(
                        onTap: controller.resendOtp,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Text(
                            "Resend OTP",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      /// VERIFY BUTTON
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: size.height * 0.065,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    if (controller.otpController.text.length ==
                                        4) {
                                      controller.getOtpVerify(
                                        controller.otpController.text,
                                      );
                                    } else {
                                      Get.snackbar(
                                        "Invalid OTP",
                                        "Please enter 4 digit OTP",
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 4,
                            ),
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Verify & Continue",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white),
                                  ),
                          ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// class OTPScreen extends StatelessWidget {
//   OTPScreen({Key? key, required this.mobile, required this.referral})
//       : super(key: key);

//   final String mobile;
//   final String referral;

//   @override
//   Widget build(BuildContext context) {
//     final OTPController controller =
//         Get.put(OTPController(mobile: mobile, referral: referral));

//     final width = MediaQuery.of(context).size.width;

//     /// PIN THEMES
//     final defaultPinTheme = PinTheme(
//       width: 56,
//       height: 56,
//       textStyle: const TextStyle(
//         fontSize: 22,
//         fontWeight: FontWeight.w600,
//       ),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//     );

//     final focusedPinTheme = defaultPinTheme.copyWith(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: primaryColor, width: 2),
//       ),
//     );

//     final submittedPinTheme = defaultPinTheme.copyWith(
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         color: primaryColor.withOpacity(0.08),
//         border: Border.all(color: primaryColor),
//       ),
//     );

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: width * 0.08),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(height: width * 0.08),

//               /// TITLE
//               Text(
//                 "OTP Verification",
//                 style: TextStyle(
//                   fontSize: width * 0.065,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),

//               const SizedBox(height: 8),

//               /// SUBTITLE
//               Text(
//                 "Enter the 4-digit code sent to +91 $mobile",
//                 style: TextStyle(
//                   color: Colors.grey.shade600,
//                   fontSize: width * 0.04,
//                 ),
//               ),

//               SizedBox(height: width * 0.12),

//               /// PIN INPUT
//               Center(
//                 child: Pinput(
//                   length: 4,
//                   controller: controller.otpController,
//                   keyboardType: TextInputType.number,
//                   defaultPinTheme: defaultPinTheme,
//                   focusedPinTheme: focusedPinTheme,
//                   submittedPinTheme: submittedPinTheme,
//                   showCursor: true,
//                   onCompleted: (pin) {
//                     controller.getOtpVerify(pin);
//                   },
//                 ),
//               ),

//               SizedBox(height: width * 0.1),

//               /// RESEND OTP
//               Center(
//                 child: InkWell(
//                   onTap: controller.resendOtp,
//                   child: Text(
//                     "Resend OTP",
//                     style: TextStyle(
//                       color: primaryColor,
//                       fontWeight: FontWeight.w600,
//                       fontSize: width * 0.04,
//                     ),
//                   ),
//                 ),
//               ),

//               const Spacer(),

//               /// VERIFY BUTTON
//               Obx(
//                 () => GestureDetector(
//                   onTap: controller.isLoading.value
//                       ? null
//                       : () {
//                           if (controller.otpController.text.length == 4) {
//                             controller
//                                 .getOtpVerify(controller.otpController.text);
//                           } else {
//                             Get.snackbar(
//                               "Invalid OTP",
//                               "Please enter 4 digit OTP",
//                               backgroundColor: Colors.red,
//                               colorText: Colors.white,
//                             );
//                           }
//                         },
//                   child: Container(
//                     height: width * 0.15,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: primaryColor,
//                       borderRadius: BorderRadius.circular(14),
//                       boxShadow: [
//                         BoxShadow(
//                           color: primaryColor.withOpacity(0.3),
//                           blurRadius: 12,
//                           offset: const Offset(0, 6),
//                         )
//                       ],
//                     ),
//                     child: Center(
//                       child: controller.isLoading.value
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : Text(
//                               "Verify OTP",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: width * 0.045,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//               ),

//               SizedBox(height: width * 0.1),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
