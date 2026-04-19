import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/push_notification_service.dart';
import 'package:psc_exam/auth_controller.dart';

class NotificationPermissionPage extends StatefulWidget {
  const NotificationPermissionPage({super.key});

  @override
  State<NotificationPermissionPage> createState() => _NotificationPermissionPageState();
}

class _NotificationPermissionPageState extends State<NotificationPermissionPage> with WidgetsBindingObserver {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // If we return from settings, check permission automatically
    if (state == AppLifecycleState.resumed) {
      _checkAndNavigate();
    }
  }

  Future<void> _checkAndNavigate() async {
    final hasPermission = await PushNotificationService.hasPermission();
    if (hasPermission) {
      final auth = Get.find<AuthController>();
      Get.offAllNamed(auth.isLoggedIn.value ? '/home' : '/login');
    }
  }

  Future<void> _handlePermission() async {
    setState(() => _isChecking = true);
    
    final granted = await PushNotificationService.requestPermission();
    
    if (granted) {
      await _checkAndNavigate();
    } else {
      // If still not granted, it might be permanently denied
      // Show a snackbar or dialog to open settings
      Get.snackbar(
        "Permission Required",
        "Please enable notifications in your phone settings to continue using the app.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.black,
        duration: const Duration(seconds: 5),
        mainButton: TextButton(
          onPressed: () => PushNotificationService.openSettings(),
          child: const Text("SETTINGS", style: TextStyle(color: Color(0xFF1B8A4E), fontWeight: FontWeight.bold)),
        ),
      );
    }
    
    if (mounted) setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1B8A4E);
    const lightGreen = Color(0xFFF4FBF4);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, lightGreen, primaryGreen.withOpacity(0.1)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔔 Icon with Glassmorphic feel
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  size: 100,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 48),
              
              const Text(
                "Don't Miss Out!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              const Text(
                "To give you the best experience, we need to send you notifications for:",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              
              _buildFeatureRow(Icons.update_rounded, "Latest Exam Updates"),
              _buildFeatureRow(Icons.description_rounded, "New Study Materials"),
              _buildFeatureRow(Icons.campaign_rounded, "Important Announcements"),
              
              const Spacer(),
              
              // 🚀 Grant Permission Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _handlePermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  child: _isChecking
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "ALLOW NOTIFICATIONS",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: () => PushNotificationService.openSettings(),
                child: const Text(
                  "Open Device Settings",
                  style: TextStyle(
                    color: primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1B8A4E)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
