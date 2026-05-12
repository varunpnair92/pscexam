class ParentNavigationNode {
  final int id;
  final String name;
  final String? navigation;
  final List<String>? keywords;

  ParentNavigationNode({
    required this.id,
    required this.name,
    this.navigation,
    this.keywords,
  });

  factory ParentNavigationNode.fromJson(Map<String, dynamic> json) {
    return ParentNavigationNode(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? "0") ?? 0,
      name: (json['name'] ?? json['keyword'] ?? "").toString().trim(),
      navigation: json['navigation']?.toString().trim(),
      keywords: json['keywords'] != null ? List<String>.from(json['keywords']) : null,
    );
  }

  factory ParentNavigationNode.fromString(String keyword) {
    return ParentNavigationNode(
      id: 0,
      name: keyword,
      keywords: [keyword],
      navigation: "studyFull",
    );
  }
}
