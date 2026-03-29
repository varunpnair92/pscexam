import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'news_model.dart';

class NewsController extends GetxController {
  var newsList = <NewsItem>[].obs;
  var isLoading = false.obs;

  Future<void> fetchNews(String url) async {
    if (url.isEmpty) return;

    isLoading.value = true;
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        newsList.value = data.map((json) => NewsItem.fromJson(json)).toList();
      }
    } catch (e) {
      // silently fail
    } finally {
      isLoading.value = false;
    }
  }
}
