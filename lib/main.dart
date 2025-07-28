import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const RateMyTripApp());
}

class RateMyTripApp extends StatelessWidget {
  const RateMyTripApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RateMyTrip',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TripLocation {
  final String name;
  final String type;
  final String province;
  final double difficulty;
  final double distance;
  final bool isUnknown;
  final String? imageUrl;

  TripLocation({
    required this.name,
    required this.type,
    required this.province,
    required this.difficulty,
    required this.distance,
    required this.isUnknown,
    this.imageUrl,
  });

  double calculateScore() {
    double difficultyScore = (10 - difficulty) * 1.5; // 0-15 คะแนน
    double distanceScore = distance <= 50 ? 8 : (distance <= 100 ? 5 : 2); // 0-8 คะแนน
    double unknownBonus = isUnknown ? 2 : 0; // 0-2 คะแนน
    return difficultyScore + distanceScore + unknownBonus;
  }

  String getRatingLevel() {
    double score = calculateScore();
    if (score >= 20) return '🌟 ยอดเยี่ยม';
    if (score >= 15) return '⭐ ดีมาก';
    if (score >= 10) return '👍 ดี';
    return '📍 พอใช้';
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<TripLocation> _locations = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _distanceController = TextEditingController();
  
  String _selectedType = 'อื่นๆ';
  String _selectedProvince = 'กรุงเทพมหานคร';
  double _difficulty = 5.0;
  bool _isUnknown = false;
  String _imageUrl = '';

  final List<String> _types = ['ภูเขา', 'ทะเล', 'น้ำตก', 'วัด', 'ตลาด', 'อื่นๆ'];
  final List<String> _provinces = [
    'กรุงเทพมหานคร', 'เชียงใหม่', 'เชียงราย', 'ภูเก็ต', 'กระบี่', 'สุราษฎร์ธานี',
    'นครราชสีมา', 'ขอนแก่น', 'อุดรธานี', 'อุบลราชธานี', 'กาญจนบุรี', 'เพชรบุรี'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6750A4), Color(0xFFE8DEF8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Icon(Icons.location_on, size: 48, color: Colors.white),
                    const SizedBox(height: 8),
                    const Text(
                      'RateMyTrip',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'ค้นหาและประเมินสถานที่ท่องเที่ยว',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      
                      // Add Button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: FilledButton.icon(
                          onPressed: _showAddLocationDialog,
                          icon: const Icon(Icons.add_location),
                          label: const Text('เพิ่มสถานที่ท่องเที่ยว'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ),
                      
                      // Locations List
                      Expanded(
                        child: _locations.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.explore_outlined, size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text('ยังไม่มีสถานที่ท่องเที่ยว', style: TextStyle(fontSize: 18, color: Colors.grey)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _locations.length,
                                itemBuilder: (context, index) {
                                  final location = _locations[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: const Color(0xFF6750A4),
                                        child: Icon(_getLocationIcon(location.type), color: const Color(0xFF6750A4)),
                                      ),
                                      title: Text(location.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      subtitle: Text('${location.type} • ${location.province}'),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.star, size: 16, color: Colors.amber),
                                              Text('${location.calculateScore().toStringAsFixed(1)}/25'),
                                            ],
                                          ),
                                          Text(location.getRatingLevel(), style: const TextStyle(fontSize: 12)),
                                        ],
                                      ),
                                      onTap: () => _showLocationDetails(location),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getLocationIcon(String type) {
    switch (type) {
      case 'ภูเขา': return Icons.terrain;
      case 'ทะเล': return Icons.waves;
      case 'น้ำตก': return Icons.water;
      case 'วัด': return Icons.temple_buddhist;
      case 'ตลาด': return Icons.store;
      default: return Icons.place;
    }
  }

  void _showAddLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มสถานที่ท่องเที่ยว'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อสถานที่',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value?.isEmpty == true ? 'กรุณากรอกชื่อสถานที่' : null,
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'ประเภทสถานที่',
                    border: OutlineInputBorder(),
                  ),
                  items: _types.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
                const SizedBox(height: 16),
                
                DropdownButtonFormField<String>(
                  value: _selectedProvince,
                  decoration: const InputDecoration(
                    labelText: 'จังหวัด',
                    border: OutlineInputBorder(),
                  ),
                  items: _provinces.map((province) => DropdownMenuItem(value: province, child: Text(province))).toList(),
                  onChanged: (value) => setState(() => _selectedProvince = value!),
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _distanceController,
                  decoration: const InputDecoration(
                    labelText: 'ระยะทางจากเมือง (กม.)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => value?.isEmpty == true ? 'กรุณากรอกระยะทาง' : null,
                ),
                const SizedBox(height: 16),
                
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ความยากในการเดินทาง: ${_difficulty.toInt()}/10'),
                    Slider(
                      value: _difficulty,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      onChanged: (value) => setState(() => _difficulty = value),
                    ),
                  ],
                ),
                
                CheckboxListTile(
                  title: const Text('ยังไม่เป็นที่รู้จัก'),
                  value: _isUnknown,
                  onChanged: (value) => setState(() => _isUnknown = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: _addLocation,
            child: const Text('เพิ่ม'),
          ),
        ],
      ),
    );
  }

  void _addLocation() {
    if (_formKey.currentState!.validate()) {
      final location = TripLocation(
        name: _nameController.text,
        type: _selectedType,
        province: _selectedProvince,
        difficulty: _difficulty,
        distance: double.parse(_distanceController.text),
        isUnknown: _isUnknown,
        imageUrl: _imageUrl.isNotEmpty ? _imageUrl : null,
      );
      
      setState(() {
        _locations.add(location);
      });
      
      _clearForm();
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เพิ่ม ${location.name} เรียบร้อยแล้ว')),
      );
    }
  }

  void _clearForm() {
    _nameController.clear();
    _distanceController.clear();
    _difficulty = 5.0;
    _isUnknown = false;
    _imageUrl = '';
  }

  void _showLocationDetails(TripLocation location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getLocationIcon(location.type), color: const Color(0xFF6750A4)),
            const SizedBox(width: 8),
            Expanded(child: Text(location.name)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (location.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  location.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6750A4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '${location.calculateScore().toStringAsFixed(1)}/25',
                                               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    location.getRatingLevel(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildDetailRow('ประเภท', location.type),
            _buildDetailRow('จังหวัด', location.province),
            _buildDetailRow('ระยะทาง', '${location.distance.toInt()} กม.'),
            _buildDetailRow('ความยาก', '${location.difficulty.toInt()}/10'),
            _buildDetailRow('สถานะ', location.isUnknown ? 'ยังไม่เป็นที่รู้จัก ⭐' : 'เป็นที่รู้จักแล้ว'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _locations.remove(location);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ลบ ${location.name} แล้ว')),
              );
            },
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
