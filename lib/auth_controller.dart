import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app_config.dart';
import 'push_notification_service.dart';
import 'ad_controller.dart';

class AuthController extends GetxController with WidgetsBindingObserver {
  static AuthController get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Rxn<User> firebaseUser = Rxn<User>();
  
  // 👤 User state
  var userId = 1.obs;
  var userName = "".obs;
  var fullName = "".obs;
  var userType = "free".obs; 
  var phone = "".obs; // 📱 ADD THIS
  var email = "".obs; // 📧 ADD THIS
  var courses = <int>[].obs; // 📚 ADD THIS
  var selectedCourseId = 0.obs; // 🎯 ADD THIS
  var selectedCourseName = "LDC".obs; // 🎯 ADD THIS
  var subscriptionPlanName = "free".obs; // 💎 ADD THIS
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this); // 🔥 Observer
    firebaseUser.bindStream(_auth.authStateChanges());
    loadSession();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this); // 🔥 Clean up
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 🔄 REFRESH ON RESUME
    if (state == AppLifecycleState.resumed) {
      _checkNotificationPermission();
      if (isLoggedIn.value) {
        loadSession();
      }
    }
  }

  Future<void> _checkNotificationPermission() async {
    // Don't check if we are already on the permission page
    if (Get.currentRoute == '/notificationPermission') return;
    
    final bool hasPermission = await PushNotificationService.hasPermission();
    if (!hasPermission) {
      Get.offAllNamed('/notificationPermission');
    }
  }

  // 💾 Load from SharedPreferences
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    userId.value = prefs.getInt('userid') ?? 1;
    userName.value = prefs.getString('username') ?? "";
    fullName.value = prefs.getString('fullname') ?? "";
    userType.value = prefs.getString('userType') ?? "free";
    phone.value = prefs.getString('phone') ?? ""; // 📱 ADD
    email.value = prefs.getString('email') ?? ""; // 📧 ADD
    courses.value = (prefs.getStringList('courses') ?? []).map((e) => int.parse(e)).toList(); // 📚 ADD
    selectedCourseId.value = prefs.getInt('selectedCourseId') ?? 0; // 🎯 ADD
    selectedCourseName.value = prefs.getString('selectedCourseName') ?? "LDC"; // 🎯 ADD
    subscriptionPlanName.value = prefs.getString('subscriptionPlanName') ?? "free"; // 💎 ADD
    isLoggedIn.value = prefs.getBool('isLoggedIn') ?? false;

    // 🔄 FRESH FETCH FROM SERVER (Each time app starts)
    if (isLoggedIn.value && userName.value.isNotEmpty) {
      try {
        bool stillExists = await fetchUserDetails(userName.value);
        if (!stillExists) {
          // User was deleted or not found, clear session
          await signOut();
        }
      } catch (_) {
        // Silently fail if network is down, keep existing session data
      }
    }
  }

  // 💾 Save to SharedPreferences (Legacy/Compact)
  Future<void> saveSession(int id, String user, String full, String type) async {
    return saveSessionExtra(id, user, full, type, user, "", []);
  }

  // 🚀 Save to SharedPreferences (Enhanced)
  Future<void> saveSessionExtra(int id, String user, String full, String type, String emailVal, String phoneVal, List<int> courseList, {String planName = "free"}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userid', id);
    await prefs.setString('username', user);
    await prefs.setString('fullname', full);
    await prefs.setString('userType', type);
    await prefs.setString('email', emailVal);
    await prefs.setString('phone', phoneVal);
    await prefs.setStringList('courses', courseList.map((e) => e.toString()).toList());
    await prefs.setString('subscriptionPlanName', planName); // 💎 ADD
    
    // 🎯 Use existing selection or default to first
    if ((prefs.getInt('selectedCourseId') ?? 0) == 0 && courseList.isNotEmpty) {
      await prefs.setInt('selectedCourseId', courseList.first);
      selectedCourseId.value = courseList.first;
    }

    await prefs.setBool('isLoggedIn', true);
    
    userId.value = id;
    userName.value = user;
    fullName.value = full;
    userType.value = type;
    email.value = emailVal;
    phone.value = phoneVal;
    courses.value = courseList;
    subscriptionPlanName.value = planName; // 💎 ADD
    isLoggedIn.value = true;

    // 🔔 Trigger FCM token registration
    PushNotificationService.initialize();
  }

  // 🔥 Google Login
  Future<void> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // 🌐 Web specific: Use signInWithPopup for better reliability
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
        Get.dialog(const Center(child: CircularProgressIndicator(color: Color(0xFF1B8A4E))), barrierDismissible: false);
      } else {
        // 📱 Mobile specific: Use google_sign_in plugin
        final GoogleSignInAccount? googleUser = await GoogleSignIn(
          clientId: '613180327334-cfu7uttjotlftkv2o206jb4j1i1o8djp.apps.googleusercontent.com',
        ).signIn();
        
        if (googleUser == null) {
          return;
        }

        Get.dialog(const Center(child: CircularProgressIndicator(color: Color(0xFF1B8A4E))), barrierDismissible: false);

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      final email = userCredential.user?.email;
      final displayName = userCredential.user?.displayName;

      if (email != null) {
        bool exists = await fetchUserDetails(email);
        if (Get.isDialogOpen ?? false) Get.back();
        if (exists) {
          Get.offAllNamed('/home');
        } else {
          // 🆕 Redirect to registration
          Get.offAllNamed('/register', arguments: {
            'email': email,
            'name': displayName ?? "",
          });
        }
      } else {
        if (Get.isDialogOpen ?? false) Get.back();
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        "Login Error", 
        "Failed to sign in. Please check your connection.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // 🌍 Fetch details from API
  Future<bool> fetchUserDetails(String email) async {
    try {
      final res = await http.get(Uri.parse("${AppConfig.getUserDetails}$email/"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final String role = (data['userType'] ?? data['user_type'] ?? "trial").toString().toLowerCase().trim(); // Default to trial
        
        final profile = data['profile'] ?? {};
        final String userPhone = profile['phone_number'] ?? "";
        final List<int> userCourses = List<int>.from(profile['courses'] ?? []);

        final planDetails = data['subscription_plan_details'] ?? {};
        final String planName = (planDetails['name'] ?? "free").toString().toLowerCase().trim();

        await saveSessionExtra(
          data['userid'] ?? 1,
          data['username'] ?? email,
          data['fullname'] ?? data['username'] ?? "User",
          role,
          email, // Use username as email
          userPhone,
          userCourses,
          planName: planName,
        );
        // 🚀 Trigger Ad Popup 1 minute after successful login
        if (Get.isRegistered<AdController>()) {
          Future.delayed(const Duration(minutes: 1), () {
            Get.find<AdController>().fetchAndShowAd(force: true);
          });
        }
        
        return true;
      } else if (res.statusCode == 404) {
        return false; // User needs registration
      } else {
        // Other errors, potential guest mode
        await saveSession(1, email, "Guest User", "free");
        return true; 
      }
    } catch (_) {
      await saveSession(1, email, "Guest User", "free");
      return true;
    }
  }

  // 🔥 Logout
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    isLoggedIn.value = false;
    userId.value = 1;
    userName.value = "";
    fullName.value = "";
    userType.value = "free";
    selectedCourseId.value = 0;
    selectedCourseName.value = "LDC";
    subscriptionPlanName.value = "free";
    
    Get.offAllNamed('/login');
  }

  // 🎯 UPDATE SELECTED COURSE
  Future<void> updateSelectedCourse(int id, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedCourseId', id);
    await prefs.setString('selectedCourseName', name);
    
    selectedCourseId.value = id;
    selectedCourseName.value = name;
  }

  // 🌟 CENTRALIZED ACCESS CHECK
  bool canAccess(dynamic item) {
    if (item == null) return true;

    // 1. Determine User Plan (Tiered System)
    final String userPlan = subscriptionPlanName.value.toLowerCase().trim();
    if (userPlan.isEmpty) return false; // Lock everything if no plan

    // 2. Determine Item Access Type and Plans
    String itemType = "free";
    bool isExplicitlyLocked = false;
    List<dynamic> itemPlans = [];

    if (item is Map) {
      final dynamic rawType = item['access_type'] ??
          item['accessType'] ??
          item['access_level'] ??
          item['accessLevel'] ??
          item['access'];

      itemType = (rawType ?? "free").toString().toLowerCase().trim();
      isExplicitlyLocked = (item['locked'] == true ||
          item['locked'] == "true" ||
          item['locked'] == 1);
      
      itemPlans = item['plans'] ?? [];
    } else {
      try {
        itemType = (item.accessType).toString().toLowerCase().trim();
        isExplicitlyLocked = (item.locked == true);
        // Attempt to get plans from custom objects if available
        itemPlans = (item as dynamic).plans ?? [];
      } catch (_) {
        itemType = "free";
      }
    }

    // 🔒 HIGH PRIORITY: Explicitly locked
    if (isExplicitlyLocked) return false;

    // 🔒 HIGH PRIORITY: Explicitly locked
    if (isExplicitlyLocked) return false;

    // 💎 TIERED ACCESS LOGIC (Multiple Plans Support)
    // We check the 'plans' list first as the source of truth.
    if (itemPlans.isNotEmpty) {
      return itemPlans.any((p) {
        final String pName = (p is Map ? p['name'] : p.toString()).toLowerCase().trim();
        // Access granted if:
        // 1. User's plan matches this plan (e.g. user is 'silver' and node has 'silver')
        // 2. OR this is a 'free' plan node (accessible to all valid users)
        return pName == userPlan || pName == "free";
      });
    }

    // 3. Fallback: if no plans listed, check legacy access_type
    // (If the user explicitly wants to ignore access_type, this can be removed later)
    return itemType == "free";
  }

  // 🔔 STANDARD PREMIUM ALERT
  void showPremiumAlert() {
    Get.snackbar(
      "Premium Required",
      "Only premium customers can access this content",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.white,
      colorText: Colors.black,
      duration: const Duration(seconds: 3),
      icon: const Icon(
        Icons.workspace_premium_rounded,
        color: Colors.amber,
        size: 30,
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
        )
      ],
    );
  }
}