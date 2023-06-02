import 'package:flutter/material.dart';
import 'package:qr_saver/web_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritePage extends StatefulWidget {
  final String currentLanguage;

  FavoritePage({required this.currentLanguage});

  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<String> favoriteUrls = [];
  List<String> favoriteNames = [];

  Map<String, Map<String, String>> allTranslations = {
    'en': {
      'Favorilerim': 'My Favorites',
      'İsim ekle': 'Add name',
      'İptal et': 'Cancel',
      'Kaydet': 'Save',
      'Favorilerden Sil': 'Remove from favorites',
      'Silmek istediğinize emin misiniz ?': 'Are you sure ?',
      'İptal et': 'Cancel',
      'Sil': 'Delete',
    },
    'tr': {
      'My Favorites': 'Favorilerim',
      'Add name': 'İsim ekle',
      'Cancel': 'İptal et',
      'Save': 'Kaydet',
      'Remove from favorites': 'Favorilerden Sil',
      'Are you sure ?': 'Silmek istediğinize emin misiniz ?',
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
    loadFavoriteUrls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTranslatedString('Favorilerim')),
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
          itemCount: favoriteUrls.length,
          itemBuilder: (context, index) {
            final url = favoriteUrls[index];
            final name =
                favoriteNames.length > index ? favoriteNames[index] : null;
            return ListTile(
              title: GestureDetector(
                child: Text(name ?? url,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontFamily: 'Helvetica',
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    )),
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
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showNameInputDialog(index);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _removeFavoriteUrl(index);
                    },
                  ),
                ],
              ),
            );
          },
        ),
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
        TextEditingController textController =
            TextEditingController(text: name);
        return AlertDialog(
          title: Text(_getTranslatedString('İsim ekle')),
          content: TextField(
            controller: textController,
            onChanged: (value) {
              name = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text(_getTranslatedString('İptal et')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(_getTranslatedString('Kaydet')),
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
      favoriteNames = savedNames.isNotEmpty
          ? savedNames
          : List<String>.filled(savedUrls.length, '');
    });
  }

  Future<void> saveFavoriteUrls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorite_urls', favoriteUrls);
    prefs.setStringList('favorite_names', favoriteNames);
  }

  Future<void> _removeFavoriteUrl(int index) async {
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_getTranslatedString('Favorilerden Sil')),
          content:
              Text(_getTranslatedString('Silmek istediğinize emin misiniz ?')),
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
      setState(() {
        favoriteUrls.removeAt(index);
        favoriteNames.removeAt(index);
      });
      await saveFavoriteUrls();
    }
  }
}
