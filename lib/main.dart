import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

/// Приложение = профессиональный монитор RateScout в WebView (та же страница и дизайн, что на сайте).
const monitorUrl = 'https://ratescout.ru/monitor/';

void main() => runApp(const RateScoutApp());

const _bg = Color(0xFF111111); // как на сайте (DOS-палитра)
const _cyan = Color(0xFF55FFFF);

class RateScoutApp extends StatelessWidget {
  const RateScoutApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RateScout',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _bg,
        appBarTheme: const AppBarTheme(backgroundColor: _bg, foregroundColor: _cyan),
        colorScheme: const ColorScheme.dark(primary: _cyan, surface: _bg),
        useMaterial3: true,
      ),
      home: const MonitorPage(),
    );
  }
}

class MonitorPage extends StatefulWidget {
  const MonitorPage({super.key});
  @override
  State<MonitorPage> createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  InAppWebViewController? _c;
  double _progress = 0;

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(monitorUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_c != null && await _c!.canGoBack()) {
          _c!.goBack();
        } else if (mounted) {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('RateScout ⇄ монитор'),
          actions: [
            IconButton(
                tooltip: 'Обновить', onPressed: () => _c?.reload(), icon: const Icon(Icons.refresh)),
            IconButton(
                tooltip: 'Открыть в браузере', onPressed: _openInBrowser, icon: const Icon(Icons.public)),
          ],
          bottom: _progress < 1.0
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(2),
                  child: LinearProgressIndicator(value: _progress == 0 ? null : _progress, minHeight: 2),
                )
              : null,
        ),
        body: SafeArea(
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(monitorUrl)),
            initialSettings: InAppWebViewSettings(
              transparentBackground: true,
              supportZoom: true,
              javaScriptEnabled: true,
            ),
            onWebViewCreated: (c) => _c = c,
            onProgressChanged: (c, p) => setState(() => _progress = p / 100.0),
          ),
        ),
      ),
    );
  }
}
