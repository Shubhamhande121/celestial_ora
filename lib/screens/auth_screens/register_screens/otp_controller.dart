// otp_controller.dart
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/model/user_model.dart';
import 'package:organic_saga/screens/home_screen/home_controller.dart';
import 'package:organic_saga/screens/home_screen/root_home_screen.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/my_detail/my_detail.dart';
import 'package:organic_saga/shared_pref/shared_pref.dart';

class OTPController extends GetxController {
  final String mobile;
  final String referral;
  
  OTPController({required this.mobile, required this.referral});
  
  var isLoading = false.obs;
  var otpController = TextEditingController();

  /// ✅ Verify OTP API
  Future<void> getOtpVerify(String otp) async {
    isLoading.value = true;

    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/Auth/verify_otp'));

    // Add referral if present
    request.fields.addAll({
      'mobile': mobile,
      'otp': otp,
      if (referral.isNotEmpty) 'referalid': referral,
    });

    if (kDebugMode) {
      log('--- OTP API REQUEST ---');
      log('URL: ${request.url}');
      log('Fields: ${request.fields}');
    }

    try {
      http.StreamedResponse response = await request.send();
      final res = await response.stream.bytesToString();
      final data = jsonDecode(res);
      log("OTP API Response: $data");

      if (response.statusCode == 200) {
        final userId = data["userdetails"]["id"].toString();
        await SharedPref.storeUserId(userId);

        // After OTP verification → fetch profile
        await fetchUserProfile(userId);
      } else {
        Get.snackbar(
          "Error",
          data["message"] ?? "Invalid OTP",
          backgroundColor: const Color(0xFFEB5757),
          colorText: Colors.white,
          margin:
              const EdgeInsets.symmetric(horizontal: 21.789, vertical: 10.35),
        );
        isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Something went wrong: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> fetchUserProfile(String userId) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/Auth/profile_fetch'),
      );
      request.fields['users_id'] = userId;

      http.StreamedResponse response = await request.send();
      final resBody = await response.stream.bytesToString();
      final data = jsonDecode(resBody);
      log("Profile fetch API Response: $data");

      // Remove any old HomeController instance
      if (Get.isRegistered<HomeController>()) {
        Get.delete<HomeController>();
      }

      // Initialize HomeController
      HomeController homeController = Get.put(HomeController());

      // Debug logging to see what we're getting
      log("Profile details: ${data['profile_details']}");
      log("Profile details type: ${data['profile_details'].runtimeType}");

      // Check if profile exists and has required fields
      bool isExistingUser = false;

      if (data['profile_details'] != null) {
        // Check if profile_details is a List or Map
        if (data['profile_details'] is List) {
          // It's a list, check if it's not empty
          if ((data['profile_details'] as List).isNotEmpty) {
            final profileDetails = data['profile_details'][0]; // Get first item
            log("First profile detail: $profileDetails");

            // Check if the user has completed their profile
            if (profileDetails['username'] != null &&
                profileDetails['username'].toString().isNotEmpty &&
                profileDetails['email'] != null &&
                profileDetails['email'].toString().isNotEmpty) {
              isExistingUser = true;
              log("User is existing: ${profileDetails['username']}");
            }
          }
        } else if (data['profile_details'] is Map) {
          // It's a map, check if it's not empty
          if ((data['profile_details'] as Map).isNotEmpty) {
            final profileDetails = data['profile_details'];
            log("Profile detail map: $profileDetails");

            // Check if the user has completed their profile
            if (profileDetails['username'] != null &&
                profileDetails['username'].toString().isNotEmpty &&
                profileDetails['email'] != null &&
                profileDetails['email'].toString().isNotEmpty) {
              isExistingUser = true;
              log("User is existing: ${profileDetails['username']}");
            }
          }
        }
      }

      if (isExistingUser) {
        // Existing user → navigate to RootHomeScreen
        homeController.userModel.value = UserModel.fromJson(
            data['profile_details'] is List
                ? data['profile_details'][0]
                : data['profile_details']);
        isLoading.value = false;
        log("Navigating to RootHomeScreen");
        homeController.currentIndex.value = 0;
        Get.offAll(() => const RootHomeScreen());
      } else {
        // 🆕 New user → navigate to MyDetail
        isLoading.value = false;
        // Initialize empty UserModel for MyDetail
        homeController.userModel.value = UserModel();
        log("Navigating to MyDetail");
        Get.offAll(() => const MyDetail());
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Failed to fetch profile: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  /// ✅ Resend OTP API
  Future<void> resendOtp() async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/Auth/resend_otp'),
      );
      request.fields['mobile'] = mobile;

      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        Get.snackbar(
          "Success",
          "OTP resent successfully",
          backgroundColor: primaryColor,
          colorText: Colors.white,
          margin:
              const EdgeInsets.symmetric(horizontal: 21.789, vertical: 10.35),
        );
      } else {
        print("Resend OTP failed: ${response.reasonPhrase}");
      }
    } catch (e) {
      print("Exception in resendOtp: $e");
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}