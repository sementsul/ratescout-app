import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data.dart';

void main() => runApp(const RateScoutApp());

const _bg = Color(0xFF111111);
const _panel = Color(0xFF1A1A1A);
const _cyan = Color(0xFF33CCCC);
const _fg = Color(0xFFE6E6E6);

class RateScoutApp extends StatelessWidget {
  const RateScoutApp({super.key});
  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);
    return MaterialApp(
      title: 'RateScout',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: _bg,
        colorScheme: base.colorScheme.copyWith(primary: _cyan, surface: _panel),
        textTheme: base.textTheme.apply(
            fontFamily: 'monospace', bodyColor: _fg, displayColor: _fg),
        appBarTheme: const AppBarTheme(backgroundColor: _bg, foregroundColor: _cyan),
        cardColor: _panel,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<RateData> _future;
  String _query = '';
  Currency? _from, _to;
  final _amountCtrl = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _future = loadData();
  }

  void _reload() => setState(() => _future = loadData());

  Future<void> _openSite() async {
    final uri = Uri.parse(siteUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Не удалось открыть сайт')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RateScout ⇄'),
        actions: [
          IconButton(
              tooltip: 'Обновить', onPressed: _reload, icon: const Icon(Icons.refresh)),
          IconButton(
              tooltip: 'Открыть сайт', onPressed: _openSite, icon: const Icon(Icons.public)),
        ],
      ),
      body: FutureBuilder<RateData>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator(color: _cyan));
          }
          if (snap.hasError) {
            return _ErrorView(message: '${snap.error}', onRetry: _reload);
          }
          final data = snap.data!;
          _from ??= data.currencies.isNotEmpty ? data.currencies.first : null;
          _to ??= data.currencies.length > 1 ? data.currencies[1] : _from;

          final q = _query.trim().toLowerCase();
          final list = q.isEmpty
              ? data.currencies
              : data.currencies
                  .where((c) =>
                      c.name.toLowerCase().contains(q) ||
                      c.ticker.toLowerCase().contains(q))
                  .toList();

          return Column(
            children: [
              _converter(data),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(color: _fg),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Поиск валюты…',
                    prefixIcon: const Icon(Icons.search, color: _cyan),
                    filled: true,
                    fillColor: _panel,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFF262626)),
                  itemBuilder: (_, i) {
                    final c = list[i];
                    return ListTile(
                      dense: true,
                      title: Text(c.label, style: const TextStyle(color: _fg)),
                      subtitle: Text(c.category, style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 12)),
                      trailing: Text('${_fmt(c.usdt)} ${data.unit}',
                          style: const TextStyle(color: _cyan, fontFeatures: [])),
                    );
                  },
                ),
              ),
              _footer(data),
            ],
          );
        },
      ),
    );
  }

  Widget _converter(RateData data) {
    final items = data.currencies;
    final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
    double? result;
    if (_from != null && _to != null && _to!.usdt > 0) {
      result = amount * _from!.usdt / _to!.usdt;
    }
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Конвертер', style: TextStyle(color: _cyan, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: _fg),
                  decoration: const InputDecoration(isDense: true, labelText: 'Сумма'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _picker(items, _from, (c) => setState(() => _from = c))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.arrow_downward, color: _cyan, size: 18),
              const SizedBox(width: 8),
              Expanded(child: _picker(items, _to, (c) => setState(() => _to = c))),
            ]),
            const SizedBox(height: 10),
            Text(
              result == null
                  ? '—'
                  : '${_fmt(amount)} ${_from?.ticker ?? ''} ≈ ${_fmt(result)} ${_to?.ticker ?? ''}',
              style: const TextStyle(color: _fg, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _picker(List<Currency> items, Currency? value, ValueChanged<Currency?> onCh) {
    return DropdownButton<Currency>(
      value: value,
      isExpanded: true,
      dropdownColor: _panel,
      style: const TextStyle(color: _fg),
      items: items
          .map((c) => DropdownMenuItem(value: c, child: Text(c.ticker.isEmpty ? c.name : c.ticker)))
          .toList(),
      onChanged: onCh,
    );
  }

  Widget _footer(RateData data) {
    final ts = data.generatedAt;
    final s = ts == null
        ? ''
        : 'Обновлено: ${ts.toUtc().toIso8601String().substring(0, 16).replaceFirst("T", " ")} UTC';
    return Container(
      width: double.infinity,
      color: _panel,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Text('$s · данные BestChange · курсы в ${data.unit}',
          style: const TextStyle(color: Color(0xFF8A8A8A), fontSize: 11)),
    );
  }

  static String _fmt(double v) {
    if (v == 0) return '0';
    if (v >= 1000) return v.toStringAsFixed(0);
    if (v >= 1) return v.toStringAsFixed(2);
    if (v >= 0.01) return v.toStringAsFixed(4);
    return v.toStringAsExponential(2);
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.wifi_off, color: _cyan, size: 40),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: _fg)),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Повторить')),
        ]),
      ),
    );
  }
}
