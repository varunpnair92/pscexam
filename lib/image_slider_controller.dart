import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'image_slider_model.dart';

class ImageSliderController extends GetxController {
  var isLoading = true.obs;
  var sliderImages = <ImageSliderModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSliderImages();
  }

  Future<void> fetchSliderImages() async {
    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse(AppConfig.ImageSlide),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'category': 'slide'}),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        sliderImages.value = data
            .map((e) => ImageSliderModel.fromJson(e))
            .where((item) => item.active && item.category == 'slide')
            .toList();
      } else {
      }
    } catch (e) {
      // Error fetching slider images
    } finally {
      isLoading(false);
    }
  }
}
