import 'package:get/get.dart';
import 'package:psc_exam/home_controller.dart';
import 'package:psc_exam/study_controller.dart';
import 'package:psc_exam/test_controller.dart';  
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => StudyController());
    Get.lazyPut(() => TestController());
    Get.lazyPut(() => HomeController());
  }
}
