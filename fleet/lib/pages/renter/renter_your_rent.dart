import 'package:flutter/material.dart';
import '../../components/history_card.dart'; // ใส่ path ให้ตรงกับโฟลเดอร์ของคุณ
import 'rent_history.dart'; // ใส่ path ให้ตรงกับโฟลเดอร์ของคุณ

class RenterYourRentPage extends StatefulWidget {
  // 💡 1. เพิ่มตัวแปรรับค่า initialIndex และกำหนดค่าเริ่มต้นเป็น 0 (แท็บ Accept)
  final int initialIndex;
  
  const RenterYourRentPage({super.key, this.initialIndex = 0});

  @override
  State<RenterYourRentPage> createState() => _RenterYourRentPageState();
}

class _RenterYourRentPageState extends State<RenterYourRentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // ── Tab definitions ──
  static const List<String> _tabLabels = [
    'Accept',
    'Using',
    'Complete',
    'Cancel',
    'Pending',
  ];

  // 💡 อัปเดตสีแท็บ
  static const List<Color> _tabColors = [
    Color(0xFF2E7D6E), // Accept – กลับมาใช้สีเดิม
    Color.fromRGBO(172, 114, 161, 1.0), // Using 
    Color(0xFF31A1D1), // Complete 
    Color(0xFFC62828), // Cancel 
    Color(0xFFE6A817), // Pending 
  ];

  // 💡 อัปเดตสีขอบและเงาของการ์ด
  static const List<List<Color>> _cardBorderGradients = [
    [Color(0xFF2E7D6E), Color(0xFF80CBC4)], // Accept (กลับมาใช้คู่สีเดิม)
    [Color.fromRGBO(172, 114, 161, 1.0), Color(0xFFE1BEE7)], // Using
    [Color(0xFF31A1D1), Color(0xFFB3E5FC)], // Complete
    [Color(0xFFC62828), Color(0xFFEF9A9A)], // Cancel
    [Color(0xFFE6A817), Color(0xFFFFF176)], // Pending
  ];

  // ── Mock rent data ──
  static const List<Map<String, dynamic>> _rentData = [
    // ... ข้อมูลเดิมของคุณ ...
    // ── Accept (index 0) ──
    {
      'name': "Sukrit's Honda",
      'rating': 4.5,
      'plate': 'AB 1222',
      'model': 'Civic e:HEV',
      'type': '4 Door Car',
      'address': '111/11, Ander Road, Cromium, Roselina, Bangkok 11111',
      'price': 250,
      'image': 'assets/images/car.jpg', // อย่าลืมใส่รูปจริงใน assets
      'status': 0,
      'fuel': 'EV',
      'deposit': 1000,
      'owner': {'name': 'Sukrit', 'phone': '081-234-5678', 'rating': 4.8},
      'booking': {'startDate': '10 Apr 2026', 'endDate': '12 Apr 2026', 'startTime': '10:00', 'endTime': '10:00', 'totalPrice': 12000},
      'beforeRentImages': ['assets/images/car.jpg', 'assets/images/car.jpg'],
    },

    // ── Using (index 1) ──
    {
      'name': "Aran's Toyota",
      'rating': 4.3,
      'plate': 'CC 8901',
      'model': 'Camry 2.5 HEV',
      'type': '4 Door Car',
      'address': '333 Siam Square, Pathum Wan, Bangkok 10330',
      'price': 300,
      'image': 'assets/images/car.jpg',
      'status': 1,
      'fuel': 'Gasohol 95',
      'deposit': 1500,
      'owner': {'name': 'Aran', 'phone': '089-876-5432', 'rating': 4.2},
      'booking': {'startDate': '08 Apr 2026', 'endDate': '09 Apr 2026', 'startTime': '09:00', 'endTime': '18:00', 'totalPrice': 2700},
      'beforeRentImages': ['assets/images/car.jpg', 'assets/images/car.jpg', 'assets/images/car.jpg'],
    },

    // ── Complete (index 2) ──
    {
      'name': "Nari's Mazda",
      'rating': 4.0,
      'plate': 'DD 2345',
      'model': 'Mazda 3 Hatchback',
      'type': 'Hatchback',
      'address': '444 Sukhumvit Rd, Khlong Toei, Bangkok 10110',
      'price': 220,
      'image': 'assets/images/car.jpg',
      'status': 2,
      'fuel': 'Diesel',
      'deposit': 1000,
      'owner': {'name': 'Nari', 'phone': '082-333-4444', 'rating': 4.5},
      'booking': {'startDate': '01 Apr 2026', 'endDate': '03 Apr 2026', 'startTime': '12:00', 'endTime': '12:00', 'totalPrice': 10560},
      'beforeRentImages': ['assets/images/car.jpg', 'assets/images/car.jpg'],
      'defect': 'พบรอยขีดข่วนเล็กน้อยที่กันชนหน้าซ้าย นอกนั้นปกติครับ', 
    },

    // ── Cancel (index 3) ──
    {
      'name': "Sukrit's Honda",
      'rating': 4.5,
      'plate': 'AB 1222',
      'model': 'Civic e:HEV',
      'type': '4 Door Car',
      'address': '111/11, Ander Road, Cromium, Roselina, Bangkok 11111',
      'price': 250,
      'image': 'assets/images/car.jpg',
      'status': 3,
      'fuel': 'EV',
      'deposit': 1000,
      'owner': {'name': 'Sukrit', 'phone': '081-234-5678', 'rating': 4.8},
      'booking': {'startDate': '15 Apr 2026', 'endDate': '16 Apr 2026', 'startTime': '08:00', 'endTime': '20:00', 'totalPrice': 3000},
      'beforeRentImages': [],
    },

    // ── Pending (index 4) ──
    {
      'name': "Krit's BMW",
      'rating': 4.8,
      'plate': 'EE 6789',
      'model': 'X3 xDrive30e',
      'type': 'SUV',
      'address': '555 Silom Rd, Bang Rak, Bangkok 10500',
      'price': 450,
      'image': 'assets/images/car.jpg',
      'status': 4,
      'fuel': 'PHEV',
      'deposit': 3000,
      'owner': {'name': 'Krit', 'phone': '085-555-6666', 'rating': 4.9},
      'booking': {'startDate': '20 Apr 2026', 'endDate': '22 Apr 2026', 'startTime': '10:00', 'endTime': '10:00', 'totalPrice': 21600},
      'beforeRentImages': [],
      // 💡 เพิ่ม pendingType: 'rent' สำหรับรายการที่รอการยืนยันเช่า
      'pendingType': 'rent', 
    },
    {
      'name': "Sompong's MG",
      'rating': 4.2,
      'plate': 'กท 9999',
      'model': 'MG ZS EV',
      'type': 'SUV',
      'address': '123 Sukhumvit Rd, Bangkok 10110',
      'price': 350,
      'image': 'assets/images/car.jpg',
      'status': 4, // อยู่ในแท็บ Pending เหมือนกัน
      'fuel': 'EV',
      'deposit': 2000,
      'owner': {'name': 'Sompong', 'phone': '081-111-2222', 'rating': 4.3},
      'booking': {'startDate': '05 Apr 2026', 'endDate': '07 Apr 2026', 'startTime': '09:00', 'endTime': '18:00', 'totalPrice': 5000},
      // 💡 เพิ่มรูป beforeRentImages มาด้วย เพราะแบบรอคืนต้องโชว์เหมือนหน้า Using
      'beforeRentImages': ['assets/images/car.jpg', 'assets/images/car.jpg'], 
      // 💡 เพิ่ม pendingType: 'return' สำหรับรายการที่เพิ่งกดคืนรถไป
      'pendingType': 'return', 
    },
  ];

  @override
  void initState() {
    super.initState();
    // 💡 2. เอา initialIndex มาตั้งเป็นค่าเริ่มต้นของ TabController
    _tabController = TabController(
      length: 5, 
      vsync: this,
      initialIndex: widget.initialIndex, // ดึงค่าจากตัวแปรด้านบนมาใช้
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _itemsForTab(int tabIndex) {
    return _rentData.where((e) => e['status'] == tabIndex).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(5, (tabIndex) {
                return _buildTabContent(tabIndex);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFAC72A1),
            Color(0xFF070E2A),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: const Center(
        child: Text(
          'Your rent',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFEEEEEE),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        labelPadding: EdgeInsets.zero,
        indicatorColor: _tabColors[_tabController.index],
        indicatorWeight: 3,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        labelColor: _tabColors[_tabController.index],
        unselectedLabelColor: const Color(0xFF999999),
        tabs: List.generate(5, (i) {
          return Tab(text: _tabLabels[i]);
        }),
      ),
    );
  }

  Widget _buildTabContent(int tabIndex) {
    final items = _itemsForTab(tabIndex);

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 64,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No ${_tabLabels[tabIndex].toLowerCase()} rentals',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          // เรียกใช้ HistoryCard ที่เพิ่งแยกออกไป
          child: HistoryCard(
            car: items[index],
            gradientColors: _cardBorderGradients[tabIndex],
            onTap: () {
              // กดแล้วให้ไปยังหน้า Detail ที่แยกไว้
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RentHistoryDetailPage(
                    car: items[index],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}