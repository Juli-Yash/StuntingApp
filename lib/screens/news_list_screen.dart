// lib/screens/news_list_screen.dart
import 'package:flutter/material.dart';
import 'package:smart_stunting_app/models/news.dart';
import 'package:smart_stunting_app/screens/news_detail_screen.dart';
import 'package:smart_stunting_app/widgets/news_card.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsListScreen extends StatelessWidget {
  final List<News> allNews;

  const NewsListScreen({super.key, required this.allNews});

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tidak dapat membuka link: $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Berita'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: allNews.length,
        itemBuilder: (context, index) {
          final newsItem = allNews[index];
          return NewsCard(
            news: newsItem,
            onTap: () {
              if (newsItem.url != null && newsItem.url!.isNotEmpty) {
                _launchUrl(context, newsItem.url!);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsDetailScreen(news: newsItem),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
