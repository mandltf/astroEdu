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
      'image': 'assets/images/teropong70mm.jpg',
      'specs': 'Aperture: 70mm\nFocal Length: 400mm\nMagnification: 140x\nMount: Altazimuth',
      'stores': ['Tokopedia', 'Shopee', 'Amazon'],
    },
    {
      'name': 'Teleskop 130EQ',
      'description': 'Dilengkapi mount equatorial, mampu melihat galaksi dan nebula.',
      'price_usd': 299.99,
      'icon': '🪐',
      'image': 'assets/images/teropong130eq.jpg',
      'specs': 'Aperture: 130mm\nFocal Length: 650mm\nMount: Equatorial (CG-3)\nEyepieces: 20mm & 10mm',
      'stores': ['Tokopedia', 'Blibli', 'Amazon'],
    },
    {
      'name': 'Binokular 10x50',
      'description': 'Ringan dan portabel, ideal untuk pemandangan langit luas.',
      'price_usd': 79.99,
      'icon': '👓',
      'image': 'assets/images/binokular10x50.jpg',
      'specs': 'Magnification: 10x\nObjective Lens: 50mm\nField of View: 114m/1000m\nPrism Type: Porro',
      'stores': ['Shopee', 'Lazada', 'Tokopedia'],
    },
    {
      'name': 'Filter Bulan',
      'description': 'Mengurangi silau bulan purnama agar detail kawah terlihat.',
      'price_usd': 24.99,
      'icon': '🌙',
      'image': 'assets/images/filterbulan.jpg',
      'specs': 'Size: 1.25 inch\nTransmission: 18%\nMaterial: Optical Glass',
      'stores': ['Tokopedia', 'Shopee'],
    },
    {
      'name': 'Buku Panduan Astronomi',
      'description': 'Referensi lengkap untuk memahami langit malam.',
      'price_usd': 19.99,
      'icon': '📖',
      'image': 'assets/images/bukupanduanastronomi.jpg',
      'specs': 'Pages: 256\nLanguage: Indonesia\nFormat: Hardcover\nCategory: Edukasi',
      'stores': ['Gramedia', 'Tokopedia', 'Shopee'],
    },
    {
      'name': 'Laser Pointer Astronomi',
      'description': 'Memudahkan menunjuk bintang saat berbagi dengan teman.',
      'price_usd': 34.99,
      'icon': '🔦',
      'image': 'assets/images/laserpointer.jpg',
      'specs': 'Power: 5mW\nWavelength: 532nm (Green)\nRange: Up to 5km\nBattery: 2x AAA',
      'stores': ['Tokopedia', 'Shopee', 'Lazada'],
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
    switch (_selectedCurrency) {
      case 'USD':
        return '\$${usdPrice.toStringAsFixed(2)}';

      case 'IDR':
        final rate = _rates['IDR'] ?? 15800;
        final value = usdPrice * rate;
        return 'Rp ${value.toStringAsFixed(0)}';

      case 'EUR':
        final rate = _rates['EUR'] ?? 0.92; 
        final value = usdPrice * rate;
        return '€${value.toStringAsFixed(2)}';

      default:
        return '\$${usdPrice.toStringAsFixed(2)}';
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
              DropdownMenuItem(
                  value: 'IDR',
                  child: Text('IDR', style: TextStyle(color: AppTheme.starlight))),
              DropdownMenuItem(
                  value: 'USD',
                  child: Text('USD', style: TextStyle(color: AppTheme.starlight))),
              DropdownMenuItem(
                  value: 'EUR',
                  child: Text('EUR', style: TextStyle(color: AppTheme.starlight))),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCurrency = value);
              }
            },
          ),
        ],
      ),
      body: StarBackground(
        child: _loadingRates
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.77,
                ),
                itemCount: _equipments.length,
                itemBuilder: (context, index) {
                  final item = _equipments[index];
                  return GestureDetector(
                    onTap: () => _showEquipmentDetail(item),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.cardBorder),
                      ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gambar
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: Image.asset(
                            item['image'],
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 120,
                              color: AppTheme.deepSpace,
                              child: Center(
                                child: Text(
                                  item['icon'],
                                  style: const TextStyle(fontSize: 45),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Konten
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                style: const TextStyle(
                                  color: AppTheme.starlight,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                item['description'],
                                style: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 11,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _formatPrice(item['price_usd']),
                                style: const TextStyle(
                                  color: AppTheme.solarGold,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),),
                  );
                },
              ),
      ),
    );
  }

  void _showEquipmentDetail(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.auroraBlue.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.auroraBlue.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Stack(
                    children: [
                      Image.asset(
                        item['image'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: AppTheme.deepSpace,
                          child: Center(
                            child: Text(
                              item['icon'],
                              style: const TextStyle(fontSize: 80),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.deepSpace.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item['name'],
                              style: const TextStyle(
                                color: AppTheme.starlight,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.solarGold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.solarGold.withOpacity(0.5)),
                            ),
                            child: Text(
                              _formatPrice(item['price_usd']),
                              style: const TextStyle(
                                color: AppTheme.solarGold,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Description
                      const Text('Deskripsi', style: TextStyle(color: AppTheme.auroraBlue, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text(
                        item['description'],
                        style: const TextStyle(color: AppTheme.starlight, fontSize: 14, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      // Specification
                      const Text('Spesifikasi Alat', style: TextStyle(color: AppTheme.auroraBlue, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.deepSpace.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.cardBorder),
                        ),
                        child: Text(
                          item['specs'],
                          style: const TextStyle(color: Color(0xFFD1D5DB), fontSize: 13, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Stores
                      const Text('Tersedia di Toko Online', style: TextStyle(color: AppTheme.auroraBlue, fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (item['stores'] as List<String>).map((store) {
                          Color storeColor = AppTheme.nebulaGreen;
                          IconData storeIcon = Icons.shopping_cart_outlined;
                          if (store.toLowerCase() == 'tokopedia') {
                            storeColor = Colors.green;
                            storeIcon = Icons.storefront;
                          } else if (store.toLowerCase() == 'shopee') {
                            storeColor = Colors.orange;
                            storeIcon = Icons.shopping_bag_outlined;
                          } else if (store.toLowerCase() == 'amazon') {
                            storeColor = Colors.amber;
                            storeIcon = Icons.language;
                          } else if (store.toLowerCase() == 'blibli') {
                            storeColor = Colors.lightBlue;
                          }
                          
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: storeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: storeColor.withOpacity(0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(storeIcon, size: 14, color: storeColor),
                                const SizedBox(width: 6),
                                Text(
                                  store,
                                  style: TextStyle(color: storeColor, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.auroraBlue,
                            foregroundColor: AppTheme.starlight,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Membuka toko online untuk ${item['name']}...'), backgroundColor: AppTheme.nebulaGreen),
                            );
                          },
                          child: const Text('Beli Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}