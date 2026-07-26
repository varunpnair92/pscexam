import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:psc_exam/auth_controller.dart';
import 'package:psc_exam/completed_exam_page.dart';
import 'package:psc_exam/exam_list_page.dart';
import 'package:psc_exam/exam_list_page_dynamic.dart';
import 'package:psc_exam/exam_page.dart';
import 'package:psc_exam/dynamic_menu_page.dart';
import 'registration_page.dart';
import 'notification_permission_page.dart';
import 'package:psc_exam/exam_review_page.dart';
import 'package:psc_exam/google_sign.dart';
import 'package:psc_exam/home_page.dart';
import 'package:psc_exam/study_exam_page.dart';
import 'package:psc_exam/study_page.dart';
import 'package:psc_exam/study_question_page.dart';
import 'package:psc_exam/test_controller.dart';
import 'firebase_options.dart';
import 'news_controller.dart';

import 'result_analysis_page.dart';
import 'story_page.dart';
import 'global_analysis_page.dart';
import 'characteristic_page.dart';
import 'news_feeder_page.dart';
import 'splash_page.dart';
import 'app_theme.dart';
import 'theme_controller.dart';
import 'exam_splash_page.dart'; // 🔥 Import ExamSplashPage
import 'exam_story_page.dart';
import 'keyword_search_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'push_notification_service.dart';
import 'ad_controller.dart';
import 'navigation_slide_page.dart';
import 'parent_navigation_page.dart';
import 'keyword_details_page.dart';
import 'keyword_summary_page.dart';
import 'tree_service.dart'; // 🔥 Import TreeService
import 'keyword_summary_capsule_page.dart';
import 'timeline_page.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  Get.put(AuthController());
  await AuthController.instance.loadSession(); // Wait for local data (fast)
  
  Get.put(ThemeController()); // 🔥 Initialize Theme
  
  // Initialize Push notifications in the background to prevent startup ANR
  PushNotificationService.initialize();

  // 🔥 Initialize TreeService globally
  Get.put(TreeService(), permanent: true);

  Get.put(TestController(), permanent: true);
  Get.put(NewsController(), permanent: true);
  Get.put(AdController(), permanent: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // 🔥 Support theming
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      initialRoute: '/splash',

      getPages: [
        GetPage(name: '/splash', page: () => const SplashPage()),
        GetPage(name: '/home', page: () => HomePage()),

        // 🔐 LOGIN
        GetPage(name: '/login', page: () => LoginPage()),

        // 📚 EXAM LIST
        GetPage(name: '/examlist', page: () => ExamListPage()),

        // 🧠 EXAM PAGE
        GetPage(name: '/exam', page: () => ExamPage()),

        // 📊 OLD RESULT PAGE (optional)
        GetPage(name: '/result', page: () => ResultPage()),

        // ⭐ NEW RESULT ANALYSIS PAGE
        GetPage(name: '/analysis', page: () => AnalysisPage()),

        // 📈 GLOBAL ANALYSIS PAGE
        GetPage(name: '/globalAnalysis', page: () => GlobalAnalysisPage()),

        // 🔍 REVIEW PAGE
        GetPage(name: '/review', page: () => ReviewPage()),

        GetPage(name: "/dynamicMenu", page: () => DynamicMenuPage()),
        GetPage(name: "/dynamicExamList", page: () => DynamicExamListPage()),

        GetPage(name: '/studyExam', page: () => StudyExamPage()),

        GetPage(name: '/studyFull', page: ()=>StudyPage()),
        GetPage(name: "/studyQuestion", page: () => StudyQuestionPage()),

        // 📖 STORY
        GetPage(name: '/story', page: () => StoryPage()),

        // ✨ CHARACTERISTIC
        GetPage(name: '/characteristic', page: () => CharacteristicPage()),

        // 📰 NEWS FEEDER
        GetPage(name: '/newsfeeder', page: () => NewsFeederPage()),

        // 🚀 EXAM SPLASH
        GetPage(name: '/examSplash', page: () => const ExamSplashPage()),
        GetPage(name: '/examstorypage', page: () => ExamStoryPage()),

        // 🔍 KEYWORD SEARCH
        GetPage(name: '/keywordSearch', page: () => KeywordSearchPage()),

        // 📝 REGISTRATION
        GetPage(name: '/register', page: () => RegistrationPage()),

        // 🎢 NAVIGATION SLIDE
        GetPage(name: '/navigationSlide', page: () => NavigationSlidePage()),

        // 🔔 NOTIFICATION PERMISSION
        GetPage(name: '/notificationPermission', page: () => NotificationPermissionPage()),

        // 🌳 PARENT NAVIGATION
        GetPage(name: '/parentNavigation', page: () => const ParentNavigationPage()),

        // 🔎 KEYWORD DETAILS
        GetPage(name: '/keywordDetails', page: () => KeywordDetailsPage()),

        // 📝 KEYWORD SUMMARY
        GetPage(name: '/keywordSummary', page: () => KeywordSummaryPage()),
        
        // 🧠 KNOWLEDGE CAPSULE
        GetPage(name: '/knowledgeCapsule', page: () => KeywordSummaryKnowledgeCapsulePage()),

        // ⏳ TIMELINE
        GetPage(name: '/timeline', page: () => const TimelinePage()),
      ],
    );
  }
}
