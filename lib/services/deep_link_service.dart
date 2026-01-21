// import 'dart:async';

// import 'package:app_links/app_links.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:organic_saga/screens/home_screen/sub_screens/product_display_screen/product_display_screen.dart';
// import 'package:organic_saga/screens/home_screen/sub_screens/sub_home_screen/sub_home_screen.dart';
// import 'package:url_launcher/url_launcher.dart';

// class DeepLinkService {
//   static late AppLinks _appLinks;
//   static StreamSubscription<Uri>? _subscription;
//   static bool _isInitialized = false;

//   static Future<void> initDeepLinks() async {
//     if (_isInitialized) return;
    
//     _appLinks = AppLinks();
//     _isInitialized = true;

//     // Handle initial deep link (when app is opened via link)
//     await _handleInitialDeepLink();

//     // Listen for deep links while app is running
//     _subscription = _appLinks.uriLinkStream.listen(
//       _handleDeepLink,
//       onError: (error) {
//         print('Deep link error: $error');
//       },
//     );
//   }

//   static Future<void> _handleInitialDeepLink() async {
//     try {
//       final Uri? initialUri = await _appLinks.getInitialAppLink();
//       if (initialUri != null) {
//         print('Initial deep link: $initialUri');
//         await _processDeepLink(initialUri);
//       }
      
//       // Use getLatestAppLink as alternative
//       final Uri? latestUri = await _appLinks.getLatestAppLink();
//       if (latestUri != null && latestUri != initialUri) {
//         print('Latest deep link: $latestUri');
//         await _processDeepLink(latestUri);
//       }
//     } catch (e) {
//       print('Initial deep link error: $e');
//     }
//   }

//   static Future<void> _handleDeepLink(Uri uri) async {
//     print('Incoming deep link: $uri');
//     await _processDeepLink(uri);
//   }

//   static Future<void> _processDeepLink(Uri uri) async {
//     try {
//       // Add delay to ensure app is fully loaded
//       await Future.delayed(Duration(milliseconds: 500));
      
//       // Handle HTTPS URLs (Universal Links on iOS, App Links on Android)
//       if (uri.scheme == 'https' && uri.host == 'sadiyaenterprises.in') {
//         await _handleWebDeepLink(uri);
//       }
//       // Handle custom scheme URLs
//       else if (uri.scheme == 'organicsaga') {
//         await _handleAppDeepLink(uri);
//       }
//       else {
//         print('Unsupported deep link scheme: ${uri.scheme}');
//       }
//     } catch (e) {
//       print('Error processing deep link: $e');
//       Get.snackbar(
//         "Error",
//         "Failed to open link",
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   static Future<void> _handleWebDeepLink(Uri uri) async {
//     final segments = uri.pathSegments;
    
//     print('Web deep link segments: $segments');
    
//     if (segments.length >= 2 && segments[0] == 'product') {
//       final productId = segments[1];
//       await _navigateToProduct(productId);
//     }
//     // Add more routes as needed
//     else if (segments.isNotEmpty && segments[0] == 'category') {
//       final categoryId = segments.length >= 2 ? segments[1] : '';
//       await _navigateToCategory(categoryId);
//     }
//     else if (segments.isEmpty || segments[0].isEmpty) {
//       // Handle root domain - navigate to home
//       Get.until((route) => route.isFirst);
//     }
//     else {
//       print('Unknown web deep link: $uri');
//       // Fallback: open in browser
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri);
//       }
//     }
//   }

//   static Future<void> _handleAppDeepLink(Uri uri) async {
//     print('App deep link - host: ${uri.host}, path: ${uri.path}');
    
//     switch (uri.host) {
//       case 'product':
//         final productId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
//         if (productId.isNotEmpty) {
//           await _navigateToProduct(productId);
//         } else {
//           print('No product ID provided in deep link');
//         }
//         break;
        
//       case 'category':
//         final categoryId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : '';
//         if (categoryId.isNotEmpty) {
//           await _navigateToCategory(categoryId);
//         }
//         break;
        
//       case 'home':
//         Get.until((route) => route.isFirst);
//         break;
        
//       default:
//         print('Unknown app deep link: $uri');
//     }
//   }

//   static Future<void> _navigateToProduct(String productId) async {
//     // Prevent duplicate navigation
//     final currentRoute = Get.currentRoute;
//     if (currentRoute.contains('/product/') && currentRoute.contains(productId)) {
//       print('Already on product page: $productId');
//       return;
//     }
    
//     print('Navigating to product: $productId');
    
//     // Close any dialogs or bottom sheets
//     if (Get.isDialogOpen == true) Get.back();
//     if (Get.isBottomSheetOpen == true) Get.back();
    
//     // Clear previous routes and navigate to product page
//     Get.offAll(
//       () => ProductDisplayScreen(id: productId),
//       transition: Transition.cupertino,
//     );
//   }

//   static Future<void> _navigateToCategory(String categoryId) async {
//     print('Navigating to category: $categoryId');
    
//     // Prevent duplicate navigation
//     final currentRoute = Get.currentRoute;
//     if (currentRoute.contains('/category/') && currentRoute.contains(categoryId)) {
//       print('Already on category page: $categoryId');
//       return;
//     }
    
//     // Navigate to category page
//     Get.offAll(
//       () => SubHomeScreen(categoryId: categoryId),
//       transition: Transition.cupertino,
//     );
//   }

//   static bool get isInitialized => _isInitialized;

//   static void dispose() {
//     _subscription?.cancel();
//     _isInitialized = false;
//   }
// }