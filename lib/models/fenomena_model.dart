class FenomenaModel {
  final int id;
  final String nama;
  final String tanggal;
  final String deskripsiSingkat;
  final String deskripsiLengkap;
  final List<String> poinPelajaran; // untuk bagian "📖 Pelajari"
  final String sumber; // sumber data terpercaya

  FenomenaModel({
    required this.id,
    required this.nama,
    required this.tanggal,
    required this.deskripsiSingkat,
    required this.deskripsiLengkap,
    required this.poinPelajaran,
    required this.sumber,
  });
}