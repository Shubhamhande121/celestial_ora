import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:organic_saga/constants/constants.dart';
import 'package:organic_saga/screens/auth_screens/register_screens/local_notification_service.dart';
import 'package:organic_saga/screens/home_screen/home_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/account/sub_screens/notifications/notification_controller.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/product_display_screen/WishlistController.dart';
import 'package:organic_saga/screens/home_screen/sub_screens/cart/cart_controller.dart';
import 'package:organic_saga/screens/splashscreen/splash_screen.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ CRITICAL: Performance optimizations
  debugProfileBuildsEnabled = false;
  debugProfilePaintsEnabled = false;
  debugRepaintRainbowEnabled = false;
  
  // ✅ Increase image cache for multiple product images
  PaintingBinding.instance.imageCache.maximumSizeBytes = 1024 * 1024 * 500; // 500MB for 60+ products
  
  // ✅ Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // ✅ Initialize Flutter Downloader
  await FlutterDownloader.initialize(
    debug: false, // ❌ CHANGE TO FALSE FOR PRODUCTION
    ignoreSsl: true,
  );

  // ✅ Initialize local notifications
  await LocalNotificationService.init();

  // ✅ FIX: INITIALIZE ALL REQUIRED CONTROLLERS HERE
  // This prevents "Controller not found" errors
  Get.put(HomeController(), permanent: true);
  Get.put(CartController(), permanent: true);
  Get.put(NotificationController(), permanent: true);
  Get.put(WishlistController(), permanent: true);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Force portrait orientation
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: false,
            primarySwatch: primarySwatch,
            fontFamily: fontFamily,
            scaffoldBackgroundColor: Colors.white,
            // ✅ Disable splash effects for better performance
            splashFactory: NoSplash.splashFactory,
          ),
          // ✅ Now all controllers are already initialized
          home: const SplashScreen(),
        );
      },
    );
  }
}