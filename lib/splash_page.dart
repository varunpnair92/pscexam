import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/auth_controller.dart';
import 'package:psc_exam/psc_loading_logo.dart';
import 'dart:async';
import 'package:psc_exam/push_notification_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    _startSplashScreen();
  }

  void _startSplashScreen() async {
    // 3 second delay for splash
    await Future.delayed(const Duration(seconds: 3));

    final AuthController auth = Get.find<AuthController>();

    // 🚀 Check for Cold Start Notification
    final coldStartMessage = PushNotificationService.coldStartMessage;
    if (coldStartMessage != null && auth.isLoggedIn.value) {
      // Clear it so it doesn't trigger again
      PushNotificationService.coldStartMessage = null;
      // Handle the navigation (it will go to Home then to target)
      PushNotificationService.processNotification(
        coldStartMessage.data,
        isColdStart: true,
      );
    } else {
      // Regular navigation
      Get.offAllNamed(auth.isLoggedIn.value ? '/home' : '/home');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B8A4E);
    const lightGreen = Color(0xFFF4FBF4);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              lightGreen,
              primaryGreen.withOpacity(0.05),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PSCLoadingLogo(size: 150),
              const SizedBox(height: 48),
              const Text(
                'Prepare for Success',
                style: TextStyle(
                  color: primaryGreen,
                  fontSize: 16,
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 2,
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 100),
              Text(
                'PSC ONLINE',
                style: TextStyle(
                  color: primaryGreen.withOpacity(0.2),
                  fontSize: 12,
                  letterSpacing: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
