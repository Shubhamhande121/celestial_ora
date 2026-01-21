// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:organic_saga/constants/baseUrl.dart';
// import 'package:organic_saga/constants/constants.dart';
// import 'package:organic_saga/screens/home_screen/home_controller.dart';
// import 'package:organic_saga/screens/home_screen/root_home_screen.dart';

// class FetchLocationScreen extends StatefulWidget {
//   const FetchLocationScreen({Key? key}) : super(key: key);

//   @override
//   State<FetchLocationScreen> createState() => _FetchLocationScreenState();
// }

// class _FetchLocationScreenState extends State<FetchLocationScreen> {
//   //final _selectedZone = StateProvider<String>((ref) => "");
//   RxMap _selectedArea = {}.obs;
//   RxMap _selectedZone = {}.obs;
//   var isLoadingCity = false.obs;
//   List _zones = [];
//   HomeController homeController = Get.find();

//   List _areas = [];
//   getArea(cityId) async {
//     try {
//       _areas = [];
//       var request =
//           http.MultipartRequest('POST', Uri.parse('$baseUrl/Auth/area_list'));
//       request.fields.addAll({
//         'city_id': cityId,
//       });

//       http.StreamedResponse response = await request.send();

//       if (response.statusCode == 200) {
//         var res = await response.stream.bytesToString();
//         var data = json.decode(res);
//         _areas = data["city_list"] as List;

//         setState(() {});
//       } else {
//         print(response.reasonPhrase);
//       }
//     } catch (e) {
//       print(e);
//       _areas = [];
//     }
//   }

//   getCity() async {
//     _areas = [];
//     _selectedArea.value = {};
//     isLoadingCity.value = true;
//     var request =
//         http.MultipartRequest('GET', Uri.parse('$baseUrl/Auth/city_list'));

//     http.StreamedResponse response = await request.send();

//     if (response.statusCode == 200) {
//       var res = await response.stream.bytesToString();
//       var data = json.decode(res);
//       print(data);
//       _zones = data["city_list"] as List;

