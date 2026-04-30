// lib/models/user_model.dart
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? photoPath;
  final DateTime createdAt;
  String? saran;
  String? kesan;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoPath,
    required this.createdAt,
    this.saran,
    this.kesan,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'],
    name: map['name'],
    email: map['email'],
    photoPath: map['photo_path'],
    createdAt: DateTime.parse(map['created_at']),
    saran: map['saran'],
    kesan: map['kesan'],
  );
}