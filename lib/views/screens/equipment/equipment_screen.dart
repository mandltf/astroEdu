import 'package:flutter/material.dart';
import '../../../services/api/currency_service.dart';
import '../../../utils/app_theme.dart';
import '../../widgets/star_background.dart';
import '../../widgets/common_widgets.dart';

class EquipmentScreen extends StatefulWidget {
  const EquipmentScreen({super.key});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  final List<Map<String, dynamic>> _equipments = [
    {
      'name': 'Teropong Bintang 70mm',
      'description': 'Cocok untuk pemula, melihat bulan, planet terang, dan gugus bintang.',
      'price_usd': 89.99,
      'icon': '🔭',
      'image': 'assets/images/teropong70mm.jpg', // placeholder, nanti pakai asset lokal
    },
    {
      'name': 'Teleskop 130EQ',
      'description': 'Dilengkapi mount equatorial, mampu melihat galaksi dan nebula.',
      'price_usd': 299.99,
      'icon': '🪐',
      'image': 'assets/images/teropong130eq.jpg',
    },
    {
      'name': 'Binokular 10x50',
      'description': 'Ringan dan portabel, ideal untuk pemandangan langit luas.',
      'price_usd': 79.99,
      'icon': '👓',
      'image': 'assets/images/binokular10x50.jpg',
    },
    {
      'name': 'Filter Bulan',
      'description': 'Mengurangi silau bulan purnama agar detail kawah terlihat.',
      'price_usd': 24.99,
      'icon': '🌙',
      'image': 'assets/images/filterbulan.jpg',
    },
    {
      'name': 'Buku Panduan Astronomi',
      'description': 'Referensi lengkap untuk memahami langit malam.',
      'price_usd': 19.99,
      'icon': '📖',
      'image': 'assets/images/bukupanduanastronomi.jpg',
    },
    {
      'name': 'Laser Pointer Astronomi',
      'description': 'Memudahkan menunjuk bintang saat berbagi dengan teman.',
      'price_usd': 34.99,
      'icon': '🔦',
      'image': 'assets/images/laserpointer.jpg',
    },
  ];

  String _selectedCurrency = 'IDR';
  Map<String, double> _rates = {};
  bool _loadingRates = true;

  @override
  void initState() {
    super.initState();
    _loadRates();
  }

  Future<void> _loadRates() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AstroAppBar(
        title: ' Peralatan Astronomi',
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
            : GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: _equipments.length,
                itemBuilder: (context, index) {
                  final item = _equipments[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ikon besar atau gambar placeholder
                        Container(
                          height: 130,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            color: AppTheme.deepSpace,
                          ),
                          child: Image.asset(
                            item['image'],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 120,
                            errorBuilder: (_, __, ___) => Text(item['icon'], style: const TextStyle(fontSize: 48)),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(color: AppTheme.starlight, fontSize: 14, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['description'],
                                style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatPrice(item['price_usd']),
                                style: const TextStyle(color: AppTheme.solarGold, fontSize: 14, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
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