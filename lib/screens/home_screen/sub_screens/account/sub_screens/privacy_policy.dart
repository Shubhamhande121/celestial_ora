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
  late Future<String> _privacyFuture;

  @override
  void initState() {
    super.initState();
    _privacyFuture = _getPrivacyPolicy();
  }
//   String cleanHtml(String html) {
//   // Remove font-size styles completely
//   html = html.replaceAll(
//     RegExp(r'font-size\s*:\s*[^;"]+;?', caseSensitive: false),
//     '',
//   );

//   // Remove strong & heading tags but keep text
//   html = html
//       .replaceAll(RegExp(r'<\/?(strong|b|h1|h2|h3|h4|h5|h6)[^>]*>'), '');

//   return html;
// }

  Future<String> _getPrivacyPolicy() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Auth/privacy_policy_fetch'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['privacy_policy'] != null &&
            data['privacy_policy'].isNotEmpty) {
          return data['privacy_policy'][0]['value'] ?? '';
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ThemedAppBar(
        title: 'Privacy Policy',
        showBack: true,
      ),
      body: FutureBuilder<String>(
        future: _privacyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ContentShimmer(sections: 3);
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Data Found"));
          }

          return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: HtmlWidget(
                snapshot.data!,

                // Base style for ALL text
                textStyle: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black87,
                  fontWeight: FontWeight.normal,
                ),

                // 🔥 Force-remove inline font sizes
                customStylesBuilder: (element) {
                  return {
                    'font-size': '14px',
                    'font-weight': 'normal',
                    'line-height': '1.6',
                  };
                },

                // 🔥 Remove strong/bold effect
                // customTextStyle: (node, baseStyle) {
                //   return baseStyle.copyWith(
                //     fontSize: 14,
                //     fontWeight: FontWeight.normal,
                //   );
                // },
              ));
        },
      ),
    );
  }
}
