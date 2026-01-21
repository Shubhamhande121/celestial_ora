import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/home_screen/home_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/orders/sub_screens/track_order.dart';
import 'package:organic_saga/shared_pref/shared_pref.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shimmer/shimmer.dart';

class Orders extends StatefulWidget {
  const Orders({Key? key}) : super(key: key);

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  Future<List> getOrderList() async {
    var userId = await SharedPref.getUserId();
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/Auth/my_order_list'),
    );
    request.fields.addAll({'user_id': userId!});

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      var listOfOrder = jsonDecode(res)["order_list"] as List;
      return listOfOrder.reversed.toList();
    } else {
      print(response.reasonPhrase);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    HomeController homeController = Get.find();
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.keyboard_arrow_left,
            color: Colors.white, // Matches theme contrast
            size: 30,
          ),
        ),
        title: Text(
          "My Orders",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: fontFamily,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      body: FutureBuilder<List>(
        future: getOrderList(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 6,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 14,
                                  width: 120,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  height: 12,
                                  width: 80,
                                  color: Colors.white,
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  height: 12,
                                  width: 60,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 80,
                            height: 30,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("No Order Found"),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      homeController.currentIndex.value = 0;
                    },
                    child: Text("Order Now"),
                  ),
                ],
              ),
            );
          }
          var listOfOrder = snap.data as List;
          return listOfOrder.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      Spacer(),
                      Text("No Order Found"),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                          homeController.currentIndex.value = 0;
                        },
                        child: Text("Order Now"),
                      ),
                      Spacer(),
                    ],
                  ),
                )
              : ListView(
                  children: List.generate(
                    listOfOrder.length,
                    (index) => IndividualOrderBuilder(
                      orderDetails: listOfOrder[index],
                      screenWidth: screenWidth,
                      imageURL: "${listOfOrder[index]["image"]}",
                      orderDate: "${listOfOrder[index]["order_date"]}",
                      description: "${listOfOrder[index]["description"]}",
                      cost: "${listOfOrder[index]["amount"]}",
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                TrackOrder(orderDetails: listOfOrder[index]),
                          ),
                        );
                      },
                      index: index,
                      orderNo: "${listOfOrder[index]["order_no"]}",
                    ),
                  ),
                );
        },
      ),
    );
  }
}

String convertDateFromString(String strDate) {
  DateTime todayDate = DateTime.parse(strDate);
  return "${todayDate.day}-${todayDate.month}-${todayDate.year} ";
}

class IndividualOrderBuilder extends StatelessWidget {
  const IndividualOrderBuilder({
    Key? key,
    required this.screenWidth,
    required this.imageURL,
    required this.orderDate,
    required this.description,
    required this.cost,
    required this.onPressed,
    required this.index,
    required this.orderNo,
    required this.orderDetails,
  }) : super(key: key);

  final double screenWidth;
  final int index;
  final String imageURL, orderDate, description, cost, orderNo;
  final dynamic orderDetails;
  final VoidCallback onPressed;

  Future<void> downloadFile(String documentUrl) async {
    try {
      Directory? path = await getExternalStorageDirectory();

      String localPath = path!.path;
      final savedDir = Directory(localPath);

      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        await savedDir.create(recursive: true);
      }

      final taskId = await FlutterDownloader.enqueue(
        url: documentUrl,
        savedDir: localPath,
        fileName:
            "downloaded_file_${DateTime.now().millisecondsSinceEpoch}.pdf",
        saveInPublicStorage: true,
        showNotification: true,
        openFileFromNotification: true,
      );

      if (taskId != null) {
        FlutterDownloader.open(taskId: taskId);
      }

      Get.snackbar(
        "Downloaded",
        "Check File Manager or Downloads folder",
        colorText: Colors.white,
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(12),
      );
    } catch (err) {
      print("Download error: $err");
      Get.snackbar("Download Failed", err.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenWidth / 41.4),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 0.5,
                blurRadius: 0.5,
                offset: Offset(0, 0.5), // changes position of shadow
              ),
            ],
          ),
          // margin: EdgeInsets.only(
          //     top: index == 0 ? screenWidth / 13.8 : 0,
          //     bottom: screenWidth / 13.8),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 5.0,
                horizontal: 16,
              ),
              child: Column(
                children: [
                  SizedBox(height: 5),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // SizedBox(
                      //   child: Image.network("${baseImageUrl + imageURL}"),
                      //   height: screenWidth / 6.57,
                      //   width: screenWidth / 4.019,
                      // ),
                      // SizedBox(
                      //   height: screenWidth / 4.26,
                      //   width: screenWidth / 27.6,
                      // ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Order: $orderNo",
                            style: TextStyle(fontSize: 15, color: Colors.black),
                          ),
                          SizedBox(height: 5),
                          Text(
                            convertDateFromString(orderDate),
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "$indianRupeeSymbol $cost",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Expanded(child: Container()),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (orderDetails["invoice_pdf"] != null)
                            GestureDetector(
                              onTap: () {
                                //download pdf
                                _launchUrl(
                                  "${baseInvoiceUrl + orderDetails["invoice_pdf"]}",
                                );
                                log(
                                  "${baseInvoiceUrl + orderDetails["invoice_pdf"]}",
                                );
                                downloadFile(
                                  "${baseInvoiceUrl + orderDetails["invoice_pdf"]}",
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                  color: Colors.green,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(7.0),
                                  child: Row(
                                    children: [
                                      Icon(Icons.download, color: Colors.white),
                                      Text(
                                        " Invoice",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Text("Track Order"),
                              Icon(Icons.keyboard_arrow_right),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
