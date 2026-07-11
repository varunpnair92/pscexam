import 'dart:convert';
import 'package:http/http.dart' as http;

void search(List nodes, Set<String> navs) {
  for (var n in nodes) {
    if (n['navigation'] != null) {
      navs.add(n['navigation'].toString());
    }
    if (n['children'] != null) {
      search(n['children'], navs);
    }
  }
}

void main() async {
  final url = 'http://13.61.176.252:5544/api/nodeall/?userid=1'; 
  final response = await http.get(Uri.parse(url));
  final data = jsonDecode(response.body);
  
  Set<String> navs = {};
  search(data, navs);
  print(navs.toList());
}
