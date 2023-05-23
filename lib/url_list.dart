import 'package:flutter/material.dart';
import 'web_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class URLListPage extends StatefulWidget {
  final String currentLanguage;

  URLListPage({required this.currentLanguage});

  @override
  _URLListPageState createState() => _URLListPageState();
}

class _URLListPageState extends State<URLListPage> {
  List<String> visitedUrls = [];
  List<String> favoriteUrls = [];
  List<String> favoriteNames = [];

  Map<String, Map<String, String>> allTranslations = {
    'en': {
      'QR Code Menülerim': 'My QR Code Menus',
      'Geçmişi Sil': 'Delete All',
      'Geçmişi silmek istediğinize emin misiniz ?': 'Are you sure ?',
      'İptal et': 'Cancel',
      'Sil': 'Delete',
      'Bu linki sil': 'Delete this link',
      'Bu linki silmek istediğinize emin misiniz ?': 'Are you sure ?',
      'İptal et': 'Cancel',
      'Sil': 'Delete',
    },
    'tr': {
      'My QR Code Menus': 'QR Code Menülerim',
      'Delete All': 'Geçmişi Sil',
      'Are you sure ?': 'Geçmişi silmek istediğinize emin misiniz ?',
      'Cancel': 'İptal et',
      'Delete': 'Sil',
      'Delete this link': 'Bu linki sil',
      'Are you sure ?': 'Bu linki silmek istediğinize emin misiniz ?',
      'Cancel': 'İptal et',
      'Delete': 'Sil',
    },
  };

  String _getTranslatedString(String key) {
    Map<String, String> translations =
        allTranslations[widget.currentLanguage] ?? {};
    return translations[key] ?? key;
  }

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
        title: Text(_getTranslatedString('QR Code Menülerim')),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurpleAccent.withOpacity(0.8),
                Colors.lightBlue.withOpacity(0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/pattern.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView.builder(
          itemCount: visitedUrls.length,
          itemBuilder: (context, index) {
            final url = visitedUrls[index];
            final isFavorite = favoriteUrls.contains(url);
            return ListTile(
              title: Text(
                url,
                style: TextStyle(
                  fontFamily: 'Helvetica',
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
          title: Text(_getTranslatedString('Geçmişi Sil')),
          content: Text(_getTranslatedString(
              'Geçmişi silmek istediğinize emin misiniz ?')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(_getTranslatedString('Sil')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
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
          title: Text(_getTranslatedString('Bu linki sil')),
          content: Text(_getTranslatedString(
              'Bu linki silmek istediğinize emin misiniz ?')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(_getTranslatedString('İptal et')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(_getTranslatedString('Sil')),
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
      savedUrls.removeAt(existingIndex);
      if (existingIndex < savedNames.length) {
        savedNames.removeAt(existingIndex);
      }
    } else {
      savedUrls.add(url);
      savedNames.add(url);
    }

    await prefs.setStringList('favorite_urls', savedUrls);
    await prefs.setStringList('favorite_names', savedNames);

    setState(() {
      favoriteUrls = savedUrls;
      favoriteNames = savedNames.isNotEmpty
          ? savedNames
          : List<String>.filled(savedUrls.length, '');
    });
  }
}
