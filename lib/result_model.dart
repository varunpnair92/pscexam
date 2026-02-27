import 'dart:convert';

class TestResult {
  final String userid;
  final int examids;
  final Map<String, dynamic> qresponse;
  final int mark;

  TestResult({
    required this.userid,
    required this.examids,
    required this.qresponse,
    required this.mark,
  });

  factory TestResult.fromJson(Map<String, dynamic> json) {

  var raw = json['qresponse'];

  Map<String, dynamic> parsed;

  // 🔥 If server sent String → decode
  if (raw is String) {
    parsed = Map<String, dynamic>.from(
      jsonDecode(raw.replaceAll("'", '"')),
    );
  } else {
    parsed = Map<String, dynamic>.from(raw);
  }

  return TestResult(
    userid: json['userid'],
    examids: json['examids'],
    qresponse: parsed,
    mark: json['mark'],
  );
}
}