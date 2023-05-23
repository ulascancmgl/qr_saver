import 'package:flutter/material.dart';
import 'package:qr_saver/web_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<String> favoriteUrls = [];
  List<String> favoriteNames = [];

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
          final name = favoriteNames.length > index ? favoriteNames[index] : null;
          return ListTile(
            title: GestureDetector(
              child: Text(name ?? url, style: TextStyle(decoration: TextDecoration.underline)),
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
            trailing: IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _showNameInputDialog(index);
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

  Future<void> _showNameInputDialog(int index) async {
    String name = favoriteNames.length > index ? favoriteNames[index] : '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController textController = TextEditingController(text: name);
        return AlertDialog(
          title: Text('Add Name'),
          content: TextField(
            controller: textController,
            onChanged: (value) {
              name = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                setState(() {
                  if (favoriteNames.length > index) {
                    favoriteNames[index] = name;
                  } else {
                    favoriteNames.add(name);
                  }
                });
                saveFavoriteUrls();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> loadFavoriteUrls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedUrls = prefs.getStringList('favorite_urls') ?? [];
    List<String> savedNames = prefs.getStringList('favorite_names') ?? [];
    setState(() {
      favoriteUrls = savedUrls;
      favoriteNames = savedNames.isNotEmpty ? savedNames : List<String>.filled(savedUrls.length, '');
    });
  }

  Future<void> saveFavoriteUrls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorite_urls', favoriteUrls);
    prefs.setStringList('favorite_names', favoriteNames);
  }
}
