import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/components/content_shimmer.dart';
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/constants/baseUrl.dart';
import 'package:html/parser.dart' as html_parser;

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

  Future<String> _getPrivacyPolicy() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/Auth/privacy_policy_fetch'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['privacy_policy'] != null &&
            data['privacy_policy'].isNotEmpty) {
          return _stripHtml(data['privacy_policy'][0]['value'] ?? '');
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  /// 🔥 Remove HTML tags safely
  String _stripHtml(String htmlText) {
    final RegExp exp = RegExp(r'<[^>]*>', multiLine: true);
    return htmlText.replaceAll(exp, '').replaceAll('&nbsp;', ' ').trim();
  }

  String removeHtmlTags(String htmlText) {
    final document = html_parser.parse(htmlText);
    return document.body?.text ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: const ThemedAppBar(
        title: 'Privacy Policy',
        showBack: true,
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _privacyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: ContentShimmer(sections: 4),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _emptyState();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
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
                child: SelectableText(
                  snapshot.data!,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: Colors.black87,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.privacy_tip_outlined, size: 52, color: Colors.grey),
          SizedBox(height: 14),
          Text(
            "Privacy Policy not available",
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
