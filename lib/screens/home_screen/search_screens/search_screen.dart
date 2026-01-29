// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/cart_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/product_display_screen/product_display_screen.dart';
import 'package:shimmer/shimmer.dart';

class SearchBottomSheet extends StatefulWidget {
  SearchBottomSheet({Key? key, this.scrollController}) : super(key: key);

  final ScrollController? scrollController;

  @override
  State<SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<SearchBottomSheet> {
  var isLoading = false.obs;

  var listOfSearch = [].obs;
  final TextEditingController searchController = TextEditingController();

  getSearch(search) async {
    listOfSearch.value = [];
    isLoading.value = true;
    var request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/Auth/search'));
    request.fields.addAll({'search': search});

    http.StreamedResponse response = await request.send();
    var res = await response.stream.bytesToString();
    if (response.statusCode == 200) {
      var data = jsonDecode(res);
      listOfSearch.value = data["search_list"];
    } else {
      print(response.reasonPhrase);
    }
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.9.sh, // 90% of screen height
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // small handle bar for bottom sheet

            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) => getSearch(value),
                decoration: InputDecoration(
                  hintText: "Search products, brands…",
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: InputBorder.none,
                  icon: const Icon(Icons.search, color: Colors.black54),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      searchController.clear(); // ✅ clears text
                      listOfSearch.clear(); // clears results
                      isLoading.value = false;
                    },
                  ),
                ),
              ),
            ),

            // TextField(
            //   onChanged: (value) => getSearch(value),
            //   decoration: InputDecoration(
            //     hintText: "Search for products",
            //     prefixIcon: const Icon(Icons.search),
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(18),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 10),
            // search results
            Expanded(
              child: Obx(() {
                if (isLoading.value) {
                  return GridView.builder(
                    controller: widget.scrollController,
                    itemCount: 6,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.68,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) => shimmerCard(),
                  );
                }

                if (listOfSearch.isEmpty && !isLoading.value) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 60, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        "No products found",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                } else {
                  return GridView.builder(
                    controller: widget.scrollController,
                    itemCount: listOfSearch.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.80,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final product = listOfSearch[index];
                      final variants = product["variant"] ?? [];
                      final variant = variants.isNotEmpty ? variants[0] : null;

                      return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ProductDisplayScreen(
                              id: product["productid"],
                            ),
                          ));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFFE2E2E2)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12)),
                                  child: Image.network(
                                    baseProductImageUrl +
                                        (product["productimage"] ?? ""),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      "assets/images/splash_3.png",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product["productname"] ??
                                          "Unnamed Product",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          variant != null
                                              ? "$indianRupeeSymbol ${variant['special_price']}"
                                              : "Out of Stock",
                                          style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        if (variant != null)
                                          InkWell(
                                            onTap: () {
                                              Get.find<CartController>()
                                                  .addToCart(
                                                      product["productid"],
                                                      1,
                                                      variant["id"],
                                                      context);
                                            },
                                            child: Container(
                                              height: 26,
                                              width: 26,
                                              decoration: BoxDecoration(
                                                color: primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget shimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E2E2)),
        ),
      ),
    );
  }
}
