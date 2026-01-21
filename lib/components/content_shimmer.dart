import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// ----------------------
/// Realistic Content Shimmer
/// Includes heading, subheading, paragraphs, and bullets
/// ----------------------
class ContentShimmer extends StatelessWidget {
  final int sections; // number of sections (heading + paragraphs)

  const ContentShimmer({Key? key, this.sections = 3}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(sections, (sectionIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Heading line
                ShimmerLine(widthFactor: 0.6, height: 20),

                const SizedBox(height: 12),

                // Subheading line
                ShimmerLine(widthFactor: 0.4, height: 16),

                const SizedBox(height: 12),

                // Paragraph lines
                ...List.generate(3 + sectionIndex, (paraLine) {
                  double widthFactor = 0.5 + (paraLine / (3 + sectionIndex)) * 0.5;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ShimmerLine(widthFactor: widthFactor, height: 16),
                  );
                }),

                const SizedBox(height: 12),

                // Bullet points
                ...List.generate(2, (bulletIndex) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 6, right: 8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: ShimmerLine(widthFactor: 0.85, height: 16),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }
}

/// Shimmer line widget
class ShimmerLine extends StatelessWidget {
  final double widthFactor; // 0.0 - 1.0
  final double height;

  const ShimmerLine({Key? key, required this.widthFactor, this.height = 16})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: screenWidth * widthFactor,
        height: height,
        color: Colors.white,
      ),
    );
  }
}
