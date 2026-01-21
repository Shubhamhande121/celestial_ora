import 'package:flutter/material.dart';
import 'package:organic_saga/constants/constants.dart';

class ThemedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? actions; // Keep this as List<Widget>

  const ThemedAppBar({
    Key? key,
    required this.title,
    this.showBack = false,
    this.onBack,
    this.actions, // remove 'required Obx trailing'
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              icon: const Icon(
                Icons.keyboard_arrow_left,
                color: Colors.white,
                size: 30,
              ),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : null,
      centerTitle: true,
      elevation: 4,
      backgroundColor: primarySwatch,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
      ),
      actions: actions,
    );
  }
}
