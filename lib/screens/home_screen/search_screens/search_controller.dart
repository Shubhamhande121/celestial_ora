// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'package:organic_saga/constants/baseUrl.dart';

// class SearchController extends GetxController {
//   var isLoading = false.obs;
//   var listOfSearch = <dynamic>[].obs;  

//   Future<void> getSearch(String search) async {
//     if (search.isEmpty) {
//       listOfSearch.clear();
//       return;
//     }

//     isLoading.value = true;
//     listOfSearch.clear();

//     try {
//       var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/Auth/search'));
//       request.fields.addAll({'search': search});

//       var response = await request.send();
//       var resString = await response.stream.bytesToString();

//       if (response.statusCode == 200) {
//         var data = jsonDecode(resString);
//         listOfSearch.value = data["search_list"] ?? [];
//       } else {
//         print('Error: ${response.reasonPhrase}');
//       }
//     } catch (e) {
//       print('Exception: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void clearSearch() {
//     listOfSearch.clear();
//   }
// }
