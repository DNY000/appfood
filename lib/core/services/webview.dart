import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VNPayWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String userId;
  final Function(bool success, String? responseCode) onComplete;

  const VNPayWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.userId,
    required this.onComplete,
  });

  @override
  State<VNPayWebViewScreen> createState() => _VNPayWebViewScreenState();
}

class _VNPayWebViewScreenState extends State<VNPayWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  Timer? _timeoutTimer;
  static const String _returnUrlScheme = 'shipper-vnpay-return://vnpay-return';

  @override
  void initState() {
    super.initState();
    _timeoutTimer = Timer(const Duration(minutes: 15), () {
      if (mounted) {
        widget.onComplete(false, '99');
        Navigator.of(context).pop();
      }
    });
    _initWebViewController();
  }

  void _initWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            print('Page started loading: $url'); // Debug log
            if (mounted) setState(() => _isLoading = true);
            _checkReturnUrl(url);
          },
          onPageFinished: (url) {
            print('Page finished loading: $url'); // Debug log
            if (mounted) setState(() => _isLoading = false);
            _checkReturnUrl(url);
          },
          onNavigationRequest: (request) {
            print('Navigation request: ${request.url}'); // Debug log
            _checkReturnUrl(request.url);
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            print('Web resource error: ${error.description}'); // Debug log
          },
        ),
      )
      ..setBackgroundColor(Colors.white)
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkReturnUrl(String url) {
    print('Checking URL: $url'); // Debug log

    // Kiểm tra cả deep link và URL parameters
    if (url.startsWith(_returnUrlScheme) ||
        url.contains('vnp_ResponseCode=') ||
        url.contains('shipper-vnpay-return')) {
      try {
        final uri = Uri.parse(url);
        final params = uri.queryParameters;
        final responseCode = params['vnp_ResponseCode'];

        print('Response Code: $responseCode'); // Debug log

        if (responseCode != null) {
          _timeoutTimer?.cancel();
          if (mounted) {
            Navigator.of(context).pop();
            widget.onComplete(responseCode == '00', responseCode);
          }
        }
      } catch (e) {
        print('Error parsing URL: $e'); // Debug log
        // Không throw exception, chỉ log lỗi
      }
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán VNPay'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _timeoutTimer?.cancel();
            Navigator.of(context).pop();
            widget.onComplete(false, '24'); // Hủy giao dịch
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Đang tải trang thanh toán...'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
