import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final res = await http.get(Uri.parse('https://app.psconline.in/api/user-exam-stats/1/'));
  print(res.body);
}
