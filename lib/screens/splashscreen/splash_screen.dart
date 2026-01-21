import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:organic_saga/screens/auth_screens/login_screens/login_screen.dart';
import 'package:organic_saga/screens/home_screen/home_controller.dart';
import 'package:organic_saga/shared_pref/shared_pref.dart';
import '../home_screen/root_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final List<Color> gradientColors = [
    Color(0xFFFFF5E1), // light cream
    Color(0xFFFFEFC4), // soft cream
    Color(0xFFFFE7A8), // slightly darker cream
  ];

  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();

    // Animation controller for pop-up + fade
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _decideNextScreen();
  }

  Future<void> _decideNextScreen() async {
    SharedPref.getUserId().then((value) {
      log(">>>User Id  $value");
      Future.delayed(const Duration(seconds: 3), () {
        if (value != null) {
          Get.put(HomeController());
          Get.offAll(
            () => const RootHomeScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(seconds: 1),
          );
        } else {
          Get.offAll(
            () => const LoginScreen(),
            transition: Transition.fadeIn,
            duration: const Duration(seconds: 1),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnim.value,
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: Container(
                    height: screenWidth / 2.5,
                    width: screenWidth / 2.5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: 
                    Image.asset(
                      "assets/images/logo.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
