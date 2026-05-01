import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/local/auth_service.dart';
import '../../../services/local/database_helper.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import '../../widgets/common_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Map<String, dynamic>? _user;
  bool _loading = true;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userId = await AuthService.instance.getCurrentUserId();
    if (userId != null) {
      final user = await DatabaseHelper.instance.getUserById(userId);
      setState(() {
        _user = user;
        _nameController.text = user?['name'] ?? '';
        _emailController.text = user?['email'] ?? '';
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _editPhoto() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && _user != null) {
      final userId = _user!['id'];
      await DatabaseHelper.instance.updateUser(userId, {'photo_path': pickedFile.path});
      await _loadUser();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil diperbarui'), backgroundColor: AppTheme.nebulaGreen),
        );
      }
    }
  }

  Future<void> _saveChanges() async {
    final userId = _user?['id'];
    if (userId == null) return;

    setState(() => _isSaving = true);
    final newName = _nameController.text.trim();
    final newEmail = _emailController.text.trim();

    if (newName != _user!['name']) {
      await DatabaseHelper.instance.updateUser(userId, {'name': newName});
    }
    if (newEmail != _user!['email']) {
      // Cek email duplikat
      final existing = await DatabaseHelper.instance.getUserByEmail(newEmail);
      if (existing != null && existing['id'] != userId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email sudah terdaftar'), backgroundColor: AppTheme.marsRed),
        );
        setState(() => _isSaving = false);
        return;
      }
      await DatabaseHelper.instance.updateUser(userId, {'email': newEmail});
    }

    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: AppTheme.nebulaGreen),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(body: StarBackground(child: const Center(child: CircularProgressIndicator())));
    }
    if (_user == null) {
      return Scaffold(body: StarBackground(child: const Center(child: Text('User tidak ditemukan', style: TextStyle(color: AppTheme.starlight)))));
    }

    return Scaffold(
      appBar: AstroAppBar(title: 'Edit Profil'),
      body: StarBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar
              GestureDetector(
                onTap: _editPhoto,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [AppTheme.auroraBlue, AppTheme.cosmicPurple]),
                  ),
                  child: ClipOval(
                    child: _user!['photo_path'] != null && File(_user!['photo_path']).existsSync()
                        ? Image.file(File(_user!['photo_path']), fit: BoxFit.cover, width: 100, height: 100)
                        : const Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _editPhoto,
                icon: const Icon(Icons.camera_alt, size: 16),
                label: const Text('Ganti Foto'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.auroraBlue),
              ),
              const SizedBox(height: 24),
              // Form
              TextField(
                controller: _nameController,
                style: const TextStyle(color: AppTheme.starlight),
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.auroraBlue),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: AppTheme.starlight),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.auroraBlue),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveChanges,
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Simpan Perubahan'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}