import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = 'http://13.61.176.252:5544/api/nodeall/?userid=1'; 
  final response = await http.get(Uri.parse(url));
  final data = jsonDecode(response.body);
  
  if (data.isNotEmpty) {
    final children = data[0]['children'] ?? [];
    for (var c in children) {
      print("${c['id']} : ${c['name']}");
      final sub = c['children'] ?? [];
      for (var s in sub) {
        print("  -> ${s['id']} : ${s['name']}");
      }
    }
  }
}
