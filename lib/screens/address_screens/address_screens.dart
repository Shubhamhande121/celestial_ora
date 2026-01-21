// ignore_for_file: invalid_use_of_protected_member
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/components/utils.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/address_screens/address_edit.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/cart_controller.dart';
import 'package:organic_saga/shared_pref/shared_pref.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({Key? key, this.isBack = false}) : super(key: key);
  final bool isBack;

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late Future<List> _addressFuture;

  @override
  void initState() {
    super.initState();
    _addressFuture = fetchAddressList();
  }

  Future<List> fetchAddressList() async {
    final userId = await SharedPref.getUserId();
    log("UserID: $userId");

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/Auth/address_fetch'),
    );
    request.fields.addAll({'users_id': userId!});

    final response = await request.send();
    final res = await response.stream.bytesToString();
    log("Address Response: $res");

    if (response.statusCode == 200) {
      final data = jsonDecode(res);
      return data["address_details"] ?? [];
    } else {
      return [];
    }
  }

  Future<void> deleteAddress(String id) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/Auth/address_delete'),
    );
    request.fields.addAll({'address_id': id});

    final response = await request.send();
    if (response.statusCode == 200) {
      final updatedList = await fetchAddressList();
      setState(() {
        _addressFuture = Future.value(updatedList);
      });
    } else {
      log("Delete Error: ${response.reasonPhrase}");
    }
  }

  void update() {
    setState(() {
      _addressFuture = fetchAddressList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final CartController cartController = Get.find();

    return Scaffold(
      appBar: const ThemedAppBar(
        title: 'My Address',
        showBack: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        onPressed: () {
          Get.to(() => EditAddressScreen(
                address: {},
                isAddressEdit: false,
                function: update,
              ));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
      body: FutureBuilder<List>(
        future: _addressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                height: 50.h,
                width: 50.w,
                child: CircularProgressIndicator(color: Colors.orange.shade900),
              ),
            );
          }

          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Address Found'));
          }

          return Padding(
            padding: EdgeInsets.all(12.w),
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final address = snapshot.data![index];

                return Obx(() {
                  final isSelected =
                      cartController.selectedAddress.value == address;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 4,
                    shadowColor: Colors.orange.shade200.withOpacity(0.7),
                    color: isSelected
                        ? primaryColor.withOpacity(0.95)
                        : Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.r),
                      onTap: () {
                        cartController.selectedAddress.value = address;
                        if (widget.isBack) Get.back();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(14.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- Name + Action Buttons ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  address['name'] ?? '',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                                Row(
                                  children: [
                                    _iconCircle(
                                      icon: Icons.edit,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.blueAccent,
                                      onTap: () {
                                        Get.to(() => EditAddressScreen(
                                              address: address,
                                              isAddressEdit: true,
                                              function: update,
                                            ));
                                      },
                                    ),
                                    SizedBox(width: 10.w),
                                    _iconCircle(
                                      icon: Icons.delete,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.redAccent,
                                      onTap: () {
                                        showWarningDialog(
                                          () {
                                            Get.back();
                                            deleteAddress(address['id']);
                                          },
                                          "Delete Address",
                                          "Are you sure you want to delete this address?",
                                          context,
                                          () => Navigator.of(context).pop(),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),

                            // --- Phone ---
                            Text(
                              "📞 ${address['phone'] ?? ''}",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.black87,
                              ),
                            ),
                            SizedBox(height: 6.h),

                            // --- Full Address ---
                            Text(
                              "📍 ${address['address1'] ?? ''}, ${address['city'] ?? ''} - ${address['pincode'] ?? ''}",
                              style: TextStyle(
                                fontSize: 12.5.sp,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.85)
                                    : Colors.black54,
                              ),
                            ),
                            SizedBox(height: 12.h),

                            // --- Address Type Chip ---
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : primaryColor.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  (address["type_address"]
                                          ?.toString()
                                          .capitalizeFirst) ??
                                      "Other",
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? primaryColor
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          );
        },
      ),
    );
  }

  /// 🔹 Helper widget for circular icon buttons
  Widget _iconCircle({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(10.w),
        child: Icon(icon, size: 20.sp, color: color),
      ),
    );
  }
}
