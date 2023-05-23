import 'package:flutter/material.dart';
import 'package:qr_saver/web_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<String> favoriteUrls = [];

  @override
  void initState() {
    super.initState();
    loadFavoriteUrls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite URLs'),
        backgroundColor: Colors.purple,
      ),
      backgroundColor: Colors.blueGrey,
      body: ListView.builder(
        itemCount: favoriteUrls.length,
        itemBuilder: (context, index) {
          final url = favoriteUrls[index];
          return ListTile(
            title: GestureDetector(
              child: Text(url, style: TextStyle(decoration: TextDecoration.underline)),
              onTap: () {
                String prefixedUrl = addPrefixToUrl(url);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WebViewPage(url: prefixedUrl),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
  String addPrefixToUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    return url;
  }

  Future<void> loadFavoriteUrls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedUrls = prefs.getStringList('favorite_urls') ?? [];
    setState(() {
      favoriteUrls = savedUrls;
    });
  }
}
