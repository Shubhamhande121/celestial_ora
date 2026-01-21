import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    Key? key,
    required this.title,
    required this.onPressed,
    this.showSeeAll = true,
    required double screenWidth,
  }) : super(key: key);

  final String title;
  final VoidCallback onPressed;
  final bool showSeeAll;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive scaling based on screen width
    double fontSize = screenWidth * 0.045; // Title font size
    double underlineWidth = screenWidth * 0.25; // Underline width
    double buttonFontSize = screenWidth * 0.035; // Button font size

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.03,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title with underline
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: screenWidth * 0.01),
              Container(
                height: 3,
                width: underlineWidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade100, Colors.pink.shade400],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
