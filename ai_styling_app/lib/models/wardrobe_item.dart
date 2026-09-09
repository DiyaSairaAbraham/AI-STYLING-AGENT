class WardrobeItem {
  final String id;
  final String imagePath;
  final String? thumbnailPath;
  final String category;
  final String color;
  final String style;

  const WardrobeItem({
    required this.id,
    required this.imagePath,
    required this.thumbnailPath,
    required this.category,
    required this.color,
    required this.style,
  });

  factory WardrobeItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return WardrobeItem(
      id: json['id_baju']?.toString() ?? '',
      imagePath: json['image_path']?.toString() ?? '',
      thumbnailPath: json['thumbnail_path']?.toString(),
      category: json['category']?.toString() ?? 'Unknown',
      color: json['color']?.toString() ?? 'Unknown',
      style: json['style']?.toString() ?? 'Unknown',
    );
  }
}