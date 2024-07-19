import 'dart:developer';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  WebViewController? webViewController;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _loadSessionData();
  }

  void _initializeWebView() {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {},
        onPageStarted: (String url) {
          log("The started page $url");
        },
        onPageFinished: (String url) async {
          log("The page finished $url");
          await _saveSessionData(url);
        },
        onWebResourceError: (WebResourceError error) {
          log('error ');
        },
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.contains('facebook')) {
            log('not valid');
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(Uri.parse(
          'https://lastadmin.atlassian.net/servicedesk/customer/portal/2/user/login?destination=portal%2F2'));
  }

  Future<void> _saveSessionData(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastVisitedUrl', url);
  }

  Future<void> _loadSessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final lastVisitedUrl = prefs.getString('lastVisitedUrl') ??
        'https://lastadmin.atlassian.net/servicedesk/customer/portal/2/user/login?destination=portal%2F2';
    webViewController?.loadRequest(Uri.parse(lastVisitedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: webViewController!),
      ),
    );
  }
}
