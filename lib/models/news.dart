// lib/models/news.dart
class News {
  final String id;
  final String title;
  final String imageUrl;
  final String shortDescription;
  final String fullContent;
  final String? url;

  News({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.shortDescription,
    required this.fullContent,
    this.url,
  });
}
