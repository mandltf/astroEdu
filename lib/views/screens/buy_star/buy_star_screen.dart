// lib/views/screens/buy_star/buy_star_screen.dart
import 'package:flutter/material.dart';
import '../../../services/local/auth_service.dart';
import '../../../services/local/database_helper.dart';
import '../../../services/api/currency_service.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import '../../widgets/common_widgets.dart';

class BuyStarScreen extends StatefulWidget {
  const BuyStarScreen({super.key});

  @override
  State<BuyStarScreen> createState() => _BuyStarScreenState();
}

class _BuyStarScreenState extends State<BuyStarScreen> {
  // Daftar bintang yang tersedia untuk dibeli
  final List<Map<String, dynamic>> _starsForSale = [
    {'name': 'Alpha Centauri', 'distance': '4.37 tahun cahaya', 'price_usd': 49.99, 'constellation': 'Centaurus', 'type': 'Bintang Ganda'},
    {'name': 'Sirius', 'distance': '8.6 tahun cahaya', 'price_usd': 99.99, 'constellation': 'Canis Major', 'type': 'Bintang Deret Utama'},
    {'name': 'Betelgeuse', 'distance': '700 tahun cahaya', 'price_usd': 149.99, 'constellation': 'Orion', 'type': 'Bintang Maharaksasa Merah'},
    {'name': 'Rigel', 'distance': '860 tahun cahaya', 'price_usd': 129.99, 'constellation': 'Orion', 'type': 'Bintang Maharaksasa Biru'},
    {'name': 'Antares', 'distance': '550 tahun cahaya', 'price_usd': 119.99, 'constellation': 'Scorpius', 'type': 'Bintang Maharaksasa Merah'},
    {'name': 'Vega', 'distance': '25 tahun cahaya', 'price_usd': 79.99, 'constellation': 'Lyra', 'type': 'Bintang Deret Utama'},
    {'name': 'Arcturus', 'distance': '36 tahun cahaya', 'price_usd': 89.99, 'constellation': 'Boötes', 'type': 'Bintang Raksasa'},
    {'name': 'Spica', 'distance': '250 tahun cahaya', 'price_usd': 109.99, 'constellation': 'Virgo', 'type': 'Bintang Ganda'},
    {'name': 'Deneb', 'distance': '1400 tahun cahaya', 'price_usd': 139.99, 'constellation': 'Cygnus', 'type': 'Bintang Maharaksasa'},
    {'name': 'Pollux', 'distance': '34 tahun cahaya', 'price_usd': 69.99, 'constellation': 'Gemini', 'type': 'Bintang Raksasa'},
  ];

  String _selectedCurrency = 'IDR';
  Map<String, double> _rates = {};
  bool _loadingRates = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _userId = await AuthService.instance.getCurrentUserId();
    final rates = await CurrencyService.instance.getRates();
    setState(() {
      _rates = rates;
      _loadingRates = false;
    });
  }

  String _formatPrice(double usdPrice) {
    if (_selectedCurrency == 'USD') {
      return '\$${usdPrice.toStringAsFixed(2)}';
    } else {
      final idrRate = _rates['IDR'] ?? 15800;
      final idrPrice = usdPrice * idrRate;
      return 'Rp ${idrPrice.toStringAsFixed(0)}';
    }
  }

  Future<void> _buyStar(Map<String, dynamic> star) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    final customNameController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text('Beri Nama Bintang', style: TextStyle(color: AppTheme.starlight)),
        content: TextField(
          controller: customNameController,
          decoration: const InputDecoration(
            hintText: 'Nama untuk bintang ini',
            hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
          ),
          style: const TextStyle(color: AppTheme.starlight),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: AppTheme.marsRed)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Beli Sekarang'),
          ),
        ],
      ),
    );

    if (confirmed == true && customNameController.text.isNotEmpty) {
      final idrRate = _rates['IDR'] ?? 15800;
      final priceIdr = star['price_usd'] * idrRate;
      await DatabaseHelper.instance.insertStar({
        'user_id': _userId,
        'star_name': star['name'],
        'custom_name': customNameController.text,
        'price_usd': star['price_usd'],
        'price_idr': priceIdr,
        'bought_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✨ Selamat! Bintang ${star['name']} sekarang bernama ${customNameController.text}'),
            backgroundColor: AppTheme.nebulaGreen,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AstroAppBar(
        title: '⭐ Beli Bintang',
        actions: [
          DropdownButton<String>(
            value: _selectedCurrency,
            dropdownColor: AppTheme.cardBg,
            underline: const SizedBox(),
            icon: const Icon(Icons.attach_money, color: AppTheme.starlight),
            items: const [
              DropdownMenuItem(value: 'IDR', child: Text('IDR', style: TextStyle(color: AppTheme.starlight))),
              DropdownMenuItem(value: 'USD', child: Text('USD', style: TextStyle(color: AppTheme.starlight))),
            ],
            onChanged: (value) {
              if (value != null) setState(() => _selectedCurrency = value);
            },
          ),
        ],
      ),
      body: StarBackground(
        child: _loadingRates
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _starsForSale.length,
                itemBuilder: (_, i) {
                  final star = _starsForSale[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 28)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    star['name'],
                                    style: const TextStyle(color: AppTheme.starlight, fontSize: 18, fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    '${star['constellation']} • ${star['type']}',
                                    style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _formatPrice(star['price_usd']),
                                  style: const TextStyle(color: AppTheme.solarGold, fontSize: 16, fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  'Jarak: ${star['distance']}',
                                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => _buyStar(star),
                          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
                          child: const Text('Beli Bintang Ini'),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}