import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = 'http://13.61.176.252:5544/api/nodeall/?userid=1'; 
  final response = await http.get(Uri.parse(url));
  final data = jsonDecode(response.body);
  
  if (data.isNotEmpty) {
    print("Course: ${data[0]['name']}");
    final children = data[0]['children'] ?? [];
    print("Children:");
    for (var c in children) {
      print("- ${c['name']}");
    }
  }
}
