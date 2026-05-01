class FenomenaModel {
  final int id;
  final String nama;
  final String tanggal;
  final String deskripsiSingkat;
  final String deskripsiLengkap;
  final List<String> poinPelajaran;
  final String sumber;
  final String waktuTerbaikUtc; // Tambahan: waktu terbaik dalam UTC (misal "21:00")

  FenomenaModel({
    required this.id,
    required this.nama,
    required this.tanggal,
    required this.deskripsiSingkat,
    required this.deskripsiLengkap,
    required this.poinPelajaran,
    required this.sumber,
    required this.waktuTerbaikUtc, // Wajib diisi
  });
}