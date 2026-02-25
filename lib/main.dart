import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'auth_controller.dart';
import 'google_sign.dart';
import 'homepage.dart';
import 'exam_list_page.dart';
import 'exam_page.dart';
import 'result_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔥 Register Auth Controller
  Get.put(AuthController());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // ⭐ Start page
      initialRoute: '/examlist',

      getPages: [

        // 🔐 Login
        GetPage(name: '/login', page: () => LoginPage()),

        // 🏠 Home
        GetPage(name: '/home', page: () => HomePage()),

        // 📚 Exam List
        GetPage(name: '/examlist', page: () => ExamListPage()),

        // 🧠 Exam Questions Page
        GetPage(name: '/exam', page: () => ExamPage()),

        // 📊 Result / Summary Page
        GetPage(name: '/result', page: () => ResultPage()),
      ],
    );
  }
}