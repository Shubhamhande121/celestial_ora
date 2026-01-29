import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/home_screen/home_controller.dart';
import 'package:organic_saga/screens/home_screen/root_home_screen.dart';
import 'package:organic_saga/shared_pref/shared_pref.dart';

class MyDetail extends StatefulWidget {
  const MyDetail({Key? key}) : super(key: key);

  @override
  State<MyDetail> createState() => _MyDetailState();
}

class _MyDetailState extends State<MyDetail> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    HomeController homeController = Get.find();

    _nameController.text = homeController.userModel.value.username ?? "";
    _emailController.text = homeController.userModel.value.email ?? "";
  }

  updateProfile() async {
    HomeController homeController = Get.find();
    isLoading.value = true;
    var userId = await SharedPref.getUserId();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/Auth/profile_update'),
    );

    request.fields.addAll({
      'users_id': userId!,
      'username': _nameController.text,
      'email': _emailController.text,
    });

    http.StreamedResponse response = await request.send();
    String resBody = await response.stream.bytesToString();
    log("Profile update response: $resBody");

    if (response.statusCode == 200) {
      // Update local model instantly
      HomeController homeController = Get.find();
      var updatedUser = homeController.userModel.value;

      updatedUser.username = _nameController.text;
      updatedUser.email = _emailController.text;

      homeController.userModel.value = updatedUser;
      homeController.userModel.refresh();

      isLoading.value = false;

      // Navigate to RootHomeScreen instead of going back
      Get.offAll(() => const RootHomeScreen());

      Get.snackbar(
        "Success",
        "Profile Updated Successfully",
        colorText: Colors.white,
        backgroundColor: primaryColor,
      );
    } else {
      isLoading.value = false;
      log("Profile update failed: ${response.reasonPhrase}");
    }
  }

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();

    return Scaffold(
      appBar: ThemedAppBar(
        showBack: true,
        title: 'Profile',
        onBack: () {
          Get.offAll(() => const RootHomeScreen());
        },
      ),
      body: Obx(
        () {
          if (homeController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 20.h),

                        // Profile Avatar
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 48.r,
                              backgroundColor: primaryColor.withOpacity(0.15),
                              child: Icon(Icons.person,
                                  size: 48.sp, color: primaryColor),
                            ),
                            Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.edit,
                                  size: 14.sp, color: Colors.white),
                            ),
                          ],
                        ),

                        12.h.verticalSpace,

                        Text(
                          homeController.userModel.value.username ??
                              "Your Name",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Text(
                          homeController.userModel.value.mobile ?? "",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 40.h),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Profile Information",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          8.h.verticalSpace,
                          Divider(color: Colors.grey.shade200),
                          20.h.verticalSpace,

                          // Name field
                          TextFormField(
                            controller: _nameController,
                            validator: (value) => value!.isEmpty
                                ? "Please enter your name"
                                : null,
                            decoration: InputDecoration(
                              labelText: "Full Name",
                              prefixIcon:
                                  Icon(Icons.person_outline, size: 20.sp),
                              filled: true,
                              fillColor: const Color(0xFFF6F7F9),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 14.h),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Email field
                          TextFormField(
                            controller: _emailController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value!.isEmpty) return "Please enter email";
                              if (!value.isEmail)
                                return "Please enter valid email";
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Email Address",
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: const Color(0xFFF6F7F9),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 14.h),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14.r),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Update button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            elevation: 8,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                            ),
                            minimumSize: const Size(double.infinity, 10)),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            updateProfile();
                          }
                        },
                        child: Obx(
                          () => isLoading.value
                              ? const SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : const Text(
                                  "Update Profile",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.3, duration: 700.ms);
        },
      ),
    );
  }
}
