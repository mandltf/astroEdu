// lib/services/api/currency_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class CurrencyService {
  static final CurrencyService instance = CurrencyService._();
  CurrencyService._();

  Map<String, double> _rates = {};
  DateTime? _lastFetch;

  Future<Map<String, double>> getRates() async {
    if (_rates.isNotEmpty && _lastFetch != null &&
        DateTime.now().difference(_lastFetch!).inHours < 1) {
      return _rates;
    }
    try {
      final response = await http.get(Uri.parse(AppConstants.currencyApiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = Map<String, double>.from(
            (data['rates'] as Map).map((k, v) => MapEntry(k, (v as num).toDouble())));
        _rates = rates;
        _lastFetch = DateTime.now();
        return _rates;
      }
    } catch (_) {}
    // Fallback rates
    return {
      'USD': 1.0,
      'IDR': 15800.0,
      'EUR': 0.92,
      'GBP': 0.79,
      'JPY': 149.5,
      'SGD': 1.34,
      'MYR': 4.72,
      'AUD': 1.53,
    };
  }

  Future<double> convert(double amount, String from, String to) async {
    final rates = await getRates();
    final fromRate = rates[from] ?? 1.0;
    final toRate = rates[to] ?? 1.0;
    final inUSD = amount / fromRate;
    return inUSD * toRate;
  }

  static const List<Map<String, String>> supportedCurrencies = [
    {'code': 'USD', 'name': 'US Dollar', 'symbol': '\$', 'flag': '🇺🇸'},
    {'code': 'IDR', 'name': 'Rupiah Indonesia', 'symbol': 'Rp', 'flag': '🇮🇩'},
    {'code': 'EUR', 'name': 'Euro', 'symbol': '€', 'flag': '🇪🇺'},
    {'code': 'GBP', 'name': 'British Pound', 'symbol': '£', 'flag': '🇬🇧'},
    {'code': 'JPY', 'name': 'Japanese Yen', 'symbol': '¥', 'flag': '🇯🇵'},
    {'code': 'SGD', 'name': 'Singapore Dollar', 'symbol': 'S\$', 'flag': '🇸🇬'},
    {'code': 'MYR', 'name': 'Malaysian Ringgit', 'symbol': 'RM', 'flag': '🇲🇾'},
    {'code': 'AUD', 'name': 'Australian Dollar', 'symbol': 'A\$', 'flag': '🇦🇺'},
  ];
}