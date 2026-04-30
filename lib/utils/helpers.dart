// lib/utils/helpers.dart
import 'package:intl/intl.dart';

class Helpers {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  static String formatCurrency(double amount, String currencyCode) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: _getSymbol(currencyCode));
    return format.format(amount);
  }

  static String _getSymbol(String code) {
    switch (code) {
      case 'USD': return '\$';
      case 'IDR': return 'Rp';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      default: return code;
    }
  }

  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }
}