import 'package:get/get.dart';

void main() {
  var rxList = [].obs;
  var originalList = [1, 2, 3];
  
  rxList.value = originalList;
  print("After assignment: rxList = $rxList, originalList = $originalList");
  
  rxList.clear();
  print("After clear: rxList = $rxList, originalList = $originalList");
}
