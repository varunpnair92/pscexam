import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'notification_model.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      final response = await http.get(Uri.parse(AppConfig.activeNotifications));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        notifications.value = data
            .map((json) => NotificationModel.fromJson(json))
            .where((n) => n.active)
            .toList();
      } else {
      }
    } catch (e) {
      // Error fetching notifications
    } finally {
      isLoading(false);
    }
  }
}
