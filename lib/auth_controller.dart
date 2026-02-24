import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Rxn<User> user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();

    user.bindStream(_auth.authStateChanges());
  }

  // 🔥 Google Login
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser =
        await GoogleSignIn().signIn();

    if (googleUser == null) return;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
  }

  // 🔥 Logout
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }
}