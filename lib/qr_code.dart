import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'web_view.dart';
import 'package:url_launcher/url_launcher.dart';

class MyQRCodePage extends StatefulWidget {
  final String currentLanguage;

  MyQRCodePage({required this.currentLanguage});

  @override
  _MyQRCodePageState createState() => _MyQRCodePageState();
}

class _MyQRCodePageState extends State<MyQRCodePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String websiteUrl = '';
  TextEditingController urlController = TextEditingController();

  Map<String, Map<String, String>> allTranslations = {
    'en': {
      'QR kodu tara': 'Scan QR Code',
    },
    'tr': {
      'Scan QR Code': 'QR kodu tara',
    },
  };

  String _getTranslatedString(String key) {
    Map<String, String> translations =
        allTranslations[widget.currentLanguage] ?? {};
    return translations[key] ?? key;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
        _getTranslatedString('QR kodu tara'),
          style: TextStyle(fontFamily: 'Helvetica', color: Colors.white),
        ),
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
      backgroundColor: Colors.lightBlue.withOpacity(0.4),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/pattern.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () {
                    String enteredUrl = urlController.text.trim();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WebViewPage(url: websiteUrl),
                      ),
                    );
                    launchUrl(websiteUrl as Uri);
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: Container(
                      color: Colors.transparent,
                      child: Text(
                        '$websiteUrl',
                        style: TextStyle(fontSize: 16, fontFamily: 'Helvetica'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        String scannedUrl = scanData.code!;
        websiteUrl = addPrefixToUrl(scannedUrl);
        saveUrl(websiteUrl);
      });
    });
  }

  String addPrefixToUrl(String url) {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://' + url;
    } else if (url.startsWith('http://')) {
      url = 'https://' + url.substring(7);
    }
    return url;
  }

  Future<void> saveUrl(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedUrls = prefs.getStringList('visited_urls') ?? [];
    if (!savedUrls.contains(url)) {
      savedUrls.add(url);
      await prefs.setStringList('visited_urls', savedUrls);
    }
  }
}
