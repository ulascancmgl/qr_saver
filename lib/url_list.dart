import 'package:flutter/material.dart';
import 'web_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class URLListPage extends StatefulWidget {
  @override
  _URLListPageState createState() => _URLListPageState();
}

class _URLListPageState extends State<URLListPage> {
  List<String> visitedUrls = [];
  List<String> favoriteUrls = [];
  List<String> favoriteNames = [];

  @override
  void initState() {
    super.initState();
    loadVisitedUrls();
    loadFavoriteUrls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code Menülerim'),
        backgroundColor: Colors.purple,
      ),
      backgroundColor: Colors.blueGrey,
      body: ListView.builder(
        itemCount: visitedUrls.length,
        itemBuilder: (context, index) {
          final url = visitedUrls[index];
          final isFavorite = favoriteUrls.contains(url);
          return ListTile(
            title: Text(url),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  color: isFavorite ? Colors.orange : Colors.grey,
                  icon: Icon(Icons.star),
                  onPressed: () {
                    toggleFavorite(url);
                  },
                ),
                IconButton(
                  color: Colors.red,
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteVisitedUrlConfirmation(url);
                  },
                ),
              ],
            ),
            onTap: () {
              String prefixedUrl = addPrefixToUrl(visitedUrls[index]);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WebViewPage(url: prefixedUrl),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: () {
          deleteVisitedUrls();
        },
        child: Icon(Icons.delete),
      ),
    );
  }

  String addPrefixToUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    return url;
  }

  Future<void> loadVisitedUrls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedUrls = prefs.getStringList('visited_urls') ?? [];
    setState(() {
      visitedUrls = savedUrls;
    });
  }
  Future<void> loadFavoriteUrls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedUrls = prefs.getStringList('favorite_urls') ?? [];
    setState(() {
      favoriteUrls = savedUrls;
    });
  }

  Future<void> deleteVisitedUrls() async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Kaydedilenleri Sil'),
          content: Text('Are you sure you want to delete all visited URLs?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('visited_urls');
      setState(() {
        visitedUrls.clear();
      });
    }
  }

  Future<void> deleteVisitedUrlConfirmation(String url) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Visited URL'),
          content: Text('Are you sure you want to delete this visited URL?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Dismiss dialog and return false
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // Dismiss dialog and return true
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      deleteVisitedUrl(url);
    }
  }

  Future<void> deleteVisitedUrl(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedUrls = prefs.getStringList('visited_urls') ?? [];
    savedUrls.remove(url);
    await prefs.setStringList('visited_urls', savedUrls);
    setState(() {
      visitedUrls = savedUrls;
    });
  }

  Future<void> toggleFavorite(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedUrls = prefs.getStringList('favorite_urls') ?? [];
    List<String> savedNames = prefs.getStringList('favorite_names') ?? [];

    int existingIndex = savedUrls.indexOf(url);

    if (existingIndex != -1) {
      // Remove the URL and its corresponding name if it exists in favorites
      savedUrls.removeAt(existingIndex);
      if (existingIndex < savedNames.length) {
        savedNames.removeAt(existingIndex);
      }
    } else {
      // Add the URL with the default name if it doesn't exist in favorites
      savedUrls.add(url);
      savedNames.add(url); // Use the URL itself as the default name
    }

    await prefs.setStringList('favorite_urls', savedUrls);
    await prefs.setStringList('favorite_names', savedNames);

    setState(() {
      favoriteUrls = savedUrls;
      favoriteNames = savedNames.isNotEmpty ? savedNames : List<String>.filled(savedUrls.length, '');
    });
  }


}