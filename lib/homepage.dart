import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:psc_exam/auth_controller.dart';

class HomePage extends StatelessWidget {
  final AuthController auth = Get.find();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text("PSC Exam")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user?.email ?? "No Email",
              style: TextStyle(fontSize: 20),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => auth.signOut(),
              child: Text("Logout"),
            )
          ],
        ),
      ),
    );
  }
}