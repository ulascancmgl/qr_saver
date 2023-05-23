import 'package:flutter/material.dart';
import 'favorite.dart';
import 'qr_code.dart';
import 'url_list.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentLanguage = 'tr';

  Map<String, String> translations = {
    'QR kodu tara': 'Scan QR Code',
    'Geçmiş': 'History',
    'Yüklenen PDFler': 'Downloaded PDFs',
    'Favoriler': 'Favorites',
  };

  String _getTranslatedString(String originalString) {
    return currentLanguage == 'tr'
        ? originalString
        : translations[originalString] ?? originalString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.restaurant),
            SizedBox(width: 8),
            Text(
              'Qr Menu',
              style: TextStyle(fontFamily: 'Helvetica', color: Colors.white),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            onSelected: (selectedLanguage) {
              setState(() {
                currentLanguage = selectedLanguage;
              });
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'tr',
                child: Text('Türkçe'),
              ),
              PopupMenuItem(
                value: 'en',
                child: Text('English'),
              ),
            ],
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.deepPurpleAccent.withOpacity(0.8),
                Colors.lightBlue.withOpacity(0.4)
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
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue.withOpacity(0.6),
              Colors.deepPurpleAccent.withOpacity(0.6)
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          image: DecorationImage(
            image: AssetImage('assets/images/pattern.png'), // Desenin yolu
            repeat: ImageRepeat.repeat, // Desenin tekrarlanma şekli
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MyQRCodePage(currentLanguage: currentLanguage),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(fontSize: 18, fontFamily: 'Helvetica'),
                    elevation: 4,
                    shadowColor: Colors.blueAccent.withOpacity(0.3),
                  ),
                  child: Text(_getTranslatedString('QR kodu tara')),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            URLListPage(currentLanguage: currentLanguage),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(fontSize: 18, fontFamily: 'Helvetica'),
                    elevation: 4,
                    shadowColor: Colors.blueAccent.withOpacity(0.3),
                  ),
                  child: Text(_getTranslatedString('Geçmiş')),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FavoritePage(currentLanguage: currentLanguage),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(fontSize: 18, fontFamily: 'Helvetica'),
                    elevation: 4,
                    shadowColor: Colors.blueAccent.withOpacity(0.3),
                  ),
                  child: Text(_getTranslatedString('Favoriler')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
