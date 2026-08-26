import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle, rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/app_theme.dart';

/// The two documents the stores require, rendered from files bundled with the
/// app.
enum LegalDocument {
  privacy('Privacy Policy', 'assets/legal/privacy.html'),
  support('Support', 'assets/legal/support.html');

  const LegalDocument(this.title, this.asset);

  final String title;
  final String asset;

  static LegalDocument fromName(String? name) => values.firstWhere(
    (document) => document.name == name,
    orElse: () => LegalDocument.privacy,
  );
}

/// Shows a bundled document.
///
/// The HTML ships inside the app rather than being fetched, so these pages open
/// with no connection at all. They are always black on white, independent of the
/// app theme, because that is how the documents are meant to read.
class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key, required this.document});

  final LegalDocument document;

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  final _controller = WebViewController();

  bool _ready = false;
  String? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final html = await rootBundle.loadString(widget.document.asset);

      await _controller.setJavaScriptMode(JavaScriptMode.disabled);
      await _controller.setBackgroundColor(Colors.white);
      await _controller.loadHtmlString(html);

      if (mounted) setState(() => _ready = true);
    } on Exception catch (error) {
      if (mounted) setState(() => _failure = '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.document.title),
        // The page is deliberately black on white, so the bar leaves the app
        // theme behind too and stays legible in either mode.
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
      ),
      body: SafeArea(
        child: _failure != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'This page could not be opened.\n$_failure',
                    textAlign: TextAlign.center,
                    style: context.text.bodyMedium?.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
              )
            : Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (!_ready)
                    const Center(child: CircularProgressIndicator.adaptive()),
                ],
              ),
      ),
    );
  }
}
