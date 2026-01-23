// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:http/http.dart' as http;
// import 'package:organic_saga/components/content_shimmer.dart';
// import 'package:organic_saga/components/custom_app_bar.dart';
// import 'package:organic_saga/constants/baseUrl.dart';

// class PrivacyPolicy extends StatefulWidget {
//   const PrivacyPolicy({Key? key}) : super(key: key);

//   @override
//   State<PrivacyPolicy> createState() => _PrivacyPolicyState();
// }

// class _PrivacyPolicyState extends State<PrivacyPolicy> {
//   late Future<String> _privacyFuture;

//   @override
//   void initState() {
//     super.initState();
//     _privacyFuture = _getPrivacyPolicy();
//   }
// //   String cleanHtml(String html) {
// //   // Remove font-size styles completely
// //   html = html.replaceAll(
// //     RegExp(r'font-size\s*:\s*[^;"]+;?', caseSensitive: false),
// //     '',
// //   );

// //   // Remove strong & heading tags but keep text
// //   html = html
// //       .replaceAll(RegExp(r'<\/?(strong|b|h1|h2|h3|h4|h5|h6)[^>]*>'), '');

// //   return html;
// // }

//   Future<String> _getPrivacyPolicy() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/Auth/privacy_policy_fetch'),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         if (data['privacy_policy'] != null &&
//             data['privacy_policy'].isNotEmpty) {
//           return data['privacy_policy'][0]['value'] ?? '';
//         }
//       }
//       return '';
//     } catch (e) {
//       return '';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const ThemedAppBar(
//         title: 'Privacy Policy',
//         showBack: true,
//       ),
//       body: FutureBuilder<String>(
//         future: _privacyFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const ContentShimmer(sections: 3);
//           }

//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No Data Found"));
//           }

//           return SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: HtmlWidget(
//                 snapshot.data!,

//                 // Base style for ALL text
//                 textStyle: const TextStyle(
//                   fontSize: 14,
//                   height: 1.6,
//                   color: Colors.black87,
//                   fontWeight: FontWeight.normal,
//                 ),

//                 // 🔥 Force-remove inline font sizes
//                 customStylesBuilder: (element) {
//                   return {
//                     'font-size': '14px',
//                     'font-weight': 'normal',
//                     'line-height': '1.6',
//                   };
//                 },

//                 // 🔥 Remove strong/bold effect
//                 // customTextStyle: (node, baseStyle) {
//                 //   return baseStyle.copyWith(
//                 //     fontSize: 14,
//                 //     fontWeight: FontWeight.normal,
//                 //   );
//                 // },
//               ));
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:organic_saga/components/custom_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: ThemedAppBar(
        title: "Privacy Policy",
        showBack: true,
        onBack: () {},
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _TitleText("Catestial Ora Privacy Policy"),
                    SizedBox(height: 12),
                    _BodyText(
                      "At Catestial Ora, we value your privacy and are committed to protecting your personal information. "
                      "This Privacy Policy explains how we collect, use, and safeguard your data.",
                    ),
                    SizedBox(height: 24),
                    _SectionTitle("1. Information We Collect"),
                    _BodyText(
                      "We may collect personal information such as your name, email address, phone number, shipping address, "
                      "and payment details when you place an order or contact us.",
                    ),
                    SizedBox(height: 16),
                    _SectionTitle("2. How We Use Your Information"),
                    _Bullet("To process and deliver your orders"),
                    _Bullet("To communicate order and service updates"),
                    _Bullet("To improve our products and services"),
                    _Bullet("To provide customer support"),
                    SizedBox(height: 16),
                    _SectionTitle("3. Cookies & Tracking"),
                    _BodyText(
                      "We may use cookies and similar technologies to improve your browsing experience "
                      "and analyze website traffic.",
                    ),
                    SizedBox(height: 16),
                    _SectionTitle("4. Data Sharing"),
                    _BodyText(
                      "We do not sell your personal information. Data may only be shared with trusted partners "
                      "such as payment gateways and delivery services when necessary.",
                    ),
                    SizedBox(height: 16),
                    _SectionTitle("5. Data Security"),
                    _BodyText(
                      "We implement appropriate security measures to protect your data against unauthorized access.",
                    ),
                    SizedBox(height: 16),
                    _SectionTitle("6. Your Rights"),
                    _BodyText(
                      "You have the right to access, update, or request deletion of your personal information.",
                    ),
                    SizedBox(height: 16),
                    _SectionTitle("7. Policy Updates"),
                    _BodyText(
                      "This Privacy Policy may be updated from time to time. Changes will be reflected on this page.",
                    ),
                    SizedBox(height: 24),
                    Divider(),
                    SizedBox(height: 12),
                    _BodyText(
                      "If you have any questions about this Privacy Policy, please contact us at:\n"
                      "📧 support@catestialora.com",
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleText extends StatelessWidget {
  final String text;
  const _TitleText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;
  final bool isBold;

  const _BodyText(this.text, {this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
        color: Colors.black87,
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
