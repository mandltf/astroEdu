import '../../models/fenomena_model.dart';

class FenomenaService {
  static final FenomenaService _instance = FenomenaService._internal();
  FenomenaService._internal();
  static FenomenaService get instance => _instance;

  // Data statis 10 fenomena utama 2026 dari sumber terpercaya
  final List<FenomenaModel> _fenomenaList = [
    FenomenaModel(
      id: 1,
      nama: "Gerhana Bulan Total / Blood Moon",
      tanggal: "2026-03-03",
      deskripsiSingkat: "Bulan tampak merah total saat masuk umbra Bumi.",
      deskripsiLengkap: "Gerhana Bulan Total terjadi saat Bulan, Bumi, dan Matahari sejajar. Bulan akan tampak berwarna merah keemasan (Blood Moon) karena cahaya matahari dibiaskan oleh atmosfer Bumi. Fenomena ini dapat diamati dari seluruh Indonesia dengan mata telanjang jika cuaca cerah.",
      poinPelajaran: [
        " Gerhana Bulan terjadi saat Bumi berada di antara Matahari dan Bulan.",
        " Warna merah terjadi karena hamburan Rayleigh di atmosfer Bumi.",
        " Gerhana bulan aman dilihat tanpa pelindung mata.",
      ],
      sumber: "BMKG, NASA",
    ),
    FenomenaModel(
      id: 2,
      nama: "Hujan Meteor Lyrid",
      tanggal: "2026-04-22",
      deskripsiSingkat: "Hujan meteor Lyrid, puncaknya 22-23 April.",
      deskripsiLengkap: "Lyrid adalah salah satu hujan meteor tertua yang diketahui. Meteor ini berasal dari debu komet C/1861 G1 Thatcher. Meskipun intensitasnya tidak terlalu tinggi, Lyrid sering menghasilkan meteor yang sangat terang dengan jejak cahaya panjang.",
      poinPelajaran: [
        " Meteor adalah debu/komet yang terbakar saat masuk atmosfer Bumi.",
        " Lyrid terjadi setiap tahun pada bulan April.",
        " Puncak terbaik diamati dari lokasi gelap setelah tengah malam.",
      ],
      sumber: "In-The-Sky.org, NASA",
    ),
    FenomenaModel(
      id: 3,
      nama: "Hujan Meteor Eta Aquarid",
      tanggal: "2026-05-05",
      deskripsiSingkat: "Hujan meteor Eta Aquarid, puncaknya 5-6 Mei.",
      deskripsiLengkap: "Hujan meteor Eta Aquarid berasal dari debu Komet Halley yang terkenal. Fenomena ini sangat cocok diamati dari Indonesia karena posisinya yang rendah di ekuator. Meteor Eta Aquarid bergerak sangat cepat, mencapai kecepatan 66 km/s.",
      poinPelajaran: [
        " Meteor ini berasal dari Komet Halley.",
        " Kecepatan meteor bisa mencapai 66 km/s.",
        " Waktu terbaik mengamati adalah sebelum fajar (pukul 03.00 - 05.00).",
      ],
      sumber: "In-The-Sky.org, NASA",
    ),
    FenomenaModel(
      id: 4,
      nama: "Hujan Meteor Perseid",
      tanggal: "2026-08-12",
      deskripsiSingkat: "Hujan meteor Perseid, puncaknya 12-13 Agustus.",
      deskripsiLengkap: "Perseid adalah hujan meteor paling populer, berasal dari debu komet Swift-Tuttle. Pada puncaknya, bisa terlihat hingga puluhan meteor per jam dari lokasi yang gelap. Meskipun puncaknya lebih baik di belahan bumi utara, Indonesia tetap bisa menyaksikan sebagian meteor ini.",
      poinPelajaran: [
        " Meteor Perseid berasal dari rasi Perseus.",
        " Komet induknya adalah Swift-Tuttle.",
        " Waktu terbaik mengamati mulai tengah malam hingga subuh.",
      ],
      sumber: "In-The-Sky.org, NASA",
    ),
    FenomenaModel(
      id: 5,
      nama: "Hujan Meteor Geminid",
      tanggal: "2026-12-13",
      deskripsiSingkat: "Hujan meteor Geminid, puncaknya 13-14 Desember.",
      deskripsiLengkap: "Geminid sering disebut sebagai hujan meteor terbaik karena konsisten dan intens. Meteor ini bergerak lebih lambat dan terkadang menghasilkan semburat warna-warni. Tidak seperti kebanyakan hujan meteor, Geminid berasal dari asteroid, bukan komet.",
      poinPelajaran: [
        " Sumber Geminid adalah asteroid 3200 Phaethon.",
        " Meteor ini bisa terlihat dari Indonesia mulai malam hingga dini hari.",
        " Puncak aktivitas hingga 150 meteor per jam di lokasi tanpa polusi cahaya.",
      ],
      sumber: "NASA, Starwalk",
    ),
    FenomenaModel(
      id: 6,
      nama: "Supermoon Pertama",
      tanggal: "2026-08-01",
      deskripsiSingkat: "Supermoon: Bulan tampak lebih besar dan terang.",
      deskripsiLengkap: "Supermoon terjadi saat bulan purnama bertepatan dengan posisi bulan di titik terdekatnya dengan Bumi (perigee). Bulan akan tampak sekitar 14% lebih besar dan 30% lebih terang dari biasanya.",
      poinPelajaran: [
        " Bulan purnama di perigee (jarak terdekat).",
        " Tampak lebih besar dan terang dari biasanya.",
        " Dapat diamati dengan mata telanjang sepanjang malam.",
      ],
      sumber: "NASA, BMKG (Almanak 2026)",
    ),
    FenomenaModel(
      id: 7,
      nama: "Konjungsi Mars dan Jupiter",
      tanggal: "2026-11-16",
      deskripsiSingkat: "Mars dan Jupiter tampak sangat berdekatan di langit.",
      deskripsiLengkap: "Dua planet terlihat sangat berdekatan (kurang dari 1 derajat) di langit timur sebelum fajar. Pemandangan ini sangat kontras: rona kemerahan Mars bersanding dengan cahaya putih Jupiter yang cemerlang. Bisa dilihat dengan mata telanjang di seluruh Indonesia.",
      poinPelajaran: [
        " Konjungsi berarti kedua planet terlihat berdekatan dari sudut pandang Bumi.",
        " Fenomena ini dapat diamati dengan mata telanjang.",
        " Waktu terbaik: sebelum fajar (sekitar pukul 04.00 dini hari).",
      ],
      sumber: "NASA Solar System Exploration",
    ),
    FenomenaModel(
      id: 8,
      nama: "Okultasi Saturnus oleh Bulan",
      tanggal: "2026-02-01",
      deskripsiSingkat: "Bulan menutupi planet Saturnus.",
      deskripsiLengkap: "Fenomena langka di mana Bulan melintas tepat di depan Saturnus, membuat Saturnus seolah 'menghilang' di balik Bulan. Peristiwa ini hanya dapat dilihat dengan teleskop kecil atau teropong berperbesaran tinggi.",
      poinPelajaran: [
        " Okultasi adalah tertutupnya suatu benda langit oleh benda lain yang lebih dekat.",
        " Wilayah Indonesia berada di jalur ideal pengamatan.",
        " Disarankan menggunakan teleskop kecil atau teropong.",
      ],
      sumber: "International Astronomical Union (IAU)",
    ),
    FenomenaModel(
      id: 9,
      nama: "Oposisi Saturnus",
      tanggal: "2026-09-21",
      deskripsiSingkat: "Saturnus di titik terdekatnya dengan Bumi.",
      deskripsiLengkap: "Pada posisi oposisi, Saturnus berada di titik terdekatnya dengan Bumi dan seluruh permukaannya diterangi Matahari. Ini adalah waktu terbaik untuk mengamati cincin Saturnus dengan teleskop.",
      poinPelajaran: [
        " Oposisi berarti planet berseberangan dengan Matahari dari Bumi.",
        " Saturnus akan terlihat sangat terang sepanjang malam.",
        " Waktu terbaik untuk fotografi planet dengan teleskop.",
      ],
      sumber: "NASA, BBC Weather",
    ),
    FenomenaModel(
      id: 10,
      nama: "Hujan Meteor Alpha Capricornid",
      tanggal: "2026-07-30",
      deskripsiSingkat: "Alpha Capricornid, dikenal dengan bolide terang.",
      deskripsiLengkap: "Meskipun intensitasnya rendah, hujan meteor Alpha Capricornid terkenal dengan bolidenya (meteor sangat terang) yang sering meledak di atmosfer.",
      poinPelajaran: [
        " Dikenal menghasilkan bolide (meteor sangat terang).",
        " Puncaknya 30 Juli.",
        " Cocok diamati dari belahan bumi selatan termasuk Indonesia.",
      ],
      sumber: "International Meteor Organization (IMO)",
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