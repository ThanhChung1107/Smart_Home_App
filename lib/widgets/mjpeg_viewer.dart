// widgets/mjpeg_viewer.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MjpegViewer extends StatefulWidget {
  final String streamUrl;
  final double aspectRatio;

  const MjpegViewer({
    Key? key,
    required this.streamUrl,
    this.aspectRatio = 16 / 9,
  }) : super(key: key);

  @override
  _MjpegViewerState createState() => _MjpegViewerState();
}

class _MjpegViewerState extends State<MjpegViewer> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.streamUrl));
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    SizedBox(height: 8),
                    Text(
                      'Đang kết nối camera...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
