import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'auth_controller.dart';
import 'app_config.dart';

class TreeService extends GetxService {
  static TreeService get instance => Get.find();
  
  var fullTree = <dynamic>[].obs;
  var isLoading = false.obs;

  Future<TreeService> init() async {
    await fetchTree();
    return this;
  }

  Future<void> fetchTree({bool force = false}) async {
    if (!force && fullTree.isNotEmpty) return;
    
    if (isLoading.value) {
      // If already loading, wait until it finishes
      while (isLoading.value) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }
    
    isLoading.value = true;
    try {
      final auth = AuthController.instance;
      final userId = auth.userId.value;
      final url = "${AppConfig.nodeall}?userid=$userId";
      
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        fullTree.value = jsonDecode(res.body);
      }
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
  }
}
