import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 

import '../../components/history_card.dart'; 
import 'rent_history.dart'; 

class RenterYourRentPage extends StatefulWidget {
  final int initialIndex;
  
  const RenterYourRentPage({super.key, this.initialIndex = 0});

  @override
  State<RenterYourRentPage> createState() => _RenterYourRentPageState();
}

class _RenterYourRentPageState extends State<RenterYourRentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true; // 💡 เพิ่มสถานะกำลังโหลด

  static const List<String> _tabLabels = [
    'Accept',
    'Using',
    'Complete',
    'Cancel',
    'Pending',
  ];

  static const List<Color> _tabColors = [
    Color(0xFF2E7D6E), 
    Color.fromRGBO(172, 114, 161, 1.0),  
    Color(0xFF31A1D1), 
    Color(0xFFC62828), 
    Color(0xFFE6A817),  
  ];

  static const List<List<Color>> _cardBorderGradients = [
    [Color(0xFF2E7D6E), Color(0xFF80CBC4)], 
    [Color.fromRGBO(172, 114, 161, 1.0), Color(0xFFE1BEE7)], 
    [Color(0xFF31A1D1), Color(0xFFB3E5FC)], 
    [Color(0xFFC62828), Color(0xFFEF9A9A)], 
    [Color(0xFFE6A817), Color(0xFFFFF176)], 
  ];
  
  // 💡 ลบข้อมูลจำลองทิ้งให้หมด แล้วเปลี่ยนเป็นลิสต์ว่างๆ (กล่องเปล่า) 
  List<Map<String, dynamic>> _rentData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 5, 
      vsync: this,
      initialIndex: widget.initialIndex, 
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });

    // 💡 เริ่มโหลดข้อมูลจาก Firebase เมื่อเปิดหน้า
    _fetchRentHistoryFromFirebase();
  }

  // ==========================================
  // 💡 ฟังก์ชันดึงประวัติการเช่าจาก Firebase (แบบจริง)
  // ==========================================
  Future<void> _fetchRentHistoryFromFirebase() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // ไปค้นหาข้อมูลในตาราง bookings
      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('renter_id', isEqualTo: user.uid)
          .get();

      if (snap.docs.isNotEmpty) {
        List<Map<String, dynamic>> realData = [];
        
        for (var doc in snap.docs) {
          var data = doc.data() as Map<String, dynamic>;
          
          realData.add({
            'id': doc.id,
            'name': data['vehicle_name'] ?? 'Unknown Vehicle', 
            'rating': 0.0, 
            'plate': data['license_plate'] ?? '-',
            'model': data['vehicle_model'] ?? '-',
            'type': data['vehicle_type'] ?? 'Car',
            'address': data['location'] ?? 'No address provided',
            'price': data['total_price'] ?? 0,
            'image': data['image_url'] ?? 'assets/images/car.jpg', 
            'status': data['status'] ?? 4, 
            'fuel': data['fuel'] ?? '-',
            'deposit': data['deposit_paid'] ?? 0,
            'owner': {
              'name': data['owner_name'] ?? 'Owner', 
              'phone': data['owner_phone'] ?? '-', 
              'rating': 0.0
            },
            'booking': {
              'startDate': data['start_date'] ?? 'N/A',
              'endDate': data['end_date'] ?? 'N/A',
              'startTime': data['start_time'] ?? 'N/A',
              'endTime': data['end_time'] ?? 'N/A',
              'totalPrice': data['total_price'] ?? 0,
            },
            'beforeRentImages': data['before_images'] ?? [],
            'afterRentImages': data['after_images'] ?? [],
            'pendingType': data['pending_type'] ?? 'rent',
            'defect': data['defect'] ?? '',
          });
        }

        if (mounted) {
          setState(() {
            _rentData = realData;
          });
        }
      } else {
        // 💡 ถ้าไม่เจอข้อมูล ให้ล้างข้อมูลเป็นลิสต์ว่าง เพื่อให้โชว์หน้า No rentals
        if (mounted) {
          setState(() {
            _rentData = [];
          });
        }
      }
    } catch (e) {
      print("Error fetching bookings: $e");
      if (mounted) {
        setState(() {
          _rentData = [];
        });
      }
    } finally {
      // 💡 หยุดหมุนวงแหวน ไม่ว่าจะดึงข้อมูลสำเร็จ หรือพัง หรือว่างเปล่า
      if (mounted) {
        setState(() => _isLoading = false); 
      }
    }
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
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFAC72A1)))
                : TabBarView(
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Your rent',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 48), 
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        labelPadding: EdgeInsets.zero,
        indicatorColor: _tabColors[_tabController.index],
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w400),
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
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No ${_tabLabels[tabIndex].toLowerCase()} rentals',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey.withOpacity(0.6),
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
          child: HistoryCard(
            car: items[index],
            gradientColors: _cardBorderGradients[tabIndex],
            onTap: () {
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