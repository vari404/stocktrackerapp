import 'package:flutter/material.dart';
import 'package:stocktrackerapp/services/news_service.dart';
import 'package:stocktrackerapp/features/newsfeed/widgets/newsfeed_card.dart';
import 'package:stocktrackerapp/widgets/bottom_nav_bar.dart';
import 'package:stocktrackerapp/widgets/custom_app_bar.dart';
import 'package:stocktrackerapp/widgets/app_drawer.dart';

class NewsfeedScreen extends StatefulWidget {
  const NewsfeedScreen({Key? key}) : super(key: key);

  @override
  State<NewsfeedScreen> createState() => _NewsfeedScreenState();
}

class _NewsfeedScreenState extends State<NewsfeedScreen> {
  final NewsService _newsService = NewsService();
  late Future<List<Map<String, dynamic>>> _newsFuture;

  @override
  void initState() {
    super.initState();
    _newsFuture = _newsService.fetchMarketNews('general');
  }

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/portfolio');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/watchlist');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/newsfeed');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Newsfeed'),
      drawer: AppDrawer(),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _newsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final newsList = snapshot.data!;
            return ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                final newsItem = newsList[index];
                return NewsfeedCard(
                  headline: newsItem['headline'] ?? 'No Title',
                  summary: newsItem['summary'] ?? 'No Summary',
                  imageUrl: newsItem['image'] ?? '',
                  source: newsItem['source'] ?? 'Unknown',
                  url: newsItem['url'] ?? '',
                );
              },
            );
          } else {
            return const Center(child: Text('No news available.'));
          }
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTabSelected: (index) => _onTabSelected(context, index),
      ),
    );
  }
}
