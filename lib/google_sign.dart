import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:psc_exam/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final AuthController auth = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => auth.signInWithGoogle(),
          child: Text("Sign in with Google"),
        ),
      ),
    );
  }
}