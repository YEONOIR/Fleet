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
  // 💡 ฟังก์ชันดึงประวัติการเช่าจาก Firebase (แบบ Join 2 ตาราง)
  // ==========================================
  Future<void> _fetchRentHistoryFromFirebase() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('bookings')
          .where('renter_id', isEqualTo: user.uid)
          .get();

      if (snap.docs.isNotEmpty) {
        List<Map<String, dynamic>> realData = [];
        
        for (var doc in snap.docs) {
          var data = doc.data() as Map<String, dynamic>;
          
          int statusCode = 4; 
          String dbStatus = data['status']?.toString().toLowerCase() ?? 'pending';
          if (dbStatus == 'accept' || dbStatus == 'accepted') statusCode = 0;
          else if (dbStatus == 'using') statusCode = 1;
          else if (dbStatus == 'complete' || dbStatus == 'completed') statusCode = 2;
          else if (dbStatus == 'cancel' || dbStatus == 'cancelled' || dbStatus == 'reject' || dbStatus == 'rejected') statusCode = 3;
          else statusCode = 4; 

          // 💡 วิ่งไปหาข้อมูลรถเพิ่มเติมจากตาราง vehicles
          String vehicleId = data['vehicle_id'] ?? '';
          String vName = 'Unknown Vehicle';
          String vPlate = '-';
          String vModel = '-';
          String vType = 'Car';
          String vImage = 'assets/images/car.jpg';
          String vAddress = 'No address';
          String vFuel = '-';
          List<dynamic> vImages = [];

          if (vehicleId.isNotEmpty) {
            var vDoc = await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).get();
            if (vDoc.exists) {
               var vd = vDoc.data() as Map<String, dynamic>;
               vName = vd['vehicle_name'] ?? vd['brand'] ?? 'Unknown Vehicle';
               vPlate = vd['license_plate'] ?? '-';
               vModel = vd['model'] ?? '-';
               vType = vd['vehicle_type'] ?? 'Car';
               vAddress = vd['address'] ?? 'No address';
               vFuel = vd['fuel'] ?? '-'; // 💡 ดึงประเภทน้ำมันมาแล้ว
               vImages = vd['images'] ?? []; // 💡 ดึงรูปภาพทั้งหมดมาแล้ว
               vImage = vImages.isNotEmpty ? vImages[0] : 'assets/images/car.jpg';
            }
          }

          // 💡 ไปดึงข้อมูลเจ้าของรถด้วย owner_id
          String ownerId = data['owner_id'] ?? '';
          String oName = 'Owner';
          String oPhone = '-';
          if (ownerId.isNotEmpty) {
            var oDoc = await FirebaseFirestore.instance.collection('users').doc(ownerId).get();
            if (oDoc.exists) {
               var od = oDoc.data() as Map<String, dynamic>;
               oName = od['first_name'] ?? 'Owner';
               oPhone = od['phone'] ?? '-';
            }
          }

          String formatDate(Timestamp? ts) {
            if (ts == null) return 'N/A';
            DateTime d = ts.toDate();
            return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
          }
          String formatTime(Timestamp? ts) {
            if (ts == null) return 'N/A';
            DateTime d = ts.toDate();
            return '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
          }

          realData.add({
            'id': doc.id,
            'vehicle_id': vehicleId,
            'name': vName, 
            'rating': 0.0, 
            'plate': vPlate,
            'model': vModel,
            'type': vType,
            'address': vAddress,
            'price': data['total_price'] ?? 0,
            'image': vImage, 
            'images': vImages, 
            'status': statusCode, 
            'fuel': vFuel, 
            'deposit': data['deposit_paid'] ?? 0,
            'owner': {
              'name': oName, 
              'phone': oPhone, 
              'rating': 0.0
            },
            'booking': {
              'startDate': formatDate(data['start_time'] as Timestamp?),
              'endDate': formatDate(data['end_time'] as Timestamp?),
              'startTime': formatTime(data['start_time'] as Timestamp?),
              'endTime': formatTime(data['end_time'] as Timestamp?),
              'totalPrice': data['total_price'] ?? 0,
            },
            'beforeRentImages': data['before_images'] ?? [],
            'afterRentImages': data['after_images'] ?? [],
            'pendingType': data['pending_type'] ?? 'rent',
            'defect': data['handin_defect'] ?? '',
            // 💡 เพิ่มตัวแปร cancelReason เข้าไปตรงนี้ครับ
            'cancelReason': data['cancel_reason'] ?? data['reject_reason'] ?? 'Cancelled by Owner',
            'created_at': data['created_at'] 
          });
        }

        realData.sort((a, b) {
           Timestamp? timeA = a['created_at'] as Timestamp?;
           Timestamp? timeB = b['created_at'] as Timestamp?;
           if (timeA == null) return 1;
           if (timeB == null) return -1;
           return timeB.compareTo(timeA);
        });

        if (mounted) setState(() => _rentData = realData);
      } else {
        if (mounted) setState(() => _rentData = []);
      }
    } catch (e) {
      print("Error fetching bookings: $e");
      if (mounted) setState(() => _rentData = []);
    } finally {
      if (mounted) setState(() => _isLoading = false); 
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