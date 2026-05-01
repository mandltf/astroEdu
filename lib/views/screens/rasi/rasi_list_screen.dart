// lib/views/screens/rasi/rasi_list_screen.dart
import 'package:flutter/material.dart';
import '../../../services/local/database_helper.dart';
import '../../../services/local/auth_service.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../models/rasi_model.dart';
import '../../../controllers/data_controller.dart';
import '../../widgets/star_background.dart';
import '../../widgets/common_widgets.dart';
import '../quiz/quiz_screen.dart';
import 'rasi_detail_screen.dart';

class RasiListScreen extends StatefulWidget {
  const RasiListScreen({super.key});

  @override
  State<RasiListScreen> createState() => _RasiListScreenState();
}

class _RasiListScreenState extends State<RasiListScreen> {
  late List<RasiModel> _items;
  int? _userId;
  Map<String, bool> _readMap = {};
  Map<String, bool> _unlockMap = {};
  String _search = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    _items = AppConstants.rasiList.map((data) => RasiModel(
      id: data['id'], name: data['name'], emoji: data['emoji'], color: data['color'],
      shortDesc: 'Rasi bintang ${data['name']}', description: 'Memuat dari Wikipedia...',
      bestTime: 'Belum diketahui', visibility: 'Belum diketahui', brightestStar: 'Belum diketahui',
      stars: 0, facts: [], season: 'Belum diketahui', wikiData: null,
    )).toList();
    final uid = await AuthService.instance.getCurrentUserId();
    setState(() => _userId = uid);
    await _refreshProgress();
    setState(() => _loading = false);
  }

  Future<void> _refreshProgress() async {
    if (_userId == null) return;
    final readMap = <String, bool>{};
    final unlockMap = <String, bool>{};
    for (int i = 0; i < _items.length; i++) {
      final id = 'item_$i';
      readMap[id] = await DatabaseHelper.instance.isItemRead(_userId!, 'rasi', id);
      unlockMap[id] = i == 0 ? true : await DatabaseHelper.instance.isItemUnlocked(_userId!, 'rasi', id);
    }
    if (mounted) setState(() {
      _readMap = readMap;
      _unlockMap = unlockMap;
    });
  }

  Future<void> _openItem(int index) async {
    final id = 'item_$index';
    if (!(_unlockMap[id] ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('🔒 Selesaikan ${_items[index - 1].name} terlebih dahulu!'), backgroundColor: AppTheme.marsRed),
      );
      return;
    }
    final item = _items[index];
    if (item.wikiData == null) {
      final wiki = await DataController.instance.getWikiData(item.name);
      if (wiki != null) item.wikiData = wiki;
    }
    await Navigator.push(context, MaterialPageRoute(builder: (_) => RasiDetailScreen(item: item, itemId: id, userId: _userId!)));
    await DatabaseHelper.instance.markAsRead(_userId!, 'rasi', id);
    if (index + 1 < _items.length) {
      await DatabaseHelper.instance.unlockItem(_userId!, 'rasi', 'item_${index + 1}');
    }
    await _refreshProgress();
  }

  Future<void> _openQuiz() async {
    final allRead = await DatabaseHelper.instance.allItemsRead(_userId!, 'rasi', _items.length);
    if (!allRead) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Baca semua rasi bintang dulu!'), backgroundColor: AppTheme.marsRed));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => QuizScreen(
      category: 'rasi',
      items: _items.map((r) => {'name': r.name, 'description': r.wikiData?['extract'] ?? r.description}).toList(),
      userId: _userId!,
    )));
  }

  bool get _allRead => _items.asMap().entries.every((e) => _readMap['item_${e.key}'] ?? false);

  Widget _buildQuizCard() {
    final unlocked = _allRead;
    return GestureDetector(
      onTap: () => unlocked ? _openQuiz() : ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔒 Selesaikan semua materi rasi bintang untuk membuka kuis!'), backgroundColor: AppTheme.marsRed)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unlocked ? AppTheme.cardBg : AppTheme.deepSpace,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: unlocked ? AppTheme.solarGold : AppTheme.cardBorder.withOpacity(0.3), width: unlocked ? 1.5 : 1),
          gradient: unlocked ? LinearGradient(colors: [AppTheme.solarGold.withOpacity(0.1), Colors.transparent]) : null,
        ),
        child: Row(
          children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(color: unlocked ? AppTheme.solarGold.withOpacity(0.2) : Colors.grey.withOpacity(0.2), shape: BoxShape.circle),
              child: Center(child: unlocked ? const Icon(Icons.quiz, color: AppTheme.solarGold, size: 28) : const Icon(Icons.lock, color: Color(0xFF6B7280), size: 24))),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Text(' Kuis Rasi Bintang', style: TextStyle(color: unlocked ? AppTheme.starlight : const Color(0xFF6B7280), fontSize: 16, fontWeight: FontWeight.w700)),
                if (unlocked) const Icon(Icons.auto_awesome, color: AppTheme.solarGold, size: 16)]),
              Text(unlocked ? 'Uji pengetahuanmu tentang rasi bintang di langit malam' : 'Selesaikan semua materi rasi bintang untuk membuka kuis',
                  style: TextStyle(color: unlocked ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563), fontSize: 12)),
            ])),
            Icon(unlocked ? Icons.arrow_forward_ios : Icons.lock, color: unlocked ? AppTheme.solarGold : const Color(0xFF4B5563), size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _search.isEmpty ? _items : _items.where((r) => r.name.toLowerCase().contains(_search.toLowerCase())).toList();
    final itemCount = filtered.isEmpty ? 0 : filtered.length + 1;

    return Scaffold(
      appBar: AstroAppBar(title: '⭐ Rasi Bintang'),
      body: StarBackground(
        child: _loading ? const Center(child: CircularProgressIndicator()) : Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: AppTheme.starlight),
                decoration: InputDecoration(
                  hintText: 'Cari rasi bintang...',
                  prefixIcon: const Icon(Icons.search, color: AppTheme.auroraBlue),
                  suffixIcon: _search.isNotEmpty ? IconButton(icon: const Icon(Icons.clear, color: AppTheme.auroraBlue), onPressed: () => setState(() => _search = '')) : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress: ${_readMap.values.where((v) => v).length}/${_items.length}', style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
                      if (_allRead) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: AppTheme.solarGold.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: const Text('Kuis Tersedia! 🎯', style: TextStyle(color: AppTheme.solarGold, fontSize: 11, fontWeight: FontWeight.w600))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: _items.isEmpty ? 0 : _readMap.values.where((v) => v).length / _items.length,
                    backgroundColor: AppTheme.cardBorder,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.auroraBlue),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (index < filtered.length) {
                    final item = filtered[index];
                    final originalIndex = _items.indexOf(item);
                    final id = 'item_$originalIndex';
                    final isRead = _readMap[id] ?? false;
                    final isUnlocked = _unlockMap[id] ?? (originalIndex == 0);
                    final preview = item.wikiData?['extract'] ?? item.description;
                    final display = preview.length > 60 ? '${preview.substring(0, 60)}...' : preview;
                    return GestureDetector(
                      onTap: () => _openItem(originalIndex),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isUnlocked ? AppTheme.cardBg : AppTheme.deepSpace,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isRead ? AppTheme.nebulaGreen.withOpacity(0.5) : isUnlocked ? AppTheme.cardBorder : AppTheme.cardBorder.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(width: 52, height: 52, decoration: BoxDecoration(color: Color(item.color).withOpacity(0.15), shape: BoxShape.circle),
                              child: isUnlocked ? Center(child: Text(item.emoji, style: const TextStyle(fontSize: 26))) : const Icon(Icons.lock, color: Color(0xFF6B7280), size: 24)),
                            const SizedBox(width: 14),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [Text(item.name, style: TextStyle(color: isUnlocked ? AppTheme.starlight : const Color(0xFF6B7280), fontSize: 16, fontWeight: FontWeight.w700)),
                                if (isRead) ...[const SizedBox(width: 6), const Icon(Icons.check_circle, color: AppTheme.nebulaGreen, size: 16)]],
                              ),
                              Text(display, style: TextStyle(color: isUnlocked ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563), fontSize: 12)),
                            ])),
                            Icon(isUnlocked ? Icons.arrow_forward_ios : Icons.lock, color: isUnlocked ? AppTheme.auroraBlue : const Color(0xFF4B5563), size: 16),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return _buildQuizCard();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}