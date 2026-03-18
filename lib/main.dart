import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:psc_exam/auth_controller.dart';
import 'package:psc_exam/completed_exam_page.dart';
import 'package:psc_exam/exam_list_page.dart';
import 'package:psc_exam/exam_list_page_dynamic.dart';
import 'package:psc_exam/exam_page.dart';
import 'package:psc_exam/exam_review_page.dart';
import 'package:psc_exam/google_sign.dart';
import 'package:psc_exam/home_page.dart';
import 'package:psc_exam/study_exam_page.dart';
import 'package:psc_exam/study_question_page.dart';
import 'package:psc_exam/test_controller.dart';
import 'firebase_options.dart';

// 🔥 ADD THESE IMPORTS
import 'result_analysis_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Get.put(AuthController());
  Get.put(TestController(), permanent: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/home',

      getPages: [
        GetPage(name: '/home', page: () => HomePage()),

        // 🔐 LOGIN
        GetPage(name: '/login', page: () => LoginPage()),

        // 🏠 HOME
        //GetPage(name: '/home', page: () => HomePage()),

        // 📚 EXAM LIST
        GetPage(name: '/examlist', page: () => ExamListPage()),

        // 🧠 EXAM PAGE
        GetPage(name: '/exam', page: () => ExamPage()),

        // 📊 OLD RESULT PAGE (optional)
        GetPage(name: '/result', page: () => ResultPage()),

        // ⭐ NEW RESULT ANALYSIS PAGE
        GetPage(name: '/analysis', page: () => AnalysisPage()),

        // 🔍 REVIEW PAGE
        GetPage(name: '/review', page: () => ReviewPage()),

        GetPage(name: "/dynamicExamList", page: () => DynamicExamListPage()),

        GetPage(name: '/studyExam', page: () => StudyExamPage()),
        GetPage(name: "/studyQuestion", page: () => StudyQuestionPage()),
      ],
    );
  }
}
