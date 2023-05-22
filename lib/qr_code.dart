import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'url_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'web_view.dart';
import 'package:url_launcher/url_launcher.dart';


class MyQRCodePage extends StatefulWidget {
  @override
  _MyQRCodePageState createState() => _MyQRCodePageState();
}

class _MyQRCodePageState extends State<MyQRCodePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String websiteUrl = '';
  TextEditingController urlController = TextEditingController();

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR kodu tara'),
        backgroundColor: Colors.purple,
      ),
      backgroundColor: Colors.blueGrey,
      body: Column(
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
                  child: Text(
                    '$websiteUrl',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: urlController,
                      decoration: InputDecoration(
                        hintText: 'Site adresini giriniz',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      String enteredUrl = urlController.text.trim();
                      if (enteredUrl.isNotEmpty) {
                        String prefixedUrl = addPrefixToUrl(enteredUrl);
                        saveUrl(prefixedUrl);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WebViewPage(url: prefixedUrl),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    child: Text('Git'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => URLListPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: Text('Kaydedilenler'),
              ),
            ),
          ),
        ],
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
