class BattleRanker {
  final int rank;
  final String fullname;
  final String username;
  final int mark;

  BattleRanker({
    required this.rank,
    required this.fullname,
    required this.username,
    required this.mark,
  });

  factory BattleRanker.fromJson(Map<String, dynamic> json) {
    return BattleRanker(
      rank: json['rank'] ?? 0,
      fullname: json['fullname'] ?? "Participant",
      username: json['username'] ?? "",
      mark: json['mark'] ?? 0,
    );
  }
}

class UserBattleResult {
  final int mark;
  final int totalMarks;
  final int rank;
  final int totalParticipants;

  UserBattleResult({
    required this.mark,
    required this.totalMarks,
    required this.rank,
    required this.totalParticipants,
  });

  factory UserBattleResult.fromJson(Map<String, dynamic> json) {
    return UserBattleResult(
      mark: json['mark'] ?? 0,
      totalMarks: json['total_marks'] ?? 0,
      rank: json['rank'] ?? 0,
      totalParticipants: json['total_participants'] ?? 0,
    );
  }
}

class BattleExamItem {
  final int id;
  final String category;
  final String specialization;
  final String type;
  final String? instructions;
  final String? description;
  final String accessType;
  final bool isLocked;
  final int totalQuestions;
  final DateTime? startTime;
  final bool resultPublished;
  final bool hasAttended;
  final DateTime? createdAt;
  final UserBattleResult? userResult;
  final int totalParticipants;
  final List<BattleRanker> topRankers;

  BattleExamItem({
    required this.id,
    required this.category,
    required this.specialization,
    required this.type,
    this.instructions,
    this.description,
    required this.accessType,
    required this.isLocked,
    required this.totalQuestions,
    this.startTime,
    required this.resultPublished,
    required this.hasAttended,
    this.createdAt,
    this.userResult,
    this.totalParticipants = 0,
    this.topRankers = const [],
  });

  factory BattleExamItem.fromJson(Map<String, dynamic> json) {
    DateTime? parsedStart;
    if (json['start_time'] != null && json['start_time'].toString().isNotEmpty) {
      try {
        parsedStart = DateTime.parse(json['start_time'].toString());
      } catch (_) {}
    }

    DateTime? parsedCreated;
    if (json['created_at'] != null && json['created_at'].toString().isNotEmpty) {
      try {
        parsedCreated = DateTime.parse(json['created_at'].toString());
      } catch (_) {}
    }

    UserBattleResult? uResult;
    if (json['user_result'] != null && json['user_result'] is Map) {
      uResult = UserBattleResult.fromJson(Map<String, dynamic>.from(json['user_result']));
    }

    List<BattleRanker> rankers = [];
    if (json['top_rankers'] != null && json['top_rankers'] is List) {
      rankers = (json['top_rankers'] as List)
          .map((r) => BattleRanker.fromJson(Map<String, dynamic>.from(r)))
          .toList();
    }

    return BattleExamItem(
      id: json['id'] ?? 0,
      category: json['category'] ?? "Exam Battle",
      specialization: (json['specialization'] ?? "Battle Exam").toString(),
      type: json['type'] ?? "battle",
      instructions: json['instructions'],
      description: json['description'],
      accessType: (json['access_type'] ?? "free").toString(),
      isLocked: json['is_locked'] == true || json['is_locked'] == "true" || json['is_locked'] == 1,
      totalQuestions: json['total_questions'] ?? 0,
      startTime: parsedStart,
      resultPublished: json['result_published'] == true || json['result_published'] == "true" || json['result_published'] == 1,
      hasAttended: json['has_attended'] == true || json['has_attended'] == "true" || json['has_attended'] == 1,
      createdAt: parsedCreated,
      userResult: uResult,
      totalParticipants: json['total_participants'] ?? 0,
      topRankers: rankers,
    );
  }
}