//       isLoadingCity.value = false;
//     } else {
//       print(response.reasonPhrase);
//       isLoadingCity.value = false;
//     }
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getCity();
//     homeController.fetchUser();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0.0,
//         leading: IconButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             icon: Icon(
//               Icons.keyboard_arrow_left,
//               color: Colors.black,
//             )),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Image.asset(
//               "assets/icons/location_illustration.png",
//               width: screenWidth / 1.85,
//               height: screenWidth / 2.44,
//             ),
//             SizedBox(
//               height: screenWidth / 10.35,
//               width: screenWidth,
//             ),
//             Text(
//               "Select Your Location",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   fontWeight: FontWeight.w600, fontSize: screenWidth / 15.92),
//             ),
//             SizedBox(
//               height: screenWidth / 27.6,
//             ),
//             Text(
//               "Switch on your location to stay in tune with what's happening in your area",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                   color: Color(0xFF7C7C7C), fontSize: screenWidth / 25.875),
//             ),
//             SizedBox(width: screenWidth, height: screenWidth / 4.65),
//             Obx(
//               () => isLoadingCity.value
//                   ? Column(
//                       children: [
//                         CircularProgressIndicator(),
//                         SizedBox(
//                           width: screenWidth,
//                           height: screenWidth / 13.8,
//                         ),
//                         Text("Fetching your location"),
//                       ],
//                     )
//                   : Column(
//                       children: [
//                         ListTile(
//                           onTap: () {
//                             zoneModelBottomSheet(context, screenWidth);
//                           },
//                           trailing: IconButton(
//                               onPressed: () {
//                                 zoneModelBottomSheet(context, screenWidth);
//                               },
//                               icon: Icon(Icons.keyboard_arrow_down)),
//                           title: Text("Your Zone"),
//                           subtitle: Text(_selectedZone.isEmpty
//                               ? "Tap here to select your zone"
//                               : "${_selectedZone["city"]}"),
//                         ),
//                         Container(
//                           margin: EdgeInsets.symmetric(
//                               horizontal: screenWidth / 20.7),
//                           child: Divider(
//                             thickness: 1.25,
//                           ),
//                         ),
//                         SizedBox(
//                           width: screenWidth,
//                           height: screenWidth / 13.8,
//                         ),
//                         Obx(
//                           () => ListTile(
//                               enabled: _areas.isEmpty ? false : true,
//                               onTap: () {
//                                 showModalBottomSheet(
//                                     context: context,
//                                     shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.only(
//                                             topRight: Radius.circular(
//                                                 screenWidth / 20.7),
//                                             topLeft: Radius.circular(
//                                                 screenWidth / 20.7))),
//                                     builder: (context) {
//                                       return Container(
//                                         child: Column(children: [
//                                           SizedBox(
//                                               height: screenWidth / 20.7,
//                                               width: screenWidth),
//                                           Container(
//                                               child: Row(
//                                                 mainAxisAlignment:
//                                                     MainAxisAlignment
//                                                         .spaceBetween,
//                                                 children: [
//                                                   Text(
//                                                     "Select Area",
//                                                     style: TextStyle(
//                                                         color: primaryColor,
//                                                         fontWeight:
//                                                             FontWeight.bold,
//                                                         fontSize:
//                                                             screenWidth / 20.7),
//                                                   ),
//                                                   CircleAvatar(
//                                                       backgroundColor:
//                                                           primaryColor,
//                                                       child: IconButton(
//                                                           onPressed: () {
//                                                             Navigator.of(
//                                                                     context)
//                                                                 .pop();
//                                                           },
//                                                           icon: Icon(
//                                                               Icons.close,
//                                                               color: Colors
//                                                                   .white)))
//                                                 ],
//                                               ),
//                                               margin: EdgeInsets.symmetric(
//                                                   horizontal:
//                                                       screenWidth / 20.7)),
//                                           SizedBox(height: screenWidth / 41.4),
//                                           Expanded(
//                                               child: ListView(
//                                                   children: List.generate(
//                                                       _areas.length,
//                                                       (index) => RadioListTile<
//                                                               Map<dynamic,
//                                                                   dynamic>>(
//                                                           title: Text(
//                                                               "${_areas[index]["area"]}"),
//                                                           value: _areas[index],
//                                                           groupValue:
//                                                               _selectedArea
//                                                                   .value,
//                                                           onChanged: (value) {
//                                                             _selectedArea
//                                                                     .value =
//                                                                 value as Map<
//                                                                     dynamic,
//                                                                     dynamic>;
//                                                             Timer(
//                                                                 Duration(
//                                                                     milliseconds:
//                                                                         350),
//                                                                 () {
//                                                               Navigator.of(
//                                                                       context)
//                                                                   .pop();
//                                                             });
//                                                           }))))
//                                         ]),
//                                         decoration: BoxDecoration(
//                                             borderRadius: BorderRadius.only(
//                                                 topRight: Radius.circular(
//                                                     screenWidth / 20.7),
//                                                 topLeft: Radius.circular(
//                                                     screenWidth / 20.7)),
//                                             color: Colors.white),
//                                         width: screenWidth,
//                                         height: screenWidth / 1.38,
//                                       );
//                                     });
//                               },
//                               trailing: IconButton(
//                                   onPressed: () {
//                                     showModalBottomSheet(
//                                         context: context,
//                                         shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.only(
//                                                 topRight: Radius.circular(
//                                                     screenWidth / 20.7),
//                                                 topLeft: Radius.circular(
//                                                     screenWidth / 20.7))),
//                                         builder: (context) {
//                                           return Container(
//                                             child: Column(children: [
//                                               SizedBox(
//                                                   height: screenWidth / 20.7,
//                                                   width: screenWidth),
//                                               Container(
//                                                   child: Row(
//                                                     mainAxisAlignment:
//                                                         MainAxisAlignment
//                                                             .spaceBetween,
//                                                     children: [
//                                                       Text(
//                                                         "Select Area",
//                                                         style: TextStyle(
//                                                             color: primaryColor,
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize:
//                                                                 screenWidth /
//                                                                     20.7),
//                                                       ),
//                                                       CircleAvatar(
//                                                           backgroundColor:
//                                                               primaryColor,
//                                                           child: IconButton(
//                                                               onPressed: () {
//                                                                 Navigator.of(
//                                                                         context)
//                                                                     .pop();
//                                                               },
//                                                               icon: Icon(
//                                                                   Icons.close,
//                                                                   color: Colors
//                                                                       .white)))
//                                                     ],
//                                                   ),
//                                                   margin: EdgeInsets.symmetric(
//                                                       horizontal:
//                                                           screenWidth / 20.7)),
//                                               SizedBox(
//                                                   height: screenWidth / 41.4),
//                                               Expanded(
//                                                   child: ListView(
//                                                 children: List.generate(
//                                                     _areas.length,
//                                                     (index) => Consumer(builder:
//                                                             (context, ref, _) {
//                                                           return RadioListTile<
//                                                                   Map<dynamic,
//                                                                       dynamic>>(
//                                                               title: Text(
//                                                                   "${_areas[index]["area"]}"),
//                                                               value:
//                                                                   _areas[index],
//                                                               groupValue:
//                                                                   _selectedArea
//                                                                       .value,
//                                                               onChanged:
//                                                                   (value) {
//                                                                 _selectedArea
//                                                                         .value =
//                                                                     value as Map<
//                                                                         dynamic,
//                                                                         dynamic>;

