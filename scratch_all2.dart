import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = 'http://13.61.176.252:5544/api/nodeall/'; // NO userid
  final response = await http.get(Uri.parse(url));
  final data = jsonDecode(response.body);
  
  if (data.isNotEmpty) {
    final children = data[0]['children'] ?? [];
    print("Direct children of LDC:");
    for (var c in children) {
      print("ID: ${c['id']}, Name: ${c['name']}, VisibleTo: ${c['visible_to_ids']}");
    }
  }
}
