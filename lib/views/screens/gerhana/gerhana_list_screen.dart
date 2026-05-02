import 'package:flutter/material.dart';
import '../../../services/local/database_helper.dart';
import '../../../services/local/auth_service.dart';
import '../../../utils/app_theme.dart';
import '../../../utils/constants.dart';
import '../../../models/gerhana_model.dart';
// import '../../../controllers/data_controller.dart';
import '../../widgets/star_background.dart';
import '../../widgets/common_widgets.dart';
import '../quiz/quiz_screen.dart';
import 'gerhana_detail_screen.dart';

class GerhanaListScreen extends StatefulWidget {
  const GerhanaListScreen({super.key});

  @override
  State<GerhanaListScreen> createState() => _GerhanaListScreenState();
}

class _GerhanaListScreenState extends State<GerhanaListScreen> {
  List<GerhanaModel> _items = [];
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
    setState(() => _loading = true);

    // FILTRASI: Hanya mengambil 'Gerhana Matahari' dan 'Gerhana Bulan' dari constants
    final filteredRawList = AppConstants.gerhanaList.where((data) {
      final name = data['name'].toString().toLowerCase();
      return name == 'gerhana matahari' || name == 'gerhana bulan';
    }).toList();

    _items = filteredRawList.map((data) {
      return GerhanaModel(
        id: data['id'],
        name: data['name'],
        emoji: data['emoji'],
        color: data['color'],
        shortDesc: data['shortDesc'] ?? 'Fenomena ${data['name']}',
        description: data['description'] ?? 'Memuat deskripsi...',
        duration: data['duration'] ?? '-',
        frequency: data['frequency'] ?? '-',
        safety: data['safety'] ?? '-',
        facts: [],
        wikiData: null,
      );
    }).toList();

    final uid = await AuthService.instance.getCurrentUserId();
    _userId = uid;
    
    await _refreshProgress();
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _refreshProgress() async {
    if (_userId == null) return;
    final readMap = <String, bool>{};
    final unlockMap = <String, bool>{};

    for (int i = 0; i < _items.length; i++) {
      final id = 'item_$i';
      // Cek status baca dan kunci dari database
      readMap[id] = await DatabaseHelper.instance.isItemRead(_userId!, 'gerhana', id);
      unlockMap[id] = i == 0 ? true : await DatabaseHelper.instance.isItemUnlocked(_userId!, 'gerhana', id);
    }

    if (mounted) {
      setState(() {
        _readMap = readMap;
        _unlockMap = unlockMap;
      });
    }
  }

  Future<void> _openItem(int index) async {
    final id = 'item_$index';
    
    if (!(_unlockMap[id] ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🔒 Selesaikan ${_items[index - 1].name} terlebih dahulu!'),
          backgroundColor: AppTheme.marsRed,
        ),
      );
      return;
    }

