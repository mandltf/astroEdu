// lib/controllers/data_controller.dart
import '../services/api/wikipedia_service.dart';

class DataController {
  static final DataController instance = DataController._();
  DataController._();

  final Map<String, Map<String, dynamic>> _cache = {};

  Future<Map<String, dynamic>?> getWikiData(String pageTitle) async {
    if (_cache.containsKey(pageTitle)) {
      return _cache[pageTitle];
    }
    final data = await WikipediaService.instance.fetchPageSummary(pageTitle);
    if (data != null) {
      _cache[pageTitle] = data;
    }
    return data;
  }
}