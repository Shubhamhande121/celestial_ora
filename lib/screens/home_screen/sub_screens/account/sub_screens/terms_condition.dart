import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:organic_saga/components/content_shimmer.dart';
import 'package:organic_saga/components/custom_app_bar.dart';
import 'package:organic_saga/constants/baseUrl.dart';

class TermsCondition extends StatefulWidget {
  const TermsCondition({Key? key}) : super(key: key);

  @override
  State<TermsCondition> createState() => _TermsConditionState();
}

class _TermsConditionState extends State<TermsCondition> {
  Future<String> getTermsCondition() async {
    try {
      final request =
          http.Request('GET', Uri.parse('$baseUrl/Auth/terms_condition'));
      final response = await request.send();

      if (response.statusCode == 200) {
        final res = await response.stream.bytesToString();
        final data = jsonDecode(res);
        return data["terms_condition"][0]["value"];
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
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: const ThemedAppBar(
        title: 'Terms & Conditions',
        showBack: true,
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: getTermsCondition(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: ContentShimmer(sections: 4),
              );
            }

            if (!snap.hasData || snap.data == null) {
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
                child: HtmlWidget(
                  snap.data!,
                  textStyle: const TextStyle(
                    fontSize: 15,
                    height: 1.7,
                    color: Colors.black87,
                  ),
                  customStylesBuilder: (element) {
                    switch (element.localName) {
                      case 'h1':
                        return {
                          'font-size': '20px',
                          'font-weight': '600',
                          'margin': '16px 0 10px 0'
                        };
                      case 'h2':
                        return {
                          'font-size': '18px',
                          'font-weight': '600',
                          'margin': '14px 0 8px 0'
                        };
                      case 'p':
                        return {
                          'font-size': '15px',
                          'line-height': '1.7',
                          'margin': '0 0 12px 0'
                        };
                      case 'ul':
                        return {
                          'padding-left': '0',
                          'margin-left': '0',
                          'list-style-position': 'inside',
                        };
                      case 'li':
                        return {
                          'margin-left': '0',
                          'padding-left': '0',
                          'font-size': '15px',
                          'margin-bottom': '8px',
                        };
                    }
                    return null;
                  },
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
          Icon(Icons.description_outlined, size: 52, color: Colors.grey),
          SizedBox(height: 14),
          Text(
            "Terms & Conditions not available",
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
