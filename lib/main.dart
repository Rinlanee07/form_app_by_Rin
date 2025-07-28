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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4C6A4C)), 
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

  TripLocation({
    required this.name,
    required this.type,
    required this.province,
    required this.difficulty,
    required this.distance,
    required this.isUnknown,
  });

  double calculateScore() {
    double difficultyScore = (10 - difficulty) * 1.5;
    double distanceScore = distance <= 50 ? 8 : (distance <= 100 ? 5 : 2);
    double unknownBonus = isUnknown ? 2 : 0;
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

  static const List<String> _types = ['ภูเขา', 'ทะเล', 'น้ำตก', 'วัด', 'ตลาด', 'อื่นๆ'];
  static const List<String> _provinces = [
    'กรุงเทพมหานคร', 'เชียงใหม่', 'เชียงราย', 'ภูเก็ต', 'กระบี่', 'สุราษฎร์ธานี',
    'นครราชสีมา', 'ขอนแก่น', 'อุดรธานี', 'อุบลราชธานี', 'กาญจนบุรี', 'เพชรบุรี'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _buildBackgroundGradient(),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color.fromARGB(255, 12, 43, 30), Color(0xFFE8DEF8)],
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: HeaderSection(),
    );
  }

  Widget _buildContent() {
    return Expanded(
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
            _buildAddButton(),
            _buildLocationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: FilledButton.icon(
        onPressed: _showAddLocationDialog,
        icon: const Icon(Icons.add_location),
        label: const Text('เพิ่มสถานที่ท่องเที่ยว'),
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }

  Widget _buildLocationsList() {
    return Expanded(
      child: _locations.isEmpty
          ? const EmptyLocationView()
          : LocationListView(
              locations: _locations,
              onLocationTap: _showLocationDetails,
            ),
    );
  }

void _showAddLocationDialog() {
  showDialog(
    context: context,
    builder: (context) => AddLocationDialog(
      formKey: _formKey,
      nameController: _nameController,
      distanceController: _distanceController,
      selectedType: _selectedType,
      selectedProvince: _selectedProvince,
      difficulty: _difficulty,
      isUnknown: _isUnknown,
      types: _types,
      provinces: _provinces,
      onTypeChanged: (value) => setState(() => _selectedType = value),
      onProvinceChanged: (value) => setState(() => _selectedProvince = value),
      onDifficultyChanged: (value) => setState(() => _difficulty = value), // เรียก setState
      onUnknownChanged: (value) => setState(() => _isUnknown = value),
      onAdd: _addLocation,
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
      );
      
      setState(() => _locations.add(location));
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
  }

  void _showLocationDetails(TripLocation location) {
    showDialog(
      context: context,
      builder: (context) => LocationDetailDialog(
        location: location,
        onDelete: () {
          setState(() => _locations.remove(location));
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ลบ ${location.name} แล้ว')),
          );
        },
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.location_on, size: 48, color: Colors.white),
        SizedBox(height: 8),
        Text(
          'RateMyTrip',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'ชวนคุณรีวิวที่เที่ยวที่น่าจดจำ',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ],
    );
  }
}

class EmptyLocationView extends StatelessWidget {
  const EmptyLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'ยังไม่มีสถานที่ท่องเที่ยว',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class LocationListView extends StatelessWidget {
  final List<TripLocation> locations;
  final Function(TripLocation) onLocationTap;

  const LocationListView({
    super.key,
    required this.locations,
    required this.onLocationTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return LocationCard(
          location: location,
          onTap: () => onLocationTap(location),
        );
      },
    );
  }
}

class LocationCard extends StatelessWidget {
  final TripLocation location;
  final VoidCallback onTap;

  const LocationCard({
    super.key,
    required this.location,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: _buildLocationIcon(),
        title: Text(
          location.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${location.type} • ${location.province}'),
        trailing: _buildRating(),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLocationIcon() {
    return CircleAvatar(
      backgroundColor: const Color.fromARGB(255, 78, 107, 124),
      child: Icon(
        _getLocationIcon(location.type),
        color: Colors.white,
      ),
    );
  }

  Widget _buildRating() {
    return Column(
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
        Text(
          location.getRatingLevel(),
          style: const TextStyle(fontSize: 12),
        ),
      ],
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
}

class AddLocationDialog extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController distanceController;
  final String selectedType;
  final String selectedProvince;
  final double difficulty;
  final bool isUnknown;
  final List<String> types;
  final List<String> provinces;
  final Function(String) onTypeChanged;
  final Function(String) onProvinceChanged;
  final Function(double) onDifficultyChanged;
  final Function(bool) onUnknownChanged;
  final VoidCallback onAdd;

  const AddLocationDialog({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.distanceController,
    required this.selectedType,
    required this.selectedProvince,
    required this.difficulty,
    required this.isUnknown,
    required this.types,
    required this.provinces,
    required this.onTypeChanged,
    required this.onProvinceChanged,
    required this.onDifficultyChanged,
    required this.onUnknownChanged,
    required this.onAdd,
  });

  @override
  State<AddLocationDialog> createState() => _AddLocationDialogState();
}

class _AddLocationDialogState extends State<AddLocationDialog> {
  late double _difficulty;
  late bool _isUnknown;

  @override
  void initState() {
    super.initState();
    _difficulty = widget.difficulty;
    _isUnknown = widget.isUnknown;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFE6F2E6), // สีเขียวอ่อน
      title: const Text('เพิ่มสถานที่ท่องเที่ยว'),
      content: SingleChildScrollView(
        child: Form(
          key: widget.formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NameField(controller: widget.nameController),
              const SizedBox(height: 16),
              TypeDropdown(
                selectedType: widget.selectedType,
                types: widget.types,
                onTypeChanged: widget.onTypeChanged,
              ),
              const SizedBox(height: 16),
              ProvinceDropdown(
                selectedProvince: widget.selectedProvince,
                provinces: widget.provinces,
                onProvinceChanged: widget.onProvinceChanged,
              ),
              const SizedBox(height: 16),
              DistanceField(controller: widget.distanceController),
              const SizedBox(height: 16),
              DifficultySlider(
                difficulty: _difficulty,
                onChanged: (value) {
                  setState(() => _difficulty = value);
                  widget.onDifficultyChanged(value);
                },
              ),
              UnknownCheckbox(
                isUnknown: _isUnknown,
                onUnknownChanged: (value) {
                  setState(() => _isUnknown = value);
                  widget.onUnknownChanged(value);
                },
              ),
              const SizedBox(height: 16),
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
          onPressed: widget.onAdd,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF4C6A4C), // เขียวเข้ม
          ),
          child: const Text('เพิ่ม'),
        ),
      ],
    );
  }
}

