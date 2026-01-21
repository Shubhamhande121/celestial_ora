import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLogo extends StatefulWidget {
  final double width;
  final double height;
  final Duration shimmerDuration;

  const ShimmerLogo({
    Key? key,
    this.width = 200,
    this.height = 200,
    this.shimmerDuration = const Duration(seconds: 1),
  }) : super(key: key);

  @override
  _ShimmerLogoState createState() => _ShimmerLogoState();
}

class _ShimmerLogoState extends State<ShimmerLogo> {
  bool _showImage = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.shimmerDuration, () {
      if (mounted) {
        setState(() {
          _showImage = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _showImage
            ? Image.asset(
                "assets/images/logo.png",
                key: const ValueKey('logo'),
                height: widget.height,
                width: widget.width,
                fit: BoxFit.contain,
              )
            : Shimmer.fromColors(
                key: const ValueKey('shimmer'),
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: widget.height,
                  width: widget.width,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
      ),
    );
  }
}
