import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:shimmer/shimmer.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({Key? key}) : super(key: key);

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  late Future<Map<String, dynamic>> _aboutFuture;

  @override
  void initState() {
    super.initState();
    _aboutFuture = getAboutUs();
  }

  Future<Map<String, dynamic>> getAboutUs() async {
    final request =
        http.Request('GET', Uri.parse('$baseUrl/Auth/contactus_fetch'));
    final response = await request.send();

    if (response.statusCode == 200) {
      final res = await response.stream.bytesToString();
      final decoded = json.decode(res);
      final list = decoded["contactus_details"] as List?;
      if (list == null || list.isEmpty) return {};
      final rawValue = list[0]["value"];
      if (rawValue is String && rawValue.trim().isNotEmpty) {
        return Map<String, dynamic>.from(json.decode(rawValue));
      } else if (rawValue is Map) {
        return Map<String, dynamic>.from(rawValue);
      }
      return {};
    } else {
      debugPrint(response.reasonPhrase);
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: ThemedAppBar(
        title: 'Contact Us',
        showBack: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _aboutFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            // SHIMMER PLACEHOLDER
            return Padding(
              padding: EdgeInsets.only(
                top: screenWidth / 27.6,
                left: screenWidth / 27.6,
                right: screenWidth / 27.6,
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ShimmerListTileLine(
                      widthTitle: screenWidth * 0.25,
                      widthSubtitle: screenWidth * 0.50,
                    ),
                    SizedBox(height: screenWidth / 20),
                    _ShimmerListTileLine(
                      widthTitle: screenWidth * 0.25,
                      widthSubtitle: screenWidth * 0.40,
                    ),
                    SizedBox(height: screenWidth / 20),
                    _ShimmerListTileLine(
                      widthTitle: screenWidth * 0.25,
                      widthSubtitle: double.infinity,
                      lines: 2,
                    ),
                    SizedBox(height: screenWidth / 13.8),
                    const Divider(),
                    SizedBox(height: screenWidth / 20),
                    Container(
                        height: 20,
                        width: screenWidth * 0.40,
                        color: Colors.white),
                    SizedBox(height: screenWidth / 27.6),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        3,
                        (_) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                              height: 14,
                              width: double.infinity,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snap.hasError || snap.data == null || snap.data!.isEmpty) {
            return const Center(child: Text("No Data Found"));
          }

          final data = snap.data!;
          return Container(
            margin: EdgeInsets.only(
              top: screenWidth / 27.6,
              left: screenWidth / 27.6,
              right: screenWidth / 27.6,
            ),
            height: screenHeight,
            width: screenWidth,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    title: Text(
                      "Email",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth / 20.92,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(data["support_email"]?.toString() ?? "-"),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    title: Text(
                      "Phone",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth / 20.92,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(data["support_number"]?.toString() ?? "-"),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    title: Text(
                      "Address",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth / 20.92,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(data["address"]?.toString() ?? "-"),
                  ),
                  const Divider(),
                  SizedBox(height: screenWidth / 41.4),
                  Text(
                    data["site_title"]?.toString() ?? "",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: screenWidth / 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: screenWidth / 41.4),
                  Text(
                    data["short_description"]?.toString() ?? "",
                    style: const TextStyle(
                      color: Colors.black45,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShimmerListTileLine extends StatelessWidget {
  const _ShimmerListTileLine({
    required this.widthTitle,
    required this.widthSubtitle,
    this.lines = 1,
  });

  final double widthTitle;
  final double widthSubtitle;
  final int lines;

  @override
  Widget build(BuildContext context) {
    final subs = List.generate(lines, (i) {
      return Padding(
        padding: EdgeInsets.only(bottom: i == lines - 1 ? 0 : 6),
        child: Container(
          height: 14,
          width: widthSubtitle,
          color: Colors.white,
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 18, width: widthTitle, color: Colors.white),
        const SizedBox(height: 8),
        ...subs,
      ],
    );
  }
}
