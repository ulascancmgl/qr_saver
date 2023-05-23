import 'package:flutter/material.dart';
import 'web_view.dart';
import 'package:shared_preferences/shared_preferences.dart';


class URLListPage extends StatefulWidget {
  @override
  _URLListPageState createState() => _URLListPageState();
}

class _URLListPageState extends State<URLListPage> {
  List<String> visitedUrls = [];

  @override
  void initState() {
    super.initState();
    loadVisitedUrls();
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
          return ListTile(
            title: Text(visitedUrls[index]),
            trailing: IconButton(
              color: Colors.red,
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteVisitedUrlConfirmation(visitedUrls[index]);
              },
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
}