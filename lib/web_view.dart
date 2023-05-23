import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class WebViewPage extends StatefulWidget {
  final String url;

  const WebViewPage({required this.url});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  InAppWebViewController? _webViewController;
  String? _pdfFilePath;

  @override
  void initState() {
    super.initState();
    if (widget.url.endsWith('.pdf')) {
      displayPDF();
    }
  }

  Future<void> displayPDF() async {
    final directory = await getTemporaryDirectory();
    final fileName = widget.url.split('/').last;
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    if (file.existsSync()) {
      final fileStat = file.statSync();
      final lastModified = fileStat.modified;
      final currentTime = DateTime.now();
      final difference = currentTime.difference(lastModified);
      final hoursPassed = difference.inHours;

      if (hoursPassed >= 2) {
        deletePDF(file);
      } else {
        setState(() {
          _pdfFilePath = filePath;
        });
      }
    } else {
      downloadPDF();
    }
  }

  Future<void> downloadPDF() async {
    final directory = await getTemporaryDirectory();
    final fileName = widget.url.split('/').last;
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    final dio = Dio();
    try {
      await dio.download(widget.url, filePath);
      setState(() {
        _pdfFilePath = filePath;
      });
    } catch (e) {
      print('Error downloading PDF: $e');
    }
  }

  Future<void> deletePDF(File file) async {
    try {
      await file.delete();
      downloadPDF();
    } catch (e) {
      print('Error deleting PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Website',
              style: TextStyle(fontFamily: 'Helvetica', color: Colors.white)),
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
        body: _pdfFilePath != null
            ? PDFView(
                filePath: _pdfFilePath!,
              )
            : InAppWebView(
                initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
                onWebViewCreated: (controller) {
                  _webViewController = controller;

                  _webViewController?.setOptions(
                    options: InAppWebViewGroupOptions(
                      android: AndroidInAppWebViewOptions(
                        builtInZoomControls: false,
                        useWideViewPort: true,
                        loadWithOverviewMode: true,
                        hardwareAcceleration: false,
                      ),
                      ios: IOSInAppWebViewOptions(
                        allowsInlineMediaPlayback: true,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
