import '../../models/fenomena_model.dart';
import 'database_helper.dart';

class FenomenaService {
  static final FenomenaService _instance = FenomenaService._internal();
  FenomenaService._internal();
  static FenomenaService get instance => _instance;

  bool _initialized = false;

  // Data statis untuk seed
  final List<Map<String, dynamic>> _seedData = [
    // --- INDONESIA ---
    {
      'nama': "Gerhana Matahari Cincin Indonesia",
      'tanggal': "2026-06-10",
      'deskripsi_singkat': "Cincin api di langit Indonesia.",
      'deskripsi_lengkap':
          "Gerhana Matahari Cincin terlihat sangat jelas melintasi wilayah Indonesia, terutama bagian ekuator. Saat Bulan berada sedikit lebih jauh dari Bumi, ukurannya tidak cukup besar untuk menutupi seluruh piringan Matahari, sehingga menciptakan bentuk cincin terang.",
      'poin_pelajaran':
          " Terjadi saat Bulan berada di apogee (titik terjauh dari Bumi).| Tidak aman dilihat dengan mata telanjang tanpa kacamata gerhana khusus.| Jalur gerhana melintasi beberapa pulau besar di Indonesia.",
      'sumber': "BMKG, Observatorium Bosscha",
      'waktu_terbaik_utc': "03:00",
      'negara': "Indonesia",
    },
    {
      'nama': "Uji Coba Fenomena Astronomi Dummy",
      'tanggal': "2026-06-09",
      'deskripsi_singkat': "Data dummy untuk menguji pengingat waktu.",
      'deskripsi_lengkap':
          "Fenomena dummy ini disiapkan agar jam pengamatan dapat diedit dengan mudah saat pengujian notifikasi dan tampilan waktu lokal.",
      'poin_pelajaran':
          " Dapat dipakai untuk menguji pengingat sehari sebelum dan tepat pada jam kejadian.| Waktu di hardcode agar mudah diedit saat pengembangan.| Gunakan data ini untuk verifikasi zona waktu terdeteksi.",
      'sumber': "Data dummy internal AstroEdu",
      'waktu_terbaik_utc': "20:53",
      'negara': "Indonesia",
    },
    {
      'nama': "Hujan Meteor Ekuator (Aquarid)",
      'tanggal': "2026-06-12",
      'deskripsi_singkat': "Hujan meteor tampak jelas dari khatulistiwa.",
      'deskripsi_lengkap':
          "Fenomena hujan meteor Aquarid yang sangat aktif di wilayah khatulistiwa, memberikan pertunjukan langit yang spektakuler bagi pengamat di Indonesia dengan tingkat aktivitas hingga 50 meteor per jam.",
      'poin_pelajaran':
          " Sangat baik diamati dari garis khatulistiwa.| Puncak aktivitas meteor mencapai 50 meteor per jam.| Pengamatan terbaik dilakukan di tempat minim polusi cahaya.",
      'sumber': "LAPAN, In-The-Sky.org",
      'waktu_terbaik_utc': "20:00",
      'negara': "Indonesia",
    },
    // --- COLOMBIA ---
    {
      'nama': "Eclipse Solar Total Sudamérica",
      'tanggal': "2026-06-11",
      'deskripsi_singkat': "Gerhana Matahari Total di Kolombia.",
      'deskripsi_lengkap':
          "Sebuah gerhana matahari total yang langka melintasi negara Kolombia dan beberapa negara Amerika Selatan lainnya. Langit akan berubah menjadi gelap seperti malam hari selama beberapa menit.",
      'poin_pelajaran':
          " Korona matahari dapat terlihat dengan jelas.| Suhu udara dapat turun drastis selama puncak gerhana.| Terlihat jelas dari wilayah Andes, Kolombia.",
      'sumber': "NASA, Observatorio Astronómico Nacional de Colombia",
      'waktu_terbaik_utc': "17:00",
      'negara': "Colombia",
    },
    {
      'nama': "Lluvia de Meteoros Andina",
      'tanggal': "2026-06-13",
      'deskripsi_singkat': "Hujan meteor yang indah melintasi pegunungan Andes.",
      'deskripsi_lengkap':
          "Hujan meteor lokal yang sangat indah saat diamati dari dataran tinggi Andes di Kolombia. Udara tipis pegunungan membuat meteor tampak lebih terang dan jelas.",
      'poin_pelajaran':
          " Ketinggian pegunungan Andes mengurangi distorsi atmosfer.| Meteor terlihat lebih terang dan tajam.| Waktu terbaik diamati menjelang fajar.",
      'sumber': "Red de Astronomía de Colombia",
      'waktu_terbaik_utc': "09:00",
      'negara': "Colombia",
    },
  ];

