import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/components/content_shimmer.dart';
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/constants/baseUrl.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  Future<String> getPrivacyPolicy() async {
    try {
      var request =
          http.Request('GET', Uri.parse('$baseUrl/Auth/privacy_policy_fetch'));
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var res = await response.stream.bytesToString();
        var data = jsonDecode(res);
        return data["privacy_policy"][0]["value"];
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
      appBar: ThemedAppBar(
        title: 'Privacy Policy',
        showBack: true,
      ),
      body: FutureBuilder<String>(
        future: getPrivacyPolicy(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            // Use your new reusable ContentShimmer
            return const ContentShimmer(sections: 3);
          }

          if (snap.hasError || snap.data == null) {
            return const Center(child: Text("No Data Found"));
          }

          // Real content
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: HtmlWidget(snap.data!),
          );
        },
      ),
    );
  }
}
