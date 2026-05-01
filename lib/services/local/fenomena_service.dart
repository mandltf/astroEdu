import '../../models/fenomena_model.dart';

class FenomenaService {
  static final FenomenaService _instance = FenomenaService._internal();
  FenomenaService._internal();
  static FenomenaService get instance => _instance;

  final List<FenomenaModel> _fenomenaList = [
    FenomenaModel(
      id: 1,
      nama: "Gerhana Bulan Total / Blood Moon",
      tanggal: "2026-03-03",
      deskripsiSingkat: "Bulan tampak merah total saat masuk umbra Bumi.",
      deskripsiLengkap: "Gerhana Bulan Total terjadi saat Bulan, Bumi, dan Matahari sejajar...",
      poinPelajaran: [
        " Gerhana Bulan terjadi saat Bumi berada di antara Matahari dan Bulan.",
        " Warna merah terjadi karena hamburan Rayleigh di atmosfer Bumi.",
        " Gerhana bulan aman dilihat tanpa pelindung mata.",
      ],
      sumber: "BMKG, NASA",
      waktuTerbaikUtc: "18:00", // Contoh waktu puncak gerhana
    ),
    FenomenaModel(
      id: 2,
      nama: "Hujan Meteor Lyrid",
      tanggal: "2026-04-22",
      deskripsiSingkat: "Hujan meteor Lyrid, puncaknya 22-23 April.",
      deskripsiLengkap: "Lyrid adalah salah satu hujan meteor tertua yang diketahui...",
      poinPelajaran: [
        " Meteor adalah debu/komet yang terbakar saat masuk atmosfer Bumi.",
        " Lyrid terjadi setiap tahun pada bulan April.",
        " Puncak terbaik diamati dari lokasi gelap setelah tengah malam.",
      ],
      sumber: "In-The-Sky.org, NASA",
      waktuTerbaikUtc: "02:00", // Waktu terbaik setelah tengah malam UTC
    ),
    FenomenaModel(
      id: 3,
      nama: "Hujan Meteor Eta Aquarid",
      tanggal: "2026-05-05",
      deskripsiSingkat: "Hujan meteor Eta Aquarid, puncaknya 5-6 Mei.",
      deskripsiLengkap: "Hujan meteor Eta Aquarid berasal dari debu Komet Halley...",
      poinPelajaran: [
        " Meteor ini berasal dari Komet Halley.",
        " Kecepatan meteor bisa mencapai 66 km/s.",
        " Waktu terbaik mengamati adalah sebelum fajar (pukul 03.00 - 05.00).",
      ],
      sumber: "In-The-Sky.org, NASA",
      waktuTerbaikUtc: "20:00", // Waktu terbaik untuk pengamat di Indonesia (UTC 20:00 = WIB 03:00)
    ),
    // ... tambahkan waktuTerbaikUtc untuk semua fenomena lainnya
    FenomenaModel(
      id: 4,
      nama: "Hujan Meteor Perseid",
      tanggal: "2026-08-12",
      deskripsiSingkat: "Hujan meteor Perseid, puncaknya 12-13 Agustus.",
      deskripsiLengkap: "Perseid adalah hujan meteor paling populer...",
      poinPelajaran: [
        " Meteor Perseid berasal dari rasi Perseus.",
        " Komet induknya adalah Swift-Tuttle.",
        " Waktu terbaik mengamati mulai tengah malam hingga subuh.",
      ],
      sumber: "In-The-Sky.org, NASA",
      waktuTerbaikUtc: "21:00",
    ),
    FenomenaModel(
      id: 5,
      nama: "Hujan Meteor Geminid",
      tanggal: "2026-12-13",
      deskripsiSingkat: "Hujan meteor Geminid, puncaknya 13-14 Desember.",
      deskripsiLengkap: "Geminid sering disebut sebagai hujan meteor terbaik...",
      poinPelajaran: [
        " Sumber Geminid adalah asteroid 3200 Phaethon.",
        " Meteor ini bisa terlihat dari Indonesia mulai malam hingga dini hari.",
        " Puncak aktivitas hingga 150 meteor per jam di lokasi tanpa polusi cahaya.",
      ],
      sumber: "NASA, Starwalk",
      waktuTerbaikUtc: "22:00",
    ),
    FenomenaModel(
      id: 6,
      nama: "Supermoon Pertama",
      tanggal: "2026-08-01",
      deskripsiSingkat: "Supermoon: Bulan tampak lebih besar dan terang.",
      deskripsiLengkap: "Supermoon terjadi saat bulan purnama bertepatan dengan perigee...",
      poinPelajaran: [
        " Bulan purnama di perigee (jarak terdekat).",
        " Tampak lebih besar dan terang dari biasanya.",
        " Dapat diamati dengan mata telanjang sepanjang malam.",
      ],
      sumber: "NASA, BMKG",
      waktuTerbaikUtc: "12:00", // Tengah malam? Sesuaikan
    ),
  ];

  List<FenomenaModel> get semuaFenomena => _fenomenaList;

  FenomenaModel? getFenomenaById(int id) {
    try {
      return _fenomenaList.firstWhere((f) => f.id == id);
    } catch (e) {
      return null;
    }
  }

  // Mencari fenomena yang paling dekat dengan tanggal tertentu.
  // Jika tidak ada yang persis, pilih yang terdekat di masa depan.
  FenomenaModel? getFenomenaTerdekat(DateTime tanggal, {bool hanyaTanggalSama = true}) {
    if (hanyaTanggalSama) {
      // Cari yang tanggalnya persis sama
      final tanggalString = tanggal.toIso8601String().split('T')[0];
      final fenomenaHariIni = _fenomenaList.firstWhere(
        (f) => f.tanggal == tanggalString,
        orElse: () => _fenomenaList.firstWhere(
          (f) => DateTime.parse(f.tanggal).isAfter(tanggal),
          orElse: () => _fenomenaList.last,
        ),
      );
      return fenomenaHariIni;
    } else {
      // Cari yang paling mendekati (bisa sebelum atau sesudah)
      FenomenaModel? terdekat;
      Duration? selisihTerkecil;
      for (var fenomena in _fenomenaList) {
        final diff = (DateTime.parse(fenomena.tanggal).difference(tanggal)).abs();
        if (selisihTerkecil == null || diff < selisihTerkecil) {
          selisihTerkecil = diff;
          terdekat = fenomena;
        }
      }
      return terdekat;
    }
  }

  // Spesifik: ambil fenomena yang sedang terjadi hari ini, atau yang terdekat.
  FenomenaModel? getFenomenaHariIni() {
    final sekarang = DateTime.now();
    final tanggalString = sekarang.toIso8601String().split('T')[0];

    // Jika ada fenomena tepat hari ini, tampilkan.
    final fenomenaSekarang = _fenomenaList.firstWhere(
      (f) => f.tanggal == tanggalString,
      orElse: () => _fenomenaList.firstWhere(
        (f) => DateTime.parse(f.tanggal).isAfter(sekarang),
        orElse: () => _fenomenaList.last,
      ),
    );
    return fenomenaSekarang;
  }
}