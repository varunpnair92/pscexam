import 'dart:convert';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'app_config.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Rxn<User> firebaseUser = Rxn<User>();
  
  // 👤 User state
  var userId = 1.obs;
  var userName = "".obs;
  var fullName = "".obs;
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    loadSession();
  }

  // 💾 Load from SharedPreferences
  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    userId.value = prefs.getInt('userid') ?? 1;
    userName.value = prefs.getString('username') ?? "";
    fullName.value = prefs.getString('fullname') ?? "";
    isLoggedIn.value = prefs.getBool('isLoggedIn') ?? false;
  }

  // 💾 Save to SharedPreferences
  Future<void> saveSession(int id, String user, String full) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userid', id);
    await prefs.setString('username', user);
    await prefs.setString('fullname', full);
    await prefs.setBool('isLoggedIn', true);
    
    userId.value = id;
    userName.value = user;
    fullName.value = full;
    isLoggedIn.value = true;
  }

  // 🔥 Google Login
  Future<void> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // 🌐 Web specific: Use signInWithPopup for better reliability
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // 📱 Mobile specific: Use google_sign_in plugin
        final GoogleSignInAccount? googleUser = await GoogleSignIn(
          clientId: '613180327334-cfu7uttjotlftkv2o206jb4j1i1o8djp.apps.googleusercontent.com',
        ).signIn();
        
        if (googleUser == null) return;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      final email = userCredential.user?.email;

      if (email != null) {
        await fetchUserDetails(email);
      }
      
      Get.offAllNamed('/home');
    } catch (e) {
      Get.snackbar(
        "Login Error", 
        "Failed to sign in. Please check your connection.",
        snackPosition: SnackPosition.BOTTOM,
      );
      print("Login Error: $e");
    }
  }

  // 🌍 Fetch details from API
  Future<void> fetchUserDetails(String email) async {
    try {
      final res = await http.get(Uri.parse("${AppConfig.getUserDetails}$email/"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await saveSession(
          data['userid'] ?? 1,
          data['username'] ?? email,
          data['fullname'] ?? data['username'] ?? "User",
        );
      } else {
        // Default to userId 1 if not found on server
        await saveSession(1, email, "Guest User");
      }
    } catch (_) {
      await saveSession(1, email, "Guest User");
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
    
    Get.offAllNamed('/login');
  }
}