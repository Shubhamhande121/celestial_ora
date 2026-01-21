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
      var request = http.Request('GET', Uri.parse('$baseUrl/Auth/about_fetch'));
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var res = await response.stream.bytesToString();
        var data = jsonDecode(res);
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
      appBar: const ThemedAppBar(
        title: 'About Us',
        showBack: true,
      ),
      body: SafeArea(
        // <-- Wrap in SafeArea to avoid overlap
        child: FutureBuilder<String>(
          future: getAboutUs(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              // Use reusable ContentShimmer
              return const ContentShimmer(sections: 3);
            }

            if (snap.hasError || snap.data == null) {
              return const Center(child: Text("No Data Found"));
            }

            // Real content
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: HtmlWidget(
                snap.data!,
                textStyle: const TextStyle(
                  fontSize: 14,  
                  color: Colors.black,  
                  fontWeight: FontWeight.w400,
                  height: 1.5, // line height
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
