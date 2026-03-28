class AppConfig {

  // 🔥 Base API URL
  static const String baseUrl = "http://13.61.184.75:5544/api/";

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

// ================= NOTIFICATIONS =================
static const String activeNotifications = "${baseUrl}active-notifications/";
}