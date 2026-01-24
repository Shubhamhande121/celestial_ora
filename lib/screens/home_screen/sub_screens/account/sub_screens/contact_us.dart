import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:html/parser.dart' as html_parser;

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

  /// CLEAN HTML TEXT
  String cleanHtml(String htmlText) {
    final document = html_parser.parse(htmlText);
    return document.body?.text.replaceAll('\u00A0', ' ').trim() ?? '';
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
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: const ThemedAppBar(
        title: 'Contact Us',
        showBack: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _aboutFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return _buildShimmer(screenWidth);
          }

          if (snap.hasError || snap.data == null || snap.data!.isEmpty) {
            return const Center(child: Text("No Data Found"));
          }

          final data = snap.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(screenWidth / 27.6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _contactCard(
                  icon: Icons.email_outlined,
                  title: "Email",
                  value: data["support_email"]?.toString() ?? "-",
                  screenWidth: screenWidth,
                ),
                _contactCard(
                  icon: Icons.phone_outlined,
                  title: "Phone",
                  value: data["support_number"]?.toString() ?? "-",
                  screenWidth: screenWidth,
                ),
                _contactCard(
                  icon: Icons.location_on_outlined,
                  title: "Address",
                  value: data["address"]?.toString() ?? "-",
                  screenWidth: screenWidth,
                ),
                SizedBox(height: screenWidth / 20),
                const Divider(),
                SizedBox(height: screenWidth / 25),
                Text(
                  data["site_title"]?.toString() ?? "",
                  style: TextStyle(
                    fontSize: screenWidth / 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenWidth / 30),
                Text(
                  cleanHtml(data["short_description"]?.toString() ?? ""),
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    color: Colors.black54,
                    height: 1.7,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// CONTACT CARD
  Widget _contactCard({
    required IconData icon,
    required String title,
    required String value,
    required double screenWidth,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth / 30),
      padding: EdgeInsets.all(screenWidth / 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: screenWidth / 15),
          SizedBox(width: screenWidth / 25),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: screenWidth / 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// SHIMMER UI
  Widget _buildShimmer(double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth / 27.6),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          children: List.generate(
            3,
            (_) => Container(
              margin: EdgeInsets.only(bottom: screenWidth / 25),
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