  Future<void>? _seedFuture;

  Future<void> _seedDatabase() async {
    if (_initialized) return;
    if (_seedFuture != null) {
      await _seedFuture;
      return;
    }
    
    _seedFuture = _doSeedDatabase();
    await _seedFuture;
    _initialized = true;
    _seedFuture = null;
  }

  Future<void> _doSeedDatabase() async {
    final db = DatabaseHelper.instance;
    for (var fenomena in _seedData) {
      try {
        await db.insertFenomenaIfNotExists(fenomena);
      } catch (e) {
        // Ignored if duplicate
      }
    }
  }

  Future<List<FenomenaModel>> get semuaFenomena async {
    await _seedDatabase();
    final db = DatabaseHelper.instance;
    final data = await db.getAllFenomena();
    return data.map((f) => FenomenaModel.fromMap(f)).toList();
  }

  Future<FenomenaModel?> getFenomenaById(int id) async {
    await _seedDatabase();
    final db = DatabaseHelper.instance;
    final data = await db.getFenomenaById(id);
    return data != null ? FenomenaModel.fromMap(data) : null;
  }

  Future<int> addFenomena(FenomenaModel fenomena) async {
    final db = DatabaseHelper.instance;
    return await db.insertFenomena(fenomena.toMap());
  }

  Future<FenomenaModel?> getFenomenaTerdekat(DateTime tanggal, {bool hanyaTanggalSama = true}) async {
    await _seedDatabase();
    final semua = await semuaFenomena;
    
    if (hanyaTanggalSama) {
      final tanggalString = tanggal.toIso8601String().split('T')[0];
      try {
        return semua.firstWhere((f) => f.tanggal == tanggalString);
      } catch (e) {
        return semua.firstWhere(
          (f) => DateTime.parse(f.tanggal).isAfter(tanggal),
          orElse: () => semua.last,
        );
      }
    } else {
      FenomenaModel? terdekat;
      Duration? selisihTerkecil;
      for (var fenomena in semua) {
        final diff = (DateTime.parse(fenomena.tanggal).difference(tanggal)).abs();
        if (selisihTerkecil == null || diff < selisihTerkecil) {
          selisihTerkecil = diff;
          terdekat = fenomena;
        }
      }
      return terdekat;
    }
  }

  Future<FenomenaModel?> getFenomenaHariIni(String negaraUser) async {
    await _seedDatabase();
    final sekarang = DateTime.now();
    final tanggalString = sekarang.toIso8601String().split('T')[0];
    final semua = await semuaFenomena;
    
    // Filter by country
    final fenomenaNegara = semua.where((f) => f.negara.toLowerCase() == negaraUser.toLowerCase()).toList();
    if (fenomenaNegara.isEmpty) {
      // Fallback jika tidak ada fenomena khusus negara tersebut, cari yang terdekat global
      return semua.firstWhere((f) => DateTime.parse(f.tanggal).isAfter(sekarang), orElse: () => semua.last);
    }

    try {
      return fenomenaNegara.firstWhere((f) => f.tanggal == tanggalString);
    } catch (e) {
      // Cari yang terdekat setelah hari ini
      try {
        return fenomenaNegara.firstWhere((f) => DateTime.parse(f.tanggal).isAfter(sekarang));
      } catch (e) {
        return fenomenaNegara.last; // Fallback
      }
    }
  }
}