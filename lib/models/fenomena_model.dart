class FenomenaModel {
  final int? id;
  final String nama;
  final String tanggal;
  final String deskripsiSingkat;
  final String deskripsiLengkap;
  final List<String> poinPelajaran;
  final String sumber;
  final String waktuTerbaikUtc;
  final String negara;

  FenomenaModel({
    this.id,
    required this.nama,
    required this.tanggal,
    required this.deskripsiSingkat,
    required this.deskripsiLengkap,
    required this.poinPelajaran,
    required this.sumber,
    required this.waktuTerbaikUtc,
    this.negara = 'Indonesia',
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nama': nama,
      'tanggal': tanggal,
      'deskripsi_singkat': deskripsiSingkat,
      'deskripsi_lengkap': deskripsiLengkap,
      'poin_pelajaran': poinPelajaran.join('|'),
      'sumber': sumber,
      'waktu_terbaik_utc': waktuTerbaikUtc,
      'negara': negara,
    };
  }

  // Create from Map (from database)
  factory FenomenaModel.fromMap(Map<String, dynamic> map) {
    return FenomenaModel(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      tanggal: map['tanggal'] as String,
      deskripsiSingkat: map['deskripsi_singkat'] as String,
      deskripsiLengkap: map['deskripsi_lengkap'] as String,
      poinPelajaran: (map['poin_pelajaran'] as String).split('|'),
      sumber: map['sumber'] as String,
      waktuTerbaikUtc: map['waktu_terbaik_utc'] as String,
      negara: map['negara'] as String? ?? 'Indonesia',
    );
  }
}