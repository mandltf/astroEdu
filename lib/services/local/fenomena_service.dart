import '../../models/fenomena_model.dart';
import 'database_helper.dart';

class FenomenaService {
  static final FenomenaService _instance = FenomenaService._internal();
  FenomenaService._internal();
  static FenomenaService get instance => _instance;

  bool _initialized = false;

  // Data statis untuk seed
  final List<Map<String, dynamic>> _seedData = [
    {
      'nama': "Gerhana Bulan Total / Blood Moon",
      'tanggal': "2026-03-03",
      'deskripsi_singkat': "Bulan tampak merah total saat masuk umbra Bumi.",
      'deskripsi_lengkap':
          "Gerhana Bulan Total terjadi saat Bulan, Bumi, dan Matahari sejajar dalam satu garis lurus. Saat itu, Bulan akan masuk ke dalam bayangan umbra Bumi dan akan tampak berwarna merah gelap. Warna merah ini disebabkan oleh cahaya Matahari yang dibiaskan oleh atmosfer Bumi.",
      'poin_pelajaran':
          " Gerhana Bulan terjadi saat Bumi berada di antara Matahari dan Bulan.| Warna merah terjadi karena hamburan Rayleigh di atmosfer Bumi.| Gerhana bulan aman dilihat tanpa pelindung mata.",
      'sumber': "BMKG, NASA",
      'waktu_terbaik_utc': "18:00",
    },
    {
      'nama': "Hujan Meteor Lyrid",
      'tanggal': "2026-04-22",
      'deskripsi_singkat': "Hujan meteor Lyrid, puncaknya 22-23 April.",
      'deskripsi_lengkap':
          "Lyrid adalah salah satu hujan meteor tertua yang diketahui, telah diamati selama lebih dari 2000 tahun. Hujan meteor ini terjadi ketika Bumi melewati jalur debu yang ditinggalkan oleh komet C/1861 G1 Thatcher.",
      'poin_pelajaran':
          " Meteor adalah debu/komet yang terbakar saat masuk atmosfer Bumi.| Lyrid terjadi setiap tahun pada bulan April.| Puncak terbaik diamati dari lokasi gelap setelah tengah malam.",
      'sumber': "In-The-Sky.org, NASA",
      'waktu_terbaik_utc': "02:00",
    },
    {
      'nama': "Hujan Meteor Eta Aquarid",
      'tanggal': "2026-05-05",
      'deskripsi_singkat': "Hujan meteor Eta Aquarid, puncaknya 5-6 Mei.",
      'deskripsi_lengkap':
          "Hujan meteor Eta Aquarid berasal dari debu Komet Halley. Ini adalah salah satu dari dua hujan meteor besar yang berasal dari komet terkenal ini.",
      'poin_pelajaran':
          " Meteor ini berasal dari Komet Halley.| Kecepatan meteor bisa mencapai 66 km/s.| Waktu terbaik mengamati adalah sebelum fajar (pukul 03.00 - 05.00).",
      'sumber': "In-The-Sky.org, NASA",
      'waktu_terbaik_utc': "20:00",
    },
    {
      'nama': "Hujan Meteor Perseid",
      'tanggal': "2026-08-12",
      'deskripsi_singkat': "Hujan meteor Perseid, puncaknya 12-13 Agustus.",
      'deskripsi_lengkap':
          "Perseid adalah hujan meteor paling populer dan paling terang. Hujan meteor ini terjadi ketika Bumi melewati jalur debu yang ditinggalkan oleh komet Swift-Tuttle.",
      'poin_pelajaran':
          " Meteor Perseid berasal dari rasi Perseus.| Komet induknya adalah Swift-Tuttle.| Waktu terbaik mengamati mulai tengah malam hingga subuh.",
      'sumber': "In-The-Sky.org, NASA",
      'waktu_terbaik_utc': "21:00",
    },
    {
      'nama': "Hujan Meteor Geminid",
      'tanggal': "2026-12-13",
      'deskripsi_singkat': "Hujan meteor Geminid, puncaknya 13-14 Desember.",
      'deskripsi_lengkap':
          "Geminid sering disebut sebagai hujan meteor terbaik tahun ini. Hujan meteor ini berasal dari asteroid 3200 Phaethon, yang jarang diketahui.",
      'poin_pelajaran':
          " Sumber Geminid adalah asteroid 3200 Phaethon.| Meteor ini bisa terlihat dari Indonesia mulai malam hingga dini hari.| Puncak aktivitas hingga 150 meteor per jam di lokasi tanpa polusi cahaya.",
      'sumber': "NASA, Starwalk",
      'waktu_terbaik_utc': "22:00",
    },
    {
      'nama': "Supermoon Pertama",
      'tanggal': "2026-08-01",
      'deskripsi_singkat': "Supermoon: Bulan tampak lebih besar dan terang.",
      'deskripsi_lengkap':
          "Supermoon terjadi saat bulan purnama bertepatan dengan perigee (jarak terdekat Bulan ke Bumi). Saat ini, Bulan akan tampak 14% lebih besar dan 30% lebih terang dari bulan purnama normal.",
      'poin_pelajaran':
          " Bulan purnama di perigee (jarak terdekat).| Tampak lebih besar dan terang dari biasanya.| Dapat diamati dengan mata telanjang sepanjang malam.",
      'sumber': "NASA, BMKG",
      'waktu_terbaik_utc': "12:00",
    },
  ];

  Future<void> _seedDatabase() async {
    if (_initialized) return;
    
    final db = DatabaseHelper.instance;
    for (var fenomena in _seedData) {
      await db.insertFenomenaIfNotExists(fenomena);
    }
    _initialized = true;
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

  Future<FenomenaModel?> getFenomenaHariIni() async {
    await _seedDatabase();
    final sekarang = DateTime.now();
    final tanggalString = sekarang.toIso8601String().split('T')[0];
    final semua = await semuaFenomena;

    try {
      return semua.firstWhere((f) => f.tanggal == tanggalString);
    } catch (e) {
      return semua.firstWhere(
        (f) => DateTime.parse(f.tanggal).isAfter(sekarang),
        orElse: () => semua.last,
      );
    }
  }
}