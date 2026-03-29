import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'characteristic_model.dart';

class CharacteristicController extends GetxController {
  var isLoading = false.obs;
  var characteristicMap = <String, List<CharacteristicQuestion>>{}.obs;
  var currentKeyword = "".obs;
  
  // ─── Selection for Tree View ──────────────────────────────────
  var selectedCategory = "".obs;

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  void clearSelection() {
    selectedCategory.value = "";
  }

  Future<void> fetchCharacteristics(String keyword) async {
    if (keyword.isEmpty) return;
    
    currentKeyword.value = keyword;
    isLoading.value = true;
    characteristicMap.clear();

    try {
      final response = await http.get(Uri.parse(AppConfig.characteristicByKeyword + keyword));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        Map<String, List<CharacteristicQuestion>> tempMap = {};
        
        data.forEach((key, value) {
          if (value is List) {
            tempMap[key] = value.map((q) => CharacteristicQuestion.fromJson(q)).toList();
          }
        });
        
        characteristicMap.value = tempMap;
      } else {
        Get.snackbar("Error", "Failed to fetch data: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
