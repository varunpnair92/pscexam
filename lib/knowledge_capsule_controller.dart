import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class KnowledgeCapsuleController extends GetxController {
  var isVisible = false.obs;
  var currentFact = "".obs;
  
  final List<String> _facts = [
    "The first silent movie in Malayalam is 'Vigathakumaran' (1928).",
    "The longest river in Kerala is Periyar (244 km).",
    "The first district in India to achieve 100% literacy is Kottayam (1989).",
    "The Father of Kerala Renaissance is Sree Narayana Guru.",
    "The highest peak in Kerala is Anamudi (2,695m).",
    "The first newspaper in Malayalam is 'Rajyasamacharam' (1847).",
    "The only district in Kerala with no forest area is Alappuzha.",
    "The first hydroelectric project in Kerala is Pallivasal.",
    "The first solar-powered airport in the world is Cochin International Airport.",
    "The 'Silicon Valley of Kerala' is Technopark, Thiruvananthapuram.",
  ];

  @override
  void onInit() {
    super.onInit();
    _checkDailyShow();
  }

  Future<void> _checkDailyShow() async {
    final prefs = await SharedPreferences.getInstance();
    final String lastShownDate = prefs.getString('last_capsule_date') ?? "";
    final String todayDate = DateTime.now().toIso8601String().substring(0, 10);

    if (lastShownDate != todayDate) {
      // It's a new day! Show the capsule.
      _showCapsule(prefs, todayDate);
    }
  }

  void _showCapsule(SharedPreferences prefs, String date) {
    // Pick a random fact
    currentFact.value = _facts[Random().nextInt(_facts.length)];
    
    // Show after a small delay to let the home screen settle
    Future.delayed(const Duration(milliseconds: 800), () {
      isVisible.value = true;
      prefs.setString('last_capsule_date', date);
    });
  }

  void dismiss() {
    isVisible.value = false;
  }
}
