class AppConfig {

  // 🔥 Base API URL
  static const String baseUrl = "http://13.61.176.252:5544/api/";

  // ================= TOGGLES =================
  static const bool showNextPreviousOnlyInWeb = true;
  static const bool knowledgeCardActive = true; // 🆕 Toggle for Knowledge Capsule

  // ================= EXAMS =================
  //static const String listExams = "${baseUrl}listexams/";
  static const String testExam = "${baseUrl}testexam/";

  // ================= HIERARCHY =================
  // NEW DATABASE TREE API
  static const String nodeall = "${baseUrl}nodeall/";

  // (OLD METHOD – can remove if unused)
  static const String hierarchy = "${baseUrl}hirarchykey";

  // ================= QUESTIONS =================
  static const String keywordQuestions =
      "${baseUrl}qbkeywordmultiplecombinedsimilar";

  // ================= KEYWORD DESCRIPTION =================
  static const String keywordDesc =
      "${baseUrl}kbkeyword/";

//==========image slid e============================
static const String ImageSlide =
      "${baseUrl}get-images-by-category/";

// ================= USER EXAM STATS =================
static const String userExamStats = "${baseUrl}user-exam-stats/";

// ================= USER DETAILS =================
static const String getUserDetails = "${baseUrl}get_userdetails_by_username/";

// ================= COURSE MANAGEMENT =================
static const String courses = "${baseUrl}courses/";
static const String updateCourse = "${baseUrl}update-course/";

// ================= QUALIFICATION MANAGEMENT =================
static const String qualifications = "${baseUrl}qualifications/";
static const String updateQualification = "${baseUrl}update-qualification/";

// ================= NOTIFICATIONS =================
  static const String activeNotifications = "${baseUrl}active-notifications/";
  static const String saveFcmToken = "${baseUrl}save_fcm_token/";

  // ================= ADVERTISEMENTS =================
  static const String activeAds = "${baseUrl}active-advertisements/";

// ================= CHARACTERISTICS =================
  static const String characteristicByKeyword = "${baseUrl}qbkeywordcharacteristic/";

  // ================= MULTIPLE COMBINED KEYWORD SEARCH =================
  static const String keywordMultipleCombinedSimilarWithKeyword = "${baseUrl}qbkeywordmultiplecombinedsimilar-with-keyword";

  // ================= KNOWLEDGE CAPSULE =================
  static const String activeKnowledgeScroll = "${baseUrl}active-knowledge-scroll/";

  // ================= KEYWORD FULL DETAILS =================
  static const String keywordFullDetails = "${baseUrl}keyword-full-details/";
}