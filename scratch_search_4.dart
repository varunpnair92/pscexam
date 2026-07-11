import 'dart:convert';
import 'package:http/http.dart' as http;

void search(List nodes) {
  for (var n in nodes) {
    if (n['navigation'].toString().contains('navigationSlide')) {
      print("Found navigationSlide in node: ${n['id']} : ${n['name']}");
    }
    if (n['children'] != null) {
      search(n['children']);
    }
  }
}

void main() async {
  final url = 'http://13.61.176.252:5544/api/nodeall/?userid=1'; 
  final response = await http.get(Uri.parse(url));
  final data = jsonDecode(response.body);
  
  search(data);
}
