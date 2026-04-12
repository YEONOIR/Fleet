import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 1. Import Firestore

import '../../components/vehicle_info_card.dart';
import '../../components/search_header.dart'; 
import '../../components/search_calendar.dart'; 
import 'vehicle_rent_detail.dart';
import '../../components/time_selector.dart';

class RenterSearchPage extends StatefulWidget {
  const RenterSearchPage({super.key});

  @override
  State<RenterSearchPage> createState() => _RenterSearchPageState();
}

class _RenterSearchPageState extends State<RenterSearchPage>
    with SingleTickerProviderStateMixin {
  
  // ── 💡 เพิ่ม State สำหรับโหลดข้อมูล ──
  bool _isLoading = true;
  List<Map<String, dynamic>> _allVehicles = [];

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
  DateTime _calendarMonth = DateTime.now(); // 💡 อัปเดตให้เป็นเดือนปัจจุบัน

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // ── Vehicle type options ──
  static const List<Map<String, dynamic>> _vehicleTypes = [
    {'label': 'Car', 'icon': Icons.directions_car, 'type': 'Car'},
    {'label': 'Motorcycle', 'icon': Icons.two_wheeler, 'type': 'Motorcycle'},
    {'label': 'Van', 'icon': Icons.airport_shuttle, 'type': 'Van'},
  ];

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
        setState(() => _isSearchExpanded = false);
      }
    });

    // 💡 2. เรียกใช้ฟังก์ชันดึงข้อมูลรถเมื่อเปิดหน้า
    _fetchVehiclesFromFirebase();
  }

  // ==========================================
  // 💡 3. ฟังก์ชันดึงข้อมูลรถ (อัปเดตให้ตรงกับ Database ของคุณ)
  // ==========================================
  Future<void> _fetchVehiclesFromFirebase() async {
    try {
      // ค้นหารถเฉพาะคันที่ว่าง (ต้องไปเพิ่ม status: "available" ใน Firebase ด้วยนะ)
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('status', isEqualTo: 'available') 
          .get();

      List<Map<String, dynamic>> fetchedCars = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        
        fetchedCars.add({
          'id': doc.id, 
          'name': data['brand'] != null ? "${data['brand']} ${data['model']}" : "Unknown Vehicle",
          'rating': '0.0', 
          'plate': data['license_plate'] ?? '-', 
          'model': data['model'] ?? '-',
          'vType': data['vehicle_type'] ?? 'Car',
          'vehicleType': data['vehicle_type'] ?? 'Car', 
          
          // 💡 แก้ไขชื่อ Field ให้ตรงกับใน Firebase ของคุณ
          'address': data['address'] ?? 'No address provided', 
          'price': data['price_per_day'] ?? 0, 
          
          // 💡 แก้ไขให้ดึงจากคำว่า 'images' ตามฐานข้อมูลคุณ
          'image': (data['images'] != null && (data['images'] as List).isNotEmpty)
              ? data['images'][0] 
              : 'assets/images/car.jpg', 
          
          'availableFrom': DateTime.now().subtract(const Duration(days: 30)),
          'availableTo': DateTime.now().add(const Duration(days: 365)),
        });
      }

      if (mounted) {
        setState(() {
          _allVehicles = fetchedCars;
        });
      }
    } catch (e) {
      print("Error loading vehicles: $e");
      if (mounted) {
        setState(() {
          _allVehicles = [];
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
                TimeSelector(
                  startTime: _startTime,
                  endTime: _endTime,
                  onStartTimeSelected: (time) => setState(() => _startTime = time),
                  onEndTimeSelected: (time) => setState(() => _endTime = time),
                ),
                const SizedBox(height: 10), 
              ],
            ),
            
          // ── Content ──
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFAC72A1)))
                : filtered.isEmpty
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
                                          _startTime = null; 
                                          _endTime = null;  
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
                          return VehicleInfoCard(
                            data: filtered[index - 1],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VehicleRentDetailPage(
                                    vehicleData: filtered[index - 1],
                                  ),
                                ),
                              );
                            },
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
          Icon(Icons.search_off, size: 64, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 12),
          Text('No vehicles found', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey.withOpacity(0.6))),
          const SizedBox(height: 6),
          Text('Try adjusting your filters or dates', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey.withOpacity(0.5))),
        ],
      ),
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