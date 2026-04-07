import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static ThemeController get instance => Get.find();

  // Observable track for current theme status
  var isDarkMode = false.obs;

  // Sync state to memory
  final String _key = 'isDarkMode';

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();
  }

  // Load from hard memory securely locally
  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode.value = prefs.getBool(_key) ?? false;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  // Save dynamically into preferences explicitly
  Future<void> _saveThemeToPrefs(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_key, isDark);
  }

  // Expose toggle command to any interaction button natively
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _saveThemeToPrefs(isDarkMode.value);
  }
}
