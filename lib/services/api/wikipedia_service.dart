// lib/services/api/wikipedia_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../utils/constants.dart';

class WikipediaService {
  static final WikipediaService instance = WikipediaService._();
  WikipediaService._();

  Future<Map<String, dynamic>?> fetchPageSummary(String pageTitle) async {
    try {
      final url = Uri.parse('${AppConstants.wikipediaApiUrl}$pageTitle');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Wikipedia error: $e');
    }
    return null;
  }

  Future<String?> fetchFullContent(String pageTitle) async {
    try {
      final url = Uri.parse(
          '${AppConstants.wikipediaSearchUrl}?action=parse&page=$pageTitle&format=json&prop=text&origin=*');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['parse']['text']['*'];
      }
    } catch (e) {
      print('Parse error: $e');
    }
    return null;
  }

  Future<String?> fetchPageImage(String pageTitle) async {
    try {
      final url = Uri.parse(
          '${AppConstants.wikipediaSearchUrl}?action=query&titles=$pageTitle&prop=pageimages&format=json&pithumbsize=500&origin=*');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final pages = data['query']['pages'] as Map<String, dynamic>;
        for (var page in pages.values) {
          if (page['thumbnail'] != null) {
            return page['thumbnail']['source'];
          }
        }
      }
    } catch (e) {
      print('Image error: $e');
    }
    return null;
  }
}