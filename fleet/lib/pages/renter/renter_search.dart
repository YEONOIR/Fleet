import 'package:flutter/material.dart';
import '../../components/vehicle_info_card.dart';
import '../../components/search_header.dart'; // Import component ใหม่
import '../../components/search_calendar.dart'; // Import component ใหม่
import 'vehicle_rent_detail.dart';
import '../../components/time_selector.dart';

class RenterSearchPage extends StatefulWidget {
  const RenterSearchPage({super.key});

  @override
  State<RenterSearchPage> createState() => _RenterSearchPageState();
}

class _RenterSearchPageState extends State<RenterSearchPage>
    with SingleTickerProviderStateMixin {
  // ── Search state ──
  bool _isSearchExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // ── Filter state ──
  String? _selectedVehicleType;

  // ── Calendar state ──
  bool _isCalendarOpen = false;
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime _calendarMonth = DateTime(2022, 1, 1);

TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  // ── Vehicle type options ──
  static const List<Map<String, dynamic>> _vehicleTypes = [
    {'label': 'Car', 'icon': Icons.directions_car, 'type': 'Car'},
    {'label': 'Motorcycle', 'icon': Icons.two_wheeler, 'type': 'Motorcycle'},
    {'label': 'Van', 'icon': Icons.airport_shuttle, 'type': 'Van'},
  ];

  // ── Mock vehicles with availability periods ──
  static final List<Map<String, dynamic>> _allVehicles = [
    {
      'name': "Sukrit's Honda",
      'rating': '4.5', // แก้จาก 4.5 เป็น '4.5'
      'plate': 'AB 1222',
      'model': 'Civic e:HEV',
      'vType': '4 Door Car',
      'vehicleType': 'Car',
      'address': '111/11, Ander Road, Cromium, Roselina, Bangkok 11111',
      'price': 250,
      'image': 'assets/images/car.jpg',
      'availableFrom': DateTime(2022, 1, 5),
      'availableTo': DateTime(2022, 1, 20),
    },
    {
      'name': "Pimthida's Bike",
      'rating': '4.5', // แก้จาก 4.5 เป็น '4.5'
      'plate': 'BB 567',
      'model': 'GRAND FILANO HYBRID',
      'vType': 'Motorcycle',
      'vehicleType': 'Motorcycle',
      'address': '222 JJ Village, Loo Road, Llama, Penguin, Bangkok 10120',
      'price': 300,
      'image': 'assets/images/bike.jpg',
      'availableFrom': DateTime(2022, 1, 8),
      'availableTo': DateTime(2022, 1, 25),
    },
    {
      'name': "Aran's Toyota",
      'rating': '4.3', // แก้จาก 4.3 เป็น '4.3'
      'plate': 'CC 8901',
      'model': 'Camry 2.5 HEV',
      'vType': '4 Door Car',
      'vehicleType': 'Car',
      'address': '333 Siam Square, Pathum Wan, Bangkok 10330',
      'price': 300,
      'image': 'assets/images/car.jpg',
      'availableFrom': DateTime(2022, 1, 1),
      'availableTo': DateTime(2022, 1, 15),
    },
    {
      'name': "Nari's Mazda",
      'rating': '4.0', // แก้จาก 4.0 เป็น '4.0'
      'plate': 'DD 2345',
      'model': 'Mazda 3 Hatchback',
      'vType': 'Hatchback',
      'vehicleType': 'Car',
      'address': '444 Sukhumvit Rd, Khlong Toei, Bangkok 10110',
      'price': 220,
      'image': 'assets/images/car.jpg',
      'availableFrom': DateTime(2022, 1, 12),
      'availableTo': DateTime(2022, 2, 5),
    },
    {
      'name': "Krit's BMW",
      'rating': '4.8', // แก้จาก 4.8 เป็น '4.8'
      'plate': 'EE 6789',
      'model': 'X3 xDrive30e',
      'vType': 'SUV',
      'vehicleType': 'Car',
      'address': '555 Silom Rd, Bang Rak, Bangkok 10500',
      'price': 450,
      'image': 'assets/images/car.jpg',
      'availableFrom': DateTime(2022, 1, 3),
      'availableTo': DateTime(2022, 1, 30),
    },
    {
      'name': "Somchai's Van",
      'rating': '4.2', // แก้จาก 4.2 เป็น '4.2'
      'plate': 'FF 3456',
      'model': 'Commuter HiAce',
      'vType': 'Van',
      'vehicleType': 'Van',
      'address': '666 Ratchadaphisek Rd, Bangkok 10310',
      'price': 500,
      'image': 'assets/images/car2.jpg',
      'availableFrom': DateTime(2022, 1, 1),
      'availableTo': DateTime(2022, 1, 28),
    },
    {
      'name': "Dao's Bike",
      'rating': '4.6', // แก้จาก 4.6 เป็น '4.6'
      'plate': 'GG 7890',
      'model': 'PCX 160',
      'vType': 'Motorcycle',
      'vehicleType': 'Motorcycle',
      'address': '777 Rama 9 Rd, Bangkok 10320',
      'price': 150,
      'image': 'assets/images/bike.jpg',
      'availableFrom': DateTime(2022, 1, 10),
      'availableTo': DateTime(2022, 2, 10),
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
        setState(() => _isSearchExpanded = false);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // ── Filter logic ──
  List<Map<String, dynamic>> get _filteredVehicles {
    List<Map<String, dynamic>> results = List.from(_allVehicles);
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isNotEmpty) {
      results = results.where((v) {
        final name = (v['name'] as String).toLowerCase();
        final model = (v['model'] as String).toLowerCase();
        final plate = (v['plate'] as String).toLowerCase();
        return name.contains(query) || model.contains(query) || plate.contains(query);
      }).toList();
    }

    if (_selectedVehicleType != null) {
      results = results.where((v) => v['vehicleType'] == _selectedVehicleType).toList();
    }

    if (_startDate != null && _endDate != null) {
      results = results.where((v) {
        final availFrom = v['availableFrom'] as DateTime;
        final availTo = v['availableTo'] as DateTime;
        return !availFrom.isAfter(_startDate!) && !availTo.isBefore(_endDate!);
      }).toList();
    }

    return results;
  }

  void _onDateTap(DateTime date) {
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        _startDate = date;
        _endDate = null;
      } else {
        if (date.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = date;
        } else {
          _endDate = date;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredVehicles;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Header Component ──
          SearchHeader(
            isSearchExpanded: _isSearchExpanded,
            searchController: _searchController,
            searchFocusNode: _searchFocusNode,
            onSearchExpandedChange: (expanded) => setState(() => _isSearchExpanded = expanded),
            onSearchChanged: () => setState(() {}),
            isFilterActive: _selectedVehicleType != null,
            onFilterTap: _showFilterSheet,
            isCalendarActive: _startDate != null,
            onCalendarTap: () => setState(() => _isCalendarOpen = !_isCalendarOpen),
          ),

          // ── Calendar Component ──
          // ── Calendar & Time Component ──
          if (_isCalendarOpen)
            Column(
              children: [
                SearchCalendar(
                  startDate: _startDate,
                  endDate: _endDate,
                  calendarMonth: _calendarMonth,
                  onDateTap: _onDateTap,
                  onMonthChanged: (newMonth) => setState(() => _calendarMonth = newMonth),
                ),
                // 💡 แทรก TimeSelector ต่อท้ายเข้าไป
                TimeSelector(
                  startTime: _startTime,
                  endTime: _endTime,
                  onStartTimeSelected: (time) => setState(() => _startTime = time),
                  onEndTimeSelected: (time) => setState(() => _endTime = time),
                ),
                const SizedBox(height: 10), // เพิ่มระยะห่างนิดหน่อย
              ],
            ),
          // ── Content ──
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: filtered.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Highlight', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF070E2A))),
                              if (_selectedVehicleType != null || _startDate != null)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedVehicleType = null;
                                      _startDate = null;
                                      _endDate = null;
                                      _startTime = null; // 💡 เคลียร์ Time
                                      _endTime = null;   // 💡 เคลียร์ Time
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: const Color(0xFFF3E5F5), borderRadius: BorderRadius.circular(12)),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.clear, size: 14, color: Color(0xFF7B1FA2)),
                                        SizedBox(width: 4),
                                        Text('Clear filters', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF7B1FA2))),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildVehicleCard(filtered[index - 1]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ─────────── Empty State ───────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 64,
            color: const Color(0xFF070E2A).withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No vehicles found',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF070E2A).withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search terms',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: const Color(0xFF070E2A).withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }


  // ─────────── Vehicle Card ───────────
  Widget _buildVehicleCard(Map<String, dynamic> vehicle) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => VehicleRentDetailPage(vehicleData: vehicle)));
      },
      child: VehicleInfoCard(data: vehicle),
    );
  }

  // ─────────── Filter Bottom Sheet ───────────
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 20),
                  const Text('Filter by Vehicle Type', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF070E2A))),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _vehicleTypes.map((vt) {
                      final isSelected = _selectedVehicleType == vt['type'];
                      return GestureDetector(
                        onTap: () {
                          setSheetState(() {
                            setState(() {
                              _selectedVehicleType = isSelected ? null : vt['type'] as String;
                            });
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF070E2A) : const Color(0xFFF3E5F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isSelected ? const Color(0xFF070E2A) : const Color(0xFFCE93D8), width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(vt['icon'] as IconData, size: 20, color: isSelected ? Colors.white : const Color(0xFF070E2A)),
                              const SizedBox(width: 8),
                              Text(vt['label'] as String, style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : const Color(0xFF070E2A))),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(30), gradient: const LinearGradient(colors: [Color(0xFFAC72A1), Color(0xFF070E2A)])),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        child: const Text('Apply Filter', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }
}