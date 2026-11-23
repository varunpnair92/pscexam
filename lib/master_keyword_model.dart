class MasterKeywordNode {
  final int id;
  final String keyword;
  final String? keywordmanglish;
  final int? parentId;
  final String? parentKeyword;
  final int childrenCount;
  final bool hasChildren;

  MasterKeywordNode({
    required this.id,
    required this.keyword,
    this.keywordmanglish,
    this.parentId,
    this.parentKeyword,
    this.childrenCount = 0,
    this.hasChildren = false,
  });

  factory MasterKeywordNode.fromJson(Map<String, dynamic> json) {
    int idVal = json['id'] is int
        ? json['id']
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    int cCount = json['children_count'] is int
        ? json['children_count']
        : int.tryParse(json['children_count']?.toString() ?? '0') ?? 0;
    bool hasKids = json['has_children'] == true || cCount > 0;

    return MasterKeywordNode(
      id: idVal,
      keyword: (json['keyword'] ?? json['name'] ?? '').toString().trim(),
      keywordmanglish: json['keywordmanglish']?.toString(),
      parentId: json['parent_id'] != null
          ? int.tryParse(json['parent_id'].toString())
          : null,
      parentKeyword: json['parent_keyword']?.toString(),
      childrenCount: cCount,
      hasChildren: hasKids,
    );
  }
}
