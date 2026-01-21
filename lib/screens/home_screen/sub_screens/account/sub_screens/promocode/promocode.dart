import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/cart_controller.dart';
import 'package:shimmer/shimmer.dart';

class PromoCode extends StatefulWidget {
  const PromoCode({Key? key, this.isApplyCode = false}) : super(key: key);
  final bool isApplyCode;
  @override
  State<PromoCode> createState() => _PromoCodeState();
}

class _PromoCodeState extends State<PromoCode> {
  getPromoCode() async {
    List couponList = [];
    var request =
        http.Request('GET', Uri.parse('$baseUrl/Auth/couponcode_fetch'));

    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    log(res);
    if (response.statusCode == 200) {
      var data = jsonDecode(res);
      couponList = data["coupon_list"] as List<dynamic>;

      return couponList;
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    CartController cartController = Get.find();
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: const ThemedAppBar(
        title: 'Promo Code',
        showBack: true, // ✅ replaces the manual IconButton
      ),
      body: FutureBuilder(
          future: getPromoCode(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  itemCount: 6,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.95,
                    crossAxisSpacing: screenWidth / 20.7,
                    mainAxisSpacing: screenWidth / 20.7,
                  ),
                  itemBuilder: (context, index) {
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: index.isEven ? screenWidth / 20.7 : 0,
                          right: index.isEven ? 0 : screenWidth / 20.7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(screenWidth / 27.6),
                          border:
                              Border.all(color: primaryColor.withOpacity(0.4)),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                height: 16, width: 60, color: Colors.white),
                            const SizedBox(height: 10),
                            Container(
                                height: 16, width: 90, color: Colors.white),
                            const SizedBox(height: 10),
                            Container(
                                height: 16, width: 80, color: Colors.white),
                            const SizedBox(height: 10),
                            Container(
                                height: 30, width: 100, color: Colors.white),
                            const SizedBox(height: 10),
                            Container(
                                height: 12, width: 90, color: Colors.white),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            if (snap.hasError) {
              return Center(
                child: Text("No Data Found"),
              );
            }

            log("dadada -->> ${snap.data}");
            var couponList = snap.data as List;

            if (couponList.isEmpty) {
              return Center(
                child: Text("No Promo Code Available"),
              );
            }

            return Column(
              children: [
                SizedBox(
                  height: screenWidth / 41.4,
                  width: screenWidth,
                ),
                Expanded(
                  child: GridView.builder(
                      itemCount: couponList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: screenWidth / 20.7,
                          crossAxisCount: 2,
                          childAspectRatio: 0.95,
                          crossAxisSpacing: screenWidth / 20.7),
                      itemBuilder: (context, index) {
                        var coupon = couponList[index] as Map<String, dynamic>;
                        var endDate = DateTime.parse(coupon["end_date"]);
                        var formateDate =
                            DateFormat("dd-MMM-yy").format(endDate);

                        return GestureDetector(
                          onTap: () async {
                            if (widget.isApplyCode) {
                              cartController.selectedPromoCode.value = coupon;
                              Get.back();
                              return;
                            }
                            cartController.selectedPromoCode.value = coupon;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Apply the coupon at checkout")));
                          },
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Text(
                                //   "Weekend Offer",
                                //   style: TextStyle(
                                //       fontSize: screenWidth / 29.57,
                                //       fontWeight: FontWeight.w600),
                                //   textAlign: TextAlign.center,
                                // ),
                                SizedBox(height: screenWidth / 82.8),
                                Visibility(
                                  visible: coupon["type"] == "percentage",
                                  replacement: Text(
                                    "Rs. ${coupon["value"]}",
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                  ),
                                  child: Text("20% OFF",
                                      style: TextStyle(
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16),
                                      textAlign: TextAlign.center),
                                ),
                                SizedBox(height: screenWidth / 82.8),
                                // SizedBox(
                                //   height: screenWidth / 41.4,
                                // ),
                                Text(
                                  "Promo Code",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: screenWidth / 82.8),
                                Text("${coupon["code"]}",
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16),
                                    textAlign: TextAlign.center),
                                SizedBox(
                                  height: screenWidth / 25.875,
                                ),
                                Text(
                                  "Redeem Now",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "Expires on ${formateDate}",
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            margin: EdgeInsets.only(
                                left: index.isEven ? screenWidth / 20.7 : 0,
                                right: index.isEven ? 0 : screenWidth / 20.7),
                            decoration: BoxDecoration(
                                color: secondaryColor.withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(screenWidth / 27.6),
                                border: Border.all(color: primaryColor)),
                          ),
                        );
                      }),
                ),
              ],
            );
          }),
    );
  }
}
