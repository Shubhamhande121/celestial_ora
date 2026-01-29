// import 'package:flutter/material.dart';
// import 'package:organic_saga/constants/constants.dart';

// class ThemedAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final bool showBack;
//   final VoidCallback? onBack;
//   final List<Widget>? actions; // Keep this as List<Widget>

//   const ThemedAppBar({
//     Key? key,
//     required this.title,
//     this.showBack = false,
//     this.onBack,
//     this.actions, // remove 'required Obx trailing'
//   }) : super(key: key);

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       automaticallyImplyLeading: false,
//       leading: showBack
//           ? IconButton(
//               icon: const Icon(
//                 Icons.keyboard_arrow_left,
//                 color: Colors.white,
//                 size: 30,
//               ),
//               onPressed: onBack ?? () => Navigator.of(context).pop(),
//             )
//           : null,
//       centerTitle: true,
//       elevation: 4,
//       backgroundColor: primarySwatch,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           bottom: Radius.circular(20),
//         ),
//       ),
//       title: Text(
//         title,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 20,
//           fontWeight: FontWeight.w600,
//           fontFamily: fontFamily,
//         ),
//       ),
//       actions: actions,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/home_screen/sub_screens/cart/cart_controller.dart';

class ThemedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBack;
  final VoidCallback? onBack;

  final VoidCallback? onSearchTap;
  final VoidCallback? onCartTap;
  // final VoidCallback? onAccountTap;

  final bool actions; // Keep this as List<Widget>

  ThemedAppBar(
      {super.key,
      this.title,
      this.showBack = false,
      this.onBack,
      this.onSearchTap,
      this.onCartTap,
      // this.onAccountTap,

      this.actions = false});

  // @override
  // Size get preferredSize => const Size.fromHeight(95);

  final cartController = Get.put(CartController());

  @override
  Size get preferredSize {
    // Total AppBar height
    // default AppBar height = kToolbarHeight = 56
    final double baseHeight = kToolbarHeight;
    return Size.fromHeight(actions ? baseHeight + 40 : baseHeight);
    // 56 + 40 = 96 if actions true
    // 56 if actions false
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE1B025), // 🌟 main gold
              Color(0xFFC9971A), // deep gold
              Color(0xFF5A3A00), // luxury dark
            ],
          ),
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(24),
          ),
        ),
      ),
      leading: showBack
          ? IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: onBack ?? () => Get.back(),
            )
          : null,
      centerTitle: true,
      title: Text(
        title ?? '',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
      actions: [
        // // 👤 Account
        // GestureDetector(
        //   onTap: onAccountTap, // navigate to profile / login
        //   child: Padding(
        //     padding: const EdgeInsets.only(right: 8, top: 10),
        //     child: const Icon(
        //       Icons.person_outline_rounded,
        //       color: Colors.white,
        //       size: 28,
        //     ),
        //   ),
        // ),

        GestureDetector(
          onTap: onCartTap,
          child: Padding(
            padding: const EdgeInsets.only(right: 14, top: 10),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 26,
                ),
                Obx(() {
                  final count = cartController.cartItemCount;
                  if (count == 0) return const SizedBox.shrink();

                  return Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Text(
                        count > 9 ? "9+" : count.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
      bottom: actions
          ? PreferredSize(
              preferredSize: const Size.fromHeight(55),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: GestureDetector(
                  onTap: onSearchTap,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: Colors.black54, size: 22),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Tap to search products & brands",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Container(
                        //   padding:
                        //       const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        //   decoration: BoxDecoration(
                        //     color: const Color(0xFFE1B025),
                        //     borderRadius: BorderRadius.circular(10),
                        //   ),
                        //   child: const Text(
                        //     "Search",
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 11,
                        //       fontWeight: FontWeight.w700,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

// class ThemedAppBar extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final String? subtitle;
//   final bool showBack;
//   final VoidCallback? onBack;
//   final List<Widget>? actions;

//   const ThemedAppBar({
//     Key? key,
//     required this.title,
//     this.subtitle,
//     this.showBack = false,
//     this.onBack,
//     this.actions,
//   }) : super(key: key);

//   @override
//   Size get preferredSize => const Size.fromHeight(78);

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       automaticallyImplyLeading: false,
//       elevation: 0,
//       backgroundColor: Colors.transparent,
//       flexibleSpace: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFFE1B025), // your gold
//               Color(0xFFC9971A), // deep gold
//               Color(0xFF5A3A00), // luxury dark
//             ],
//           ),
//           borderRadius: BorderRadius.vertical(
//             bottom: Radius.circular(22),
//           ),
//         ),
//       ),

//       leading: showBack
//           ? Padding(
//               padding: const EdgeInsets.only(left: 8),
//               child: IconButton(
//                 icon: const Icon(
//                   Icons.arrow_back_ios_new_rounded,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//                 onPressed: onBack ?? () => Navigator.of(context).pop(),
//               ),
//             )
//           : null,

//       centerTitle: true,

//       title: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               fontFamily: fontFamily,
//               letterSpacing: 0.3,
//             ),
//           ),
//           if (subtitle != null)
//             Text(
//               subtitle!,
//               style: TextStyle(
//                 color: Colors.white.withOpacity(0.85),
//                 fontSize: 12,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//         ],
//       ),

//       actions: actions,

//       // ✨ Smooth bottom shadow effect
//       bottom: PreferredSize(
//         preferredSize: const Size.fromHeight(8),
//         child: Container(
//           height: 8,
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.05),
//             borderRadius: const BorderRadius.vertical(
//               bottom: Radius.circular(22),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
