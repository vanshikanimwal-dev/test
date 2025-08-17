import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// A screen to display a PDF file from a local asset.
class PdfViewerPage extends StatelessWidget {
  final String pdfPath;

  const PdfViewerPage({
    Key? key,
    required this.pdfPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consent Form'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: SfPdfViewer.asset(
        pdfPath,
      ),
    );
  }
}
