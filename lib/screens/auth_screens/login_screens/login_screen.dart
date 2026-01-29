import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/auth_screens/register_screens/otp_screen.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({Key? key}) : super(key: key);

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   bool isLoading = false;
//   final TextEditingController mobileController = TextEditingController();
//   final TextEditingController referralController = TextEditingController();
//   final FocusNode mobileFocus = FocusNode();

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFFFFF1F5), // soft blush
//               Colors.white,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // 🌸 Top Image
//                 SizedBox(
//                   height: size.height * 0.38,
//                   width: size.width,
//                   child: Image.asset(
//                     "assets/images/front_page.jpeg",
//                     fit: BoxFit.cover,
//                   ),
//                 ),

//                 // ✨ Login Card
//                 Transform.translate(
//                   offset: const Offset(0, -30),
//                   child: Container(
//                     padding: const EdgeInsets.all(22),
//                     margin: const EdgeInsets.symmetric(horizontal: 18),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(28),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.08),
//                           blurRadius: 20,
//                           offset: const Offset(0, 10),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // ✨ Headline
//                         const Text(
//                           "Luxury Beauty\nNow in Your Pocket",
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           "Sign in to explore Celestial Ora",
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),

//                         const SizedBox(height: 28),

//                         // 📱 Mobile Input
//                         const Text(
//                           "Mobile Number",
//                           style: TextStyle(
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         const SizedBox(height: 6),
//                         TextField(
//                           focusNode: mobileFocus,
//                           controller: mobileController,
//                           keyboardType: TextInputType.phone,
//                           inputFormatters: [
//                             LengthLimitingTextInputFormatter(10),
//                             FilteringTextInputFormatter.digitsOnly,
//                           ],
//                           decoration: InputDecoration(
//                             hintText: "Enter 10-digit number",
//                             filled: true,
//                             fillColor: Colors.grey.shade100,
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(14),
//                               borderSide: BorderSide.none,
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 18),

//                         // 🎁 Referral
//                         // const Text(
//                         //   "Referral Code (Optional)",
//                         //   style: TextStyle(
//                         //     fontWeight: FontWeight.w500,
//                         //   ),
//                         // ),
//                         //const SizedBox(height: 6),
//                         // TextField(
//                         //   controller: referralController,
//                         //   decoration: InputDecoration(
//                         //     hintText: "Enter referral code",
//                         //     filled: true,
//                         //     fillColor: Colors.grey.shade100,
//                         //     border: OutlineInputBorder(
//                         //       borderRadius: BorderRadius.circular(14),
//                         //       borderSide: BorderSide.none,
//                         //     ),
//                         //   ),
//                         // ),

//                         SizedBox(height: 15.h),

//                         // 🚀 Submit Button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 52,
//                           child: ElevatedButton(
//                             onPressed: () {
//                               if (mobileController.text.length == 10) {
//                                 getLogin(
//                                   mobileController.text,
//                                   referralController.text,
//                                 );
//                               } else {
//                                 Get.snackbar(
//                                   "Error",
//                                   "Please enter a valid mobile number",
//                                   backgroundColor: primaryColor,
//                                   colorText: Colors.white,
//                                 );
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.orange.shade700,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(18),
//                               ),
//                             ),
//                             child: isLoading
//                                 ? const CircularProgressIndicator(
//                                     color: Colors.white,
//                                   )
//                                 : const Text(
//                                     "Continue",
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   /// ✅ Send login request (mobile + referral)
//   Future<void> getLogin(String mobile, String referral) async {
//     try {
//       setState(() => isLoading = true);

//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/Auth/login_user'),
//       );
//       request.fields['mobile'] = mobile;
//       if (referral.isNotEmpty) {
//         request.fields['referalid'] = referral;
//       }

//       http.StreamedResponse response = await request.send();
//       final responseBody = await response.stream.bytesToString();
//       final data = json.decode(responseBody);

//       if (response.statusCode == 200 && data['status'] == 200) {
//         Get.snackbar(
//           "Success",
//           data['message'] ?? "OTP sent successfully",
//           backgroundColor: primaryColor,
//           colorText: Colors.white,
//           margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         );

//         // Navigate to OTP screen
//         Get.to(() => OTPScreen(
//               mobile: mobile,
//               referral: referral,
//             ));
//       } else {
//         Get.snackbar(
//           "Error",
//           data['message'] ?? "Something went wrong",
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//           margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         "Error",
//         "Something went wrong! $e",
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//         margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
// }

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController referralController = TextEditingController();
  final FocusNode mobileFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🛍️ Brand / Banner
              Container(
                height: size.height * 0.32,
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30),
                  ),
                ),
                child: Image.asset(
                  "assets/images/front_page.jpeg",
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 24),

              // 🧾 Login Card
              Container(
                padding: const EdgeInsets.all(22),
                margin: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 Title
                    const Text(
                      "Welcome to Celestial Ora",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Login or sign up to continue shopping",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 26),

                    // 📱 Mobile Field
                    const Text(
                      "Mobile Number",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      focusNode: mobileFocus,
                      controller: mobileController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.phone_android),
                        hintText: "Enter 10-digit mobile number",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // 🚀 Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (mobileController.text.length == 10) {
                            getLogin(
                              mobileController.text,
                              referralController.text,
                            );
                          } else {
                            Get.snackbar(
                              "Invalid Number",
                              "Please enter a valid 10-digit mobile number",
                              backgroundColor: Colors.black,
                              colorText: Colors.white,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            backgroundColor: primaryColor),
                        child: isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 🔐 Footer Text
                    Center(
                      child: Text(
                        "We’ll send you an OTP for verification",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// API remains SAME
  Future<void> getLogin(String mobile, String referral) async {
    try {
      setState(() => isLoading = true);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/Auth/login_user'),
      );
      request.fields['mobile'] = mobile;
      if (referral.isNotEmpty) {
        request.fields['referalid'] = referral;
      }

      http.StreamedResponse response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);

      if (response.statusCode == 200 && data['status'] == 200) {
        Get.to(() => OTPScreen(mobile: mobile, referral: referral));
      } else {
        Get.snackbar("Error", data['message'] ?? "Something went wrong");
      }
    } catch (e) {
      Get.snackbar("Error", "Something went wrong");
    } finally {
      setState(() => isLoading = false);
    }
  }
}
