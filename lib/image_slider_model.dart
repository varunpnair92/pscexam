class ImageSliderModel {
  final int id;
  final String title;
  final String category;
  final String image;
  final String imageUrl;
  final bool active;

  ImageSliderModel({
    required this.id,
    required this.title,
    required this.category,
    required this.image,
    required this.imageUrl,
    required this.active,
  });

  factory ImageSliderModel.fromJson(Map<String, dynamic> json) {
    return ImageSliderModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      image: json['image'] ?? '',
      imageUrl: json['image_url'] ?? '',
      active: json['active'] ?? false,
    );
  }
}