// --- Widget เมทอดแยกเป็นคลาสใหม่ ---

class NameField extends StatelessWidget {
  final TextEditingController controller;
  const NameField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'ชื่อสถานที่',
        border: OutlineInputBorder(),
      ),
      validator: (value) => value?.isEmpty == true ? 'กรุณากรอกชื่อสถานที่' : null,
    );
  }
}

class TypeDropdown extends StatelessWidget {
  final String selectedType;
  final List<String> types;
  final Function(String) onTypeChanged;

  const TypeDropdown({
    super.key,
    required this.selectedType,
    required this.types,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedType,
      decoration: const InputDecoration(
        labelText: 'ประเภทสถานที่',
        border: OutlineInputBorder(),
      ),
      items: types
          .map((type) => DropdownMenuItem(value: type, child: Text(type)))
          .toList(),
      onChanged: (value) => onTypeChanged(value!),
    );
  }
}

class ProvinceDropdown extends StatelessWidget {
  final String selectedProvince;
  final List<String> provinces;
  final Function(String) onProvinceChanged;

  const ProvinceDropdown({
    super.key,
    required this.selectedProvince,
    required this.provinces,
    required this.onProvinceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedProvince,
      decoration: const InputDecoration(
        labelText: 'จังหวัด',
        border: OutlineInputBorder(),
      ),
      items: provinces
          .map((province) => DropdownMenuItem(value: province, child: Text(province)))
          .toList(),
      onChanged: (value) => onProvinceChanged(value!),
    );
  }
}

class DistanceField extends StatelessWidget {
  final TextEditingController controller;
  const DistanceField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'ระยะทางจากเมือง (กม.)',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: (value) => value?.isEmpty == true ? 'กรุณากรอกระยะทาง' : null,
    );
  }
}

class DifficultySlider extends StatelessWidget {
  final double difficulty;
  final ValueChanged<double> onChanged;

  const DifficultySlider({
    super.key,
    required this.difficulty,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ความยากในการเดินทาง: ${difficulty.toInt()}/10'),
        Slider(
          value: difficulty,
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: const Color(0xFF4C6A4C), // เขียวเข้ม
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class UnknownCheckbox extends StatelessWidget {
  final bool isUnknown;
  final ValueChanged<bool> onUnknownChanged;

  const UnknownCheckbox({
    super.key,
    required this.isUnknown,
    required this.onUnknownChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: const Text('ยังไม่เป็นที่รู้จัก'),
      value: isUnknown,
      onChanged: (value) => onUnknownChanged(value ?? false), // รองรับ nullable
      controlAffinity: ListTileControlAffinity.leading,
      activeColor: const Color(0xFF4C6A4C), // เขียวเข้ม
    );
  }
}

class LocationDetailDialog extends StatelessWidget {
  final TripLocation location;
  final VoidCallback onDelete;

  const LocationDetailDialog({
    super.key,
    required this.location,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildScoreCard(),
          const SizedBox(height: 16),
          _buildDetails(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDelete,
          child: const Text('ลบ', style: TextStyle(color: Colors.red)),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ปิด'),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Icon(_getLocationIcon(location.type), color: const Color(0xFF6750A4)),
        const SizedBox(width: 8),
        Expanded(child: Text(location.name)),
      ],
    );
  }

  Widget _buildScoreCard() {
    return Container(
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            location.getRatingLevel(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      children: [
        DetailRow(label: 'ประเภท', value: location.type),
        DetailRow(label: 'จังหวัด', value: location.province),
        DetailRow(label: 'ระยะทาง', value: '${location.distance.toInt()} กม.'),
        DetailRow(label: 'ความยาก', value: '${location.difficulty.toInt()}/10'),
        DetailRow(
          label: 'สถานะ',
          value: location.isUnknown ? 'ยังไม่เป็นที่รู้จัก ⭐' : 'เป็นที่รู้จักแล้ว',
        ),
      ],
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
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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