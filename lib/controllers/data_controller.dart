import '../services/api/wikipedia_service.dart';

class DataController {
  static final DataController instance = DataController._();
  DataController._();

  final Map<String, Map<String, dynamic>> _cache = {};

  Future<Map<String, dynamic>?> getWikiData(String name, {String? category}) async {
    // 1. Cek Cache dulu biar hemat kuota
    if (_cache.containsKey(name)) {
      return _cache[name];
    }

    // 2. Coba cari dengan nama langsung (Misal: "Andromeda")
    var data = await WikipediaService.instance.fetchPageSummary(name);

    // 3. Jika gagal, coba tambahkan kata kategori di belakangnya (Misal: "Bima Sakti (galaksi)")
    if (data == null && category != null) {
      String fallbackName = "$name ($category)";
      data = await WikipediaService.instance.fetchPageSummary(fallbackName);
    }

    // 4. Jika masih gagal, coba tambahkan kata kategori di depannya (Misal: "Galaksi Sombrero")
    if (data == null && category != null) {
      String prefixName = "${category[0].toUpperCase()}${category.substring(1)} $name";
      data = await WikipediaService.instance.fetchPageSummary(prefixName);
    }

    // Simpan ke cache jika ketemu (biar pencarian berikutnya instan)
    if (data != null) {
      _cache[name] = data;
    }
    
    return data;
  }
}