import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(milliseconds: 500), () {
//       mobileFocus.requestFocus();
//       pasteFromClipboard();
//     });
//   }

//   @override
//   void dispose() {
//     mobileFocus.dispose();
//     mobileController.dispose();
//     referralController.dispose();
//     super.dispose();
//   }

//   Future<void> pasteFromClipboard() async {
//     ClipboardData? clipboardData =
//         await Clipboard.getData(Clipboard.kTextPlain);
//     if (clipboardData != null &&
//         clipboardData.text != null &&
//         clipboardData.text!.length >= 8) {
//       setState(() {
//         referralController.text = clipboardData.text!;
//       });
//     }
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

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;

//     return SafeArea(
//       child: Scaffold(
//         resizeToAvoidBottomInset: true,
//         body: Stack(
//           children: [
//             Column(
//               children: [
//                 SizedBox(
//                   height: screenWidth / 1.41,
//                   width: screenWidth,
//                   child: Image.asset("assets/images/front_page.jpeg"),
//                 ),
//               ],
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 SizedBox(height: screenWidth / 1.38),
//                 Padding(
//                   padding:
//                       EdgeInsets.symmetric(horizontal: screenWidth / 21.78),
//                   child: Text(
//                     "Luxury Beauty\nNow in Your Pocket.",
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: screenWidth / 15.92,
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: screenWidth / 17.25),
//                 Padding(
//                   padding:
//                       EdgeInsets.symmetric(horizontal: screenWidth / 21.78),
//                   child: Text(
//                     "Enter Mobile Number",
//                     style: TextStyle(
//                       color: const Color(0xFF2C2C2C),
//                       fontSize: screenWidth / 29.57,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding:
//                       EdgeInsets.symmetric(horizontal: screenWidth / 21.78),
//                   child: TextField(
//                     focusNode: mobileFocus,
//                     controller: mobileController,
//                     keyboardType: TextInputType.phone,
//                     autofillHints: [AutofillHints.telephoneNumber],
//                     inputFormatters: [
//                       LengthLimitingTextInputFormatter(10),
//                       FilteringTextInputFormatter.digitsOnly,
//                     ],
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                     decoration: const InputDecoration(
//                       hintText: "9999999999",
//                       hintStyle: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black38,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: EdgeInsets.only(
//                     left: screenWidth / 21.78,
//                     right: screenWidth / 21.78,
//                     top: 4,
//                   ),
//                   child: Align(
//                     alignment: Alignment.centerRight,
//                     child: ValueListenableBuilder<TextEditingValue>(
//                       valueListenable: mobileController,
//                       builder: (context, value, child) {
//                         return Text(
//                           "${value.text.length} / 10",
//                           style: const TextStyle(
//                               color: Colors.grey, fontSize: 12),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: screenWidth / 16.8),
//                 Padding(
//                   padding:
//                       EdgeInsets.symmetric(horizontal: screenWidth / 21.78),
//                   child: Text(
//                     "Referral Code (Optional)",
//                     style: TextStyle(
//                       color: const Color(0xFF2B2B2B),
//                       fontSize: screenWidth / 29.57,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding:
//                       EdgeInsets.symmetric(horizontal: screenWidth / 21.78),
//                   child: TextFormField(
//                     controller: referralController,
//                     decoration: const InputDecoration(
//                       hintText: "YEFHJGGCHFUT",
//                       hintStyle: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black38,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: screenWidth / 13.8),
//                 Padding(
//                   padding:
//                       EdgeInsets.symmetric(horizontal: screenWidth / 21.78),
//                   child: SizedBox(
//                     width: screenWidth,
//                     height: screenWidth / 6.17,
//                     child: ElevatedButton.icon(
//                       style: ButtonStyle(
//                         shape: WidgetStateProperty.all(
//                           RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(21.789),
//                           ),
//                         ),
//                       ),
//                       onPressed: () {
//                         if (mobileController.text.length == 10) {
//                           getLogin(
//                               mobileController.text, referralController.text);
//                         } else {
//                           Get.snackbar(
//                             "Error",
//                             "Please enter valid mobile number",
//                             backgroundColor: primaryColor,
//                             colorText: Colors.white,
//                             margin: const EdgeInsets.symmetric(
//                                 horizontal: 20, vertical: 10),
//                           );
//                         }
//                       },
//                       icon: isLoading
//                           ? const SizedBox.shrink()
//                           : const Icon(Icons.arrow_forward),
//                       label: isLoading
//                           ? const CircularProgressIndicator(
//                               color: Colors.white)
//                           : const Text("Submit"),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: screenWidth / 20.7),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
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
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFF1F5), // soft blush
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 🌸 Top Image
                SizedBox(
                  height: size.height * 0.38,
                  width: size.width,
                  child: Image.asset(
                    "assets/images/front_page.jpeg",
                    fit: BoxFit.cover,
                  ),
                ),

                // ✨ Login Card
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    margin: const EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✨ Headline
                        const Text(
                          "Luxury Beauty\nNow in Your Pocket",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Sign in to explore Celestial Ora",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // 📱 Mobile Input
                        const Text(
                          "Mobile Number",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          focusNode: mobileFocus,
                          controller: mobileController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(10),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: "Enter 10-digit number",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // 🎁 Referral
                        const Text(
                          "Referral Code (Optional)",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: referralController,
                          decoration: InputDecoration(
                            hintText: "Enter referral code",
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // 🚀 Submit Button
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
                                  "Error",
                                  "Please enter a valid mobile number",
                                  backgroundColor: primaryColor,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Continue",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Send login request (mobile + referral)
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
        Get.snackbar(
          "Success",
          data['message'] ?? "OTP sent successfully",
          backgroundColor: primaryColor,
          colorText: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        );

        // Navigate to OTP screen
        Get.to(() => OTPScreen(
              mobile: mobile,
              referral: referral,
            ));
      } else {
        Get.snackbar(
          "Error",
          data['message'] ?? "Something went wrong",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Something went wrong! $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
