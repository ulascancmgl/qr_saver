import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DownloadedListPage extends StatefulWidget {
  @override
  _DownloadedListPageState createState() => _DownloadedListPageState();
}

class _DownloadedListPageState extends State<DownloadedListPage> {
  List<String> _pdfPaths = [];

  @override
  void initState() {
    super.initState();
    loadDownloadedPDFs();
  }

  Future<void> loadDownloadedPDFs() async {
    final directory = Directory((await getTemporaryDirectory()).path);
    final pdfFiles =
        directory.listSync().where((file) => file.path.endsWith('.pdf'));
    setState(() {
      _pdfPaths = pdfFiles.map((file) => file.path).toList();
    });
  }

  Future<void> deletePDF(String filePath) async {
    final file = File(filePath);
    if (file.existsSync()) {
      await file.delete();
      setState(() {
        _pdfPaths.remove(filePath);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Downloaded PDFs'),
        backgroundColor: Colors.purple,
      ),
      backgroundColor: Colors.blueGrey,
      body: ListView.builder(
        itemCount: _pdfPaths.length,
        itemBuilder: (context, index) {
          final filePath = _pdfPaths[index];
          final fileName = filePath.split('/').last;
          return ListTile(
            title: Text(fileName),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => deletePDF(filePath),
            ),
          );
        },
      ),
    );
  }
}