//                                                                 Navigator.of(
//                                                                         context)
//                                                                     .pop();
//                                                               });
//                                                         })),
//                                               ))
//                                             ]),
//                                             decoration: BoxDecoration(
//                                                 borderRadius: BorderRadius.only(
//                                                     topRight: Radius.circular(
//                                                         screenWidth / 20.7),
//                                                     topLeft: Radius.circular(
//                                                         screenWidth / 20.7)),
//                                                 color: Colors.white),
//                                             width: screenWidth,
//                                             height: screenWidth / 1.38,
//                                           );
//                                         });
//                                   },
//                                   icon: Icon(Icons.keyboard_arrow_down)),
//                               title: Text("Your Area"),
//                               subtitle: Text(_selectedArea.value.isEmpty
//                                   ? "Tap here to select your area"
//                                   : "${_selectedArea.value["area"]}")),
//                         ),
//                         Container(
//                           margin: EdgeInsets.symmetric(
//                               horizontal: screenWidth / 20.7),
//                           child: Divider(
//                             thickness: 1.25,
//                           ),
//                         ),
//                       ],
//                     ),
//             ),
//             SizedBox(
//               width: screenWidth,
//               height: screenWidth / 9.63,
//             ),
//             Container(
//               margin: EdgeInsets.symmetric(horizontal: screenWidth / 20.7),
//               child: ElevatedButton(
//                   style: ButtonStyle(
//                       shape: MaterialStateProperty.all(RoundedRectangleBorder(
//                           borderRadius:
//                               BorderRadius.circular(screenWidth / 21.789)))),
//                   onPressed: () {
//                     homeController.location =
//                         "${_selectedZone.value["city"]}, ${_selectedArea.value["area"]}  ";

//                     if (_zones.isNotEmpty && _selectedArea.isNotEmpty) {
//                       Navigator.of(context).pushAndRemoveUntil(
//                           MaterialPageRoute(
//                               builder: (context) => RootHomeScreen()),
//                           (route) => false);
//                     } else {
//                       Get.snackbar("Error", "Please select your location");
//                     }
//                   },
//                   child: Text("Submit")),
//               width: screenWidth,
//               height: screenWidth / 6.18,
//             ),
//             SizedBox(height: screenWidth / 13.8)
//           ],
//         ),
//       ),
//     );
//   }

//   Future<dynamic> zoneModelBottomSheet(
//       BuildContext context, double screenWidth) {
//     return showModalBottomSheet(
//         context: context,
//         shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//                 topRight: Radius.circular(screenWidth / 20.7),
//                 topLeft: Radius.circular(screenWidth / 20.7))),
//         builder: (context) {
//           return Container(
//             child: Column(children: [
//               SizedBox(height: screenWidth / 20.7, width: screenWidth),
//               Container(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Select Zone",
//                         style: TextStyle(
//                             color: primaryColor,
//                             fontWeight: FontWeight.bold,
//                             fontSize: screenWidth / 20.7),
//                       ),
//                       CircleAvatar(
//                           backgroundColor: primaryColor,
//                           child: IconButton(
//                               onPressed: () {
//                                 Navigator.of(context).pop();
//                               },
//                               icon: Icon(Icons.close, color: Colors.white)))
//                     ],
//                   ),
//                   margin: EdgeInsets.symmetric(horizontal: screenWidth / 20.7)),
//               SizedBox(height: screenWidth / 41.4),
//               Expanded(
//                   child: ListView(
//                 physics: BouncingScrollPhysics(),
//                 children: List.generate(
//                   _zones.length,
//                   (index) => RadioListTile<Map<dynamic, dynamic>>(
//                       title: Text("${_zones[index]["city"]}"),
//                       value: _zones[index],
//                       groupValue: _selectedZone.value,
//                       onChanged: (value) {
//                         _selectedZone.value = value as Map<dynamic, dynamic>;

//                         getArea(_selectedZone.value["id"].toString());
//                         _selectedArea.value = {};
//                         Navigator.of(context).pop();
//                       }),
//                 ),
//               ))
//             ]),
//             decoration: BoxDecoration(
//                 borderRadius: BorderRadius.only(
//                     topRight: Radius.circular(screenWidth / 20.7),
//                     topLeft: Radius.circular(screenWidth / 20.7)),
//                 color: Colors.white),
//             width: screenWidth,
//           );
//         });
//   }
// }
