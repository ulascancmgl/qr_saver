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
      downloadAndDisplayPDF();
    }
  }

  Future<void> downloadAndDisplayPDF() async {
    final directory = await getTemporaryDirectory();
    final fileName = widget.url.split('/').last;
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    if (!file.existsSync()) {
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
  }

  Future<void> deletePDF() async {
    if (_pdfFilePath != null) {
      final file = File(_pdfFilePath!);
      if (file.existsSync()) {
        await file.delete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await deletePDF();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Website'),
          backgroundColor: Colors.purple,
        ),
        backgroundColor: Colors.blueGrey,
        body: _pdfFilePath != null
            ? PDFView(
          filePath: _pdfFilePath!,
        )
            : InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
        ),
      ),
    );
  }

}

