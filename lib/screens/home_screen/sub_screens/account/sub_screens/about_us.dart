import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/components/content_shimmer.dart';
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/constants/baseUrl.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  Future<String> getAboutUs() async {
    try {
      final request =
          http.Request('GET', Uri.parse('$baseUrl/Auth/about_fetch'));
      final response = await request.send();

      if (response.statusCode == 200) {
        final res = await response.stream.bytesToString();
        final data = jsonDecode(res);
        return data["about_us"][0]["value"];
      } else {
        return "No Data Found";
      }
    } catch (e) {
      return "No Data Found";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA), // soft background
      appBar: const ThemedAppBar(
        title: 'About Us',
        showBack: true,
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: getAboutUs(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: ContentShimmer(sections: 3),
              );
            }

            if (!snap.hasData || snap.data == null) {
              return _emptyState();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: HtmlWidget(
                  snap.data!,
                  textStyle: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Empty / Error UI
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.info_outline, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "No information available",
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
