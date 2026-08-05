import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String redirectUrl;

  const PaymentWebViewPage({super.key, required this.redirectUrl});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;

            debugPrint(url);

            if (url.contains("transaction_status=settlement") ||
                url.contains("transaction_status=capture")) {
              Navigator.pop(context, true);
              return NavigationDecision.prevent;
            }

            if (url.contains("transaction_status=deny") ||
                url.contains("transaction_status=cancel") ||
                url.contains("transaction_status=expire")) {
              Navigator.pop(context, false);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.redirectUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran Nextcart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context, false),
          ),
        ],
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