    final item = _items[index];
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GerhanaDetailScreen(item: item, itemId: id, userId: _userId!),
      ),
    );

    // Setelah kembali dari detail, tandai sudah dibaca dan buka item selanjutnya
    await DatabaseHelper.instance.markAsRead(_userId!, 'gerhana', id);
    if (index + 1 < _items.length) {
      await DatabaseHelper.instance.unlockItem(_userId!, 'gerhana', 'item_${index + 1}');
    }
    
    await _refreshProgress();
  }

  Future<void> _openQuiz() async {
    final allRead = _items.isNotEmpty && 
                    _readMap.values.where((v) => v).length == _items.length;

    if (!allRead) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Baca semua materi gerhana dulu!'), 
          backgroundColor: AppTheme.marsRed
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          category: 'gerhana',
          items: _items.map((g) => {
            'name': g.name, 
            'description': g.description
          }).toList(),
          userId: _userId!,
        ),
      ),
    );
  }

  bool get _allRead => _items.isNotEmpty && 
                       _readMap.values.where((v) => v).length == _items.length;

  @override
  Widget build(BuildContext context) {
    final filtered = _search.isEmpty 
        ? _items 
        : _items.where((g) => g.name.toLowerCase().contains(_search.toLowerCase())).toList();
    
    final itemCount = filtered.isEmpty ? 0 : filtered.length + 1;

    return Scaffold(
      appBar: AstroAppBar(title: ' Gerhana'),
      body: StarBackground(
        child: _loading 
            ? const Center(child: CircularProgressIndicator(color: AppTheme.auroraBlue)) 
            : Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: TextField(
                      onChanged: (v) => setState(() => _search = v),
                      style: const TextStyle(color: AppTheme.starlight),
                      decoration: InputDecoration(
                        hintText: 'Cari gerhana...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.auroraBlue),
                        suffixIcon: _search.isNotEmpty 
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: AppTheme.auroraBlue), 
                                onPressed: () => setState(() => _search = '')) 
                            : null,
                      ),
                    ),
                  ),

                  // Progress Indicator
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress: ${_readMap.values.where((v) => v).length}/${_items.length}', 
                              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)
                            ),
                            if (_allRead) 
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), 
                                decoration: BoxDecoration(
                                  color: AppTheme.solarGold.withOpacity(0.2), 
                                  borderRadius: BorderRadius.circular(20)
                                ),
                                child: const Text('Kuis Tersedia! 🎯', 
                                  style: TextStyle(color: AppTheme.solarGold, fontSize: 11, fontWeight: FontWeight.w600))
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _items.isEmpty ? 0 : _readMap.values.where((v) => v).length / _items.length,
                          backgroundColor: AppTheme.cardBorder.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.auroraBlue),
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: itemCount,
                      itemBuilder: (context, idx) {
                        if (idx < filtered.length) {
                          final item = filtered[idx];
                          final originalIndex = _items.indexOf(item);
                          final id = 'item_$originalIndex';
                          
                          final isRead = _readMap[id] ?? false;
                          final isUnlocked = _unlockMap[id] ?? (originalIndex == 0);
                          
                          final preview = item.shortDesc;
                          final display = preview.length > 60 
                              ? '${preview.substring(0, 60)}...' 
                              : preview;

                          return _buildGerhanaCard(item, isUnlocked, isRead, display, originalIndex);
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

  Widget _buildGerhanaCard(GerhanaModel item, bool isUnlocked, bool isRead, String display, int index) {
    return GestureDetector(
      onTap: () => _openItem(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked ? AppTheme.cardBg : AppTheme.deepSpace.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead 
                ? AppTheme.nebulaGreen.withOpacity(0.5) 
                : isUnlocked ? AppTheme.cardBorder : AppTheme.cardBorder.withOpacity(0.2)
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56, 
              height: 56, 
              decoration: BoxDecoration(
                color: Color(item.color).withOpacity(0.1), 
                shape: BoxShape.circle
              ),
              child: isUnlocked 
                  ? Center(child: Text(item.emoji, style: const TextStyle(fontSize: 28))) 
                  : const Icon(Icons.lock, color: Color(0xFF6B7280), size: 24)
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Row(children: [
                    Text(item.name, style: TextStyle(
                      color: isUnlocked ? AppTheme.starlight : const Color(0xFF6B7280), 
                      fontSize: 16, 
                      fontWeight: FontWeight.w700)
                    ),
                    if (isRead) ...[
                      const SizedBox(width: 6), 
                      const Icon(Icons.check_circle, color: AppTheme.nebulaGreen, size: 16)
                    ]
                  ]),
                  const SizedBox(height: 4),
                  Text(display, style: TextStyle(
                    color: isUnlocked ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563), 
                    fontSize: 13)
                  ),
                ]
              )
            ),
            Icon(isUnlocked ? Icons.arrow_forward_ios : Icons.lock_outline, 
                color: isUnlocked ? AppTheme.auroraBlue : const Color(0xFF4B5563), 
                size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard() {
    final unlocked = _allRead;
    return GestureDetector(
      onTap: () => unlocked ? _openQuiz() : null,
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: unlocked ? AppTheme.cardBg : AppTheme.deepSpace.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked ? AppTheme.solarGold.withOpacity(0.5) : AppTheme.cardBorder.withOpacity(0.2), 
            width: unlocked ? 1.5 : 1
          ),
          gradient: unlocked ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.solarGold.withOpacity(0.1), Colors.transparent]
          ) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56, height: 56, 
              decoration: BoxDecoration(
                color: unlocked ? AppTheme.solarGold.withOpacity(0.15) : Colors.grey.withOpacity(0.1), 
                shape: BoxShape.circle
              ),
              child: Center(child: Icon(
                unlocked ? Icons.quiz_rounded : Icons.lock_clock_outlined, 
                color: unlocked ? AppTheme.solarGold : const Color(0xFF6B7280), 
                size: 28
              ))
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text('Uji Pengetahuan', 
                    style: TextStyle(
                      color: unlocked ? AppTheme.starlight : const Color(0xFF6B7280), 
                      fontSize: 16, 
                      fontWeight: FontWeight.w700
                    )
                  ),
                  const SizedBox(height: 4),
                  Text(unlocked 
                    ? 'Ayo kerjakan kuis fenomena gerhana!' 
                    : 'Selesaikan 2 materi di atas untuk membuka kuis',
                    style: TextStyle(
                      color: unlocked ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563), 
                      fontSize: 13
                    )
                  ),
                ]
              )
            ),
            if (unlocked) const Icon(Icons.arrow_forward_ios, color: AppTheme.solarGold, size: 16),
          ],
        ),
      ),
    );
  }
}