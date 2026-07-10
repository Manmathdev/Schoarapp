import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme.dart';

class PdfViewerPage extends StatefulWidget {
  final String assetPath;
  final String title;

  const PdfViewerPage({super.key, required this.assetPath, required this.title});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late final PdfControllerPinch _controller;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _controller = PdfControllerPinch(
      document: PdfDocument.openAsset(widget.assetPath),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _share(BuildContext context) async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      // Assets live inside the app bundle, not on the real filesystem, so we
      // copy the bytes to a temp file first — that's what the OS share
      // sheet and other apps can actually open.
      final bytes = await rootBundle.load(widget.assetPath);
      final tempDir = await getTemporaryDirectory();
      final fileName = widget.assetPath.split('/').last;
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          text: widget.title,
          files: [XFile(file.path)],
          sharePositionOrigin: box != null ? (box.localToGlobal(Offset.zero) & box.size) : null,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not share this file.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Scaffold(
      backgroundColor: palette.bgBase,
      appBar: AppBar(
        backgroundColor: palette.bgBase,
        elevation: 0,
        foregroundColor: palette.textPrimary,
        title: Text(
          widget.title,
          style: ScholarStyles.serif(fontSize: 18, fontWeight: FontWeight.w600, color: palette.textPrimary),
        ),
        actions: [
          IconButton(
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.ios_share),
            tooltip: 'Share',
            onPressed: _isSharing ? null : () => _share(context),
          ),
        ],
      ),
      body: PdfViewPinch(
        controller: _controller,
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) => Center(
            child: CircularProgressIndicator(color: palette.accent),
          ),
          pageLoaderBuilder: (_) => Center(
            child: CircularProgressIndicator(color: palette.accent),
          ),
          errorBuilder: (_, error) => Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: palette.statusRevision),
                  const SizedBox(height: 16),
                  Text(
                    'Could not open this PDF.\n$error',
                    textAlign: TextAlign.center,
                    style: ScholarStyles.sans(color: palette.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
