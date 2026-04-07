class AdModel {
  final int id;
  final String title;
  final String category;
  final String imageUrl;
  final String? description;
  final int timer; // 0 = no auto-dismiss
  final String? linkUrl;
  final bool active;

  AdModel({
    required this.id,
    required this.title,
    required this.category,
    required this.imageUrl,
    this.description,
    required this.timer,
    this.linkUrl,
    required this.active,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      imageUrl: json['image_url'] ?? json['image'] ?? '',
      description: json['description'],
      timer: json['timer'] ?? 0,
      linkUrl: json['link_url'],
      active: json['active'] ?? false,
    );
  }
}
