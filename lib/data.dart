import 'dart:convert';
import 'package:http/http.dart' as http;

/// Источники данных RateScout (raw GitHub — надёжно, тот же контент, что на сайте).
const _base = 'https://raw.githubusercontent.com/sementsul/ratescout/main';
const currenciesUrl = '$_base/currencies.json';
const historyUrl = '$_base/history.json';
const siteUrl = 'https://ratescout.ru/';

class Currency {
  final String slug;
  final String name;
  final String ticker;
  final String category;
  final double usdt; // текущий курс в USDT (последняя точка истории)

  Currency({
    required this.slug,
    required this.name,
    required this.ticker,
    required this.category,
    required this.usdt,
  });

  String get label => ticker.isNotEmpty ? '$ticker · $name' : name;
}

class RateData {
  final List<Currency> currencies;
  final DateTime? generatedAt;
  final String unit;
  RateData(this.currencies, this.generatedAt, this.unit);
}

/// Грузит и объединяет currencies.json + history.json → список валют с текущим курсом в USDT.
Future<RateData> loadData() async {
  final resp = await Future.wait([
    http.get(Uri.parse(currenciesUrl)),
    http.get(Uri.parse(historyUrl)),
  ]);
  if (resp[0].statusCode != 200 || resp[1].statusCode != 200) {
    throw Exception('Не удалось загрузить данные (HTTP ${resp[0].statusCode}/${resp[1].statusCode}).');
  }

  final cur = json.decode(utf8.decode(resp[0].bodyBytes)) as Map<String, dynamic>;
  final his = json.decode(utf8.decode(resp[1].bodyBytes)) as Map<String, dynamic>;

  final series = (his['series'] as Map<String, dynamic>? ?? {});
  final unit = (his['unit'] as String?) ?? 'USDT';
  DateTime? gen;
  final ga = his['generated_at'];
  if (ga is int) gen = DateTime.fromMillisecondsSinceEpoch(ga * 1000, isUtc: true);

  double? latest(String slug) {
    final pts = series[slug];
    if (pts is List && pts.isNotEmpty) {
      final last = pts.last;
      if (last is List && last.length >= 2 && last[1] is num) return (last[1] as num).toDouble();
    }
    return null;
  }

  final curMap = (cur['currencies'] as Map<String, dynamic>? ?? {});
  final out = <Currency>[];
  curMap.forEach((slug, v) {
    final m = v as Map<String, dynamic>;
    final rate = latest(slug);
    if (rate == null || rate <= 0) return; // показываем только валюты с актуальным курсом
    out.add(Currency(
      slug: slug,
      name: (m['name'] ?? slug).toString(),
      ticker: (m['ticker'] ?? '').toString(),
      category: (m['category'] ?? '').toString(),
      usdt: rate,
    ));
  });

  out.sort((a, b) {
    final c = a.category.compareTo(b.category);
    return c != 0 ? c : a.name.compareTo(b.name);
  });
  return RateData(out, gen, unit);
}
