import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdfx/pdfx.dart';

import '../utils/services/whatsapp_service.dart';

class DocumentViewerScreen extends StatefulWidget {
  final Map<String, dynamic> media;
  final bool isMyDownloadPage;

  const DocumentViewerScreen(
      {super.key, required this.media, this.isMyDownloadPage = false});

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  PdfControllerPinch? _pdfController;
  bool _pdfError = false;

  bool get _isPdf =>
      (widget.media['extension']?.toString().toLowerCase() == 'pdf');

  @override
  void initState() {
    super.initState();
    if (_isPdf) {
      try {
        _pdfController = PdfControllerPinch(
          document: PdfDocument.openFile(widget.media['path']),
          initialPage: 1,
        );
      } catch (_) {
        _pdfError = true;
      }
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  IconData _getDocumentIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111B21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF202C33),
        title: Text(
          widget.media['name'],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () async {
              await Share.shareXFiles(
                [XFile(widget.media['path'])],
                text: 'Check out this document!',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isPdf
                ? (_pdfError || _pdfController == null)
                    ? const Center(
                        child: Text(
                          'Unable to open PDF',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : PdfViewPinch(
                        controller: _pdfController!,
                        backgroundDecoration:
                            const BoxDecoration(color: Color(0xFF111B21)),
                      )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getDocumentIcon(widget.media['extension']),
                          size: 100,
                          color: const Color(0xFF00A884),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.media['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${widget.media['type']} • ${_formatFileSize(widget.media['size'])}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          !widget.isMyDownloadPage
              ? Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 25),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final result = await WhatsAppService()
                            .copyToDownloads(widget.media);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result
                                  ? 'Document saved successfully!'
                                  : 'Failed to save document.'),
                              backgroundColor:
                                  result ? Colors.green : Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A884),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.save_alt, color: Colors.white),
                      label: const Text(
                        'Save to Downloads',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
