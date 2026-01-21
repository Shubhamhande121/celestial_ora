import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/orders/orders.dart';

import '../../../../../../../constants/constants.dart';

class TrackOrder extends StatefulWidget {
  const TrackOrder({Key? key, this.orderDetails}) : super(key: key);
  final dynamic orderDetails;

  @override
  State<TrackOrder> createState() => _TrackOrderState();
}

class _TrackOrderState extends State<TrackOrder> {
  var address = <String, dynamic>{}.obs;

  Future<List<dynamic>> getOrderDetails() async {
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/Auth/order_details'));
    request.fields.addAll(
      {
        'order_id': widget.orderDetails["id"],
        'address_id': widget.orderDetails["address_id"]
      },
    );

    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();

    log(res.toString());
    if (response.statusCode == 200) {
      var data = jsonDecode(res);

      address.value = data["order_details"]["address"] ?? {};
      return data["order_details"]["details"] as List<dynamic>;
    } else {
      print(response.reasonPhrase);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.orderDetails["status"]);
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor, // from your constants
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.keyboard_arrow_left,
            color: Colors.white, // Contrast against orange
            size: 30,
          ),
        ),
        title: Text(
          "Track Order",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: fontFamily,
          ),
          textAlign: TextAlign.center,
        ),
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: screenWidth / 20.7,
              width: screenWidth,
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                "Order ID : ${widget.orderDetails["order_no"]}",
                style: TextStyle(
                    fontSize: screenWidth / 23, fontWeight: FontWeight.w600),
              ),
              margin: EdgeInsets.symmetric(horizontal: screenWidth / 20.7),
            ),
            SizedBox(
              height: screenWidth / 82.8,
              width: screenWidth,
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                convertDateFromString(
                  widget.orderDetails["order_date"],
                ),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: screenWidth / 27.6,
                ),
              ),
              margin: EdgeInsets.symmetric(horizontal: screenWidth / 20.7),
            ),
            // Container(
            //   color: Colors.transparent,
            //   margin: EdgeInsets.symmetric(horizontal: screenWidth / 20.7),
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(screenWidth / 21.789),
            //     child: InkWell(
            //       onTap: () {
            //         // Navigator.of(context).push(
            //         //     MaterialPageRoute(builder: (context) => OrderAccepted()));
            //       },
            //       child: Material(
            //         color: Colors.transparent,
            //         child: Container(
            //             padding:
            //                 EdgeInsets.symmetric(horizontal: screenWidth / 20.7),
            //             alignment: Alignment.centerLeft,
            //             child: Text(
            //               "Arriving at 12.45 PM Today",
            //               style: TextStyle(
            //                   color: Colors.white,
            //                   fontWeight: FontWeight.w500,
            //                   fontSize: screenWidth / 25.875),
            //             ),
            //             decoration: BoxDecoration(
            //                 borderRadius:
            //                     BorderRadius.circular(screenWidth / 21.789),
            //                 color: primaryColor),
            //             width: screenWidth,
            //             height: screenWidth / 6.179),
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(
              height: screenWidth / 18,
              width: screenWidth,
            ),
            IndividualOrderTimeLine(
              screenWidth: screenWidth,
              title: "Ordered",
              isCompleted: widget.orderDetails["status"] == "Placed" ||
                  widget.orderDetails["status"] == "Packed" ||
                  widget.orderDetails["status"] == "Shipped" ||
                  widget.orderDetails["status"] == "Delivered",
            ),
            IndividualOrderTimeLine(
              screenWidth: screenWidth,
              title: "Packed",
              isCompleted: widget.orderDetails["status"] == "Packed" ||
                  widget.orderDetails["status"] == "Shipped" ||
                  widget.orderDetails["status"] == "Delivered",
            ),
            IndividualOrderTimeLine(
              screenWidth: screenWidth,
              title: "Shipped",
              isCompleted: widget.orderDetails["status"] == "Shipped" ||
                  widget.orderDetails["status"] == "Delivered",
            ),
            IndividualOrderTimeLine(
              screenWidth: screenWidth,
              title: "Delivered",
              isCompleted: widget.orderDetails["status"] == "Delivered",
              isEnd: true,
            ),

            SizedBox(
              width: screenWidth,
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth / 20.7),
              child: Row(
                children: [
                  Text(
                    "Order Details",
                    style: TextStyle(
                      fontSize: screenWidth / 24.35,
                    ),
                  ),
                  Spacer(),
                  Text(
                    "Total : ${indianRupeeSymbol} ${widget.orderDetails["amount"]}",
                    style: TextStyle(
                      fontSize: screenWidth / 24.35,
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Container(
              margin: EdgeInsets.symmetric(horizontal: screenWidth / 20.35),
              decoration: BoxDecoration(
                  color: Color(0xFFF5FEF8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFE8D8BA))),
              child: Column(
                children: [
                  FutureBuilder<List<dynamic>>(
                      future: getOrderDetails(),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (!snap.hasData) {
                          return Container();
                        }

                        return ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: snap.data!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${(index + 1)}. ".toString()),
                                    SizedBox(
                                      width: 4,
                                    ),
                                    Expanded(
                                      child: Text(
                                        snap.data![index]["product_name"],
                                        style: TextStyle(
                                          fontSize: screenWidth / 27.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Text(
                                  "     ${snap.data![index]["qty"]} x ${indianRupeeSymbol} ${snap.data![index]["special_price"]}",
                                  style: TextStyle(
                                    fontSize: screenWidth / 27.6,
                                  ),
                                ),
                              );
                            });
                      }),
                  SizedBox(
                    width: screenWidth,
                    height: 30,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: screenWidth,
              height: 20,
            ),

            Obx(
              () => address.isEmpty
                  ? SizedBox()
                  : Container(
                      padding: EdgeInsets.symmetric(
                          vertical: screenWidth / 23,
                          horizontal: screenWidth / 10.35),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Shipping Address",
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth / 24.35),
                          ),
                          SizedBox(
                            width: screenWidth,
                            height: screenWidth / 41.4,
                          ),
                          Text(
                              "${address["name"]}, ${address["phone"]},  ${address["area"]},  ${address["address1"]} ${address["city"]}, ${address["state"]}, ${address["pincode"]}")
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Color(0xFFF5FEF8),
                          borderRadius:
                              BorderRadius.circular(screenWidth / 41.4),
                          border: Border.all(color: Color(0xFFE8D8BA))),
                      margin:
                          EdgeInsets.symmetric(horizontal: screenWidth / 18.81),
                      width: screenWidth,
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class IndividualOrderTimeLine extends StatelessWidget {
  const IndividualOrderTimeLine({
    Key? key,
    required this.screenWidth,
    required this.title,
    this.isEnd = false,
    this.isCompleted = false,
  }) : super(key: key);

  final double screenWidth;
  final String title;
  final bool isEnd, isCompleted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Row(children: [
            Container(
              height: screenWidth / 18,
              width: screenWidth / 18,
              decoration: BoxDecoration(
                  color: isCompleted ? secondaryColor : Color(0xFFFAFAFA),

                  border: Border.all(
                      width: 0.2,
                      color: isCompleted ? secondaryColor : Colors.black,),

                  borderRadius: BorderRadius.circular(screenWidth / 18)),
              child: isCompleted
                  ? Icon(
                      Icons.done,
                      size: screenWidth / 34.5,
                      color: Colors.white,
                    )
                  : Container(),
            ),
            SizedBox(
              width: screenWidth / 13.8,
            ),
            Text(
              "$title",
              style: TextStyle(fontSize: screenWidth / 27.6),
            )
          ]),
          margin: EdgeInsets.symmetric(horizontal: screenWidth / 20.7),
        ),
        isEnd
            ? Container()
            : Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth / 20.7),
                child: Row(
                  children: [
                    Container(
                      margin:
                          EdgeInsets.symmetric(vertical: screenWidth / 82.8),
                      child: Container(
                        color: Color(0xFF000000),
                        width: 0.6,
                        height: screenWidth / 6.9,
                      ),
                      width: screenWidth / 18,
                      height: screenWidth / 6.9,
                      alignment: Alignment.center,
                    ),
                  ],
                ),
              ),
      ],
    );
  }
}
