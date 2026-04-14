import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
// 💡 1. นำเข้าแพ็กเกจแผนที่และพิกัด
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../components/vehicle_info_card.dart'; 
import 'vehicle_rent_detail.dart';

class RenterHomePage extends StatefulWidget { 
  const RenterHomePage({super.key});

  @override
  State<RenterHomePage> createState() => _RenterHomePageState();
}

class _RenterHomePageState extends State<RenterHomePage> {
  String _firstName = "Loading...";
  double _credit = 0.0;
  List<Map<String, dynamic>> _vehicles = [];
  
  bool _isLoadingUser = true;
  bool _isLoadingVehicles = true;

  // 💡 2. กำหนดพิกัดเริ่มต้นของแผนที่ (ละติจูด, ลองจิจูด)
  final LatLng _currentLocation = const LatLng(13.7944, 100.3246);

  @override
  void initState() {
    super.initState();
    _fetchUserData();     
    _fetchVehiclesData(); 
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          if (mounted) {
            setState(() {
              _firstName = doc['first_name'] ?? 'User';
              _credit = (doc['wallet_balance'] ?? 0).toDouble();
              _isLoadingUser = false;
            });
          }
        }
      }
    } catch (e) {
      print("Error loading user data: $e");
      if (mounted) setState(() => _isLoadingUser = false);
    }
  }

  // 💡 ไฟล์ renter_home.dart ในส่วนของ _fetchVehiclesData()
  Future<void> _fetchVehiclesData() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('status', isEqualTo: 'available') 
          .limit(5)
          .get();

      List<Map<String, dynamic>> fetchedCars = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        fetchedCars.add({
          // 💡 แก้ไขการส่งข้อมูลให้ครบถ้วน และตรงตาม Key ที่ต้องการ
          'id': doc.id, 
          'V Name': data['vehicle_name'] ?? (data['brand'] != null ? "${data['brand']} ${data['model']}" : "Unknown Vehicle"), // ลองหา V Name ก่อน ถ้าไม่มีค่อยผสม
          'V_Rate': (data['rating'] ?? 0.0).toDouble(), // ดึง rating จริงๆ
          'V Plate': data['license_plate'] ?? '-',
          'V Brand': data['brand'] ?? '-',
          'V Model': data['model'] ?? '-',
          'V Type': data['vehicle_type'] ?? 'Car',
          'V Fuel': data['fuel'] ?? 'N/A', // ต้องดึง fuel มาด้วยเพื่อให้ใช้กับไอคอนพลังงานได้
          'V Address': data['address'] ?? data['location'] ?? 'No address provided', // ดึง address แทน location
          'V Price': (data['price_per_day'] ?? 0).toDouble(),
          'V Deposit': (data['deposit'] ?? 0).toDouble(), // เผื่อไว้ส่งต่อให้หน้ารายละเอียด
          // ดึงรูปจาก 'images' ตามที่เห็นในฐานข้อมูลของคุณ
          'imagePath': (data['images'] != null && (data['images'] as List).isNotEmpty) ? data['images'][0] : 'assets/images/car.jpg',
          'images': data['images'] ?? [], // ส่งไปเผื่อดูรูปเต็มในหน้ารายละเอียด
        });
      }

      if (mounted) {
        setState(() {
          _vehicles = fetchedCars;
          _isLoadingVehicles = false;
        });
      }
    } catch (e) {
      print("Error loading vehicles: $e");
      if (mounted) setState(() => _isLoadingVehicles = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildCreditTopUpRow(context),
            const SizedBox(height: 24),
            
            // ── Map Section ──
            _buildMapSection(),
            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Top 5 most car near you',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF070E2A),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20), 
              child: _isLoadingVehicles
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFAC72A1)))
                  : _vehicles.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              'No vehicles available right now.\nCheck back later!',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                            ),
                          ),
                        )
                      : Column(
                          children: List.generate(_vehicles.length, (index) {
                            return VehicleInfoCard(
                              data: _vehicles[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VehicleRentDetailPage(
                                      vehicleData: _vehicles[index],
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ),
            ),
            const SizedBox(height: 20),
          ],
        ),
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
          colors: [Color(0xFFAC72A1), Color(0xFF070E2A)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Text(
            _isLoadingUser ? 'Loading...' : 'Welcome, $_firstName',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

 // ─────────── Credit & Top Up Row (Fixed Height & Auto Refresh) ───────────
  Widget _buildCreditTopUpRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // ── 1. Credit Card ──
          Expanded(
            child: Container(
              height: 85, 
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04), 
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3E5F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded, 
                      color: Color(0xFFAC72A1), 
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, 
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My Credit',
                          style: TextStyle(
                            fontFamily: 'Poppins', 
                            fontSize: 12, 
                            fontWeight: FontWeight.w500, 
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _isLoadingUser ? '...' : '฿${_credit.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontFamily: 'Poppins', 
                            fontSize: 18, 
                            fontWeight: FontWeight.w700, 
                            color: Color(0xFF070E2A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // ── 2. Top Up Button ──
          Expanded(
            child: GestureDetector(
              // 💡 แก้ไขตรงนี้: ใส่ async / await เพื่อให้มันรอ และดึงข้อมูลใหม่เมื่อกลับมา
              onTap: () async {
                // รอจนกว่าหน้า Top-up จะถูกปิด
                await Navigator.pushNamed(context, '/renter/topup');
                
                // พอกลับมาปุ๊บ สั่งให้โชว์สถานะโหลด และดึงข้อมูลใหม่ทันที
                if (mounted) {
                  setState(() {
                    _isLoadingUser = true;
                  });
                  _fetchUserData(); 
                }
              },
              child: Container(
                height: 85, 
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF3E5F5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_card_rounded, 
                        color: Color(0xFFAC72A1),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Top up',
                      style: TextStyle(
                        fontFamily: 'Poppins', 
                        fontSize: 16, 
                        fontWeight: FontWeight.w600, 
                        color: Color(0xFF070E2A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 💡 3. เปลี่ยนจากภาพวาดเป็นแผนที่ของจริง
  // ==========================================
  Widget _buildMapSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Vehicles near you',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF070E2A),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 200, // ขยายความสูงแผนที่นิดนึงให้ดูง่ายขึ้น
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: _currentLocation, // จุดศูนย์กลางแผนที่
                  initialZoom: 14.5, // ระดับการซูม (ยิ่งเยอะยิ่งใกล้)
                ),
                children: [
                  // 💡 ตัวดึงภาพแผนที่มาจาก OpenStreetMap (ฟรี)
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.fleet.app',
                  ),
                  // 💡 ชั้นสำหรับวางหมุดต่างๆ บนแผนที่
                  MarkerLayer(
                    markers: [
                      // หมุดตำแหน่งของเราเอง
                      Marker(
                        point: _currentLocation,
                        width: 60,
                        height: 60,
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF070E2A),
                          size: 40,
                        ),
                      ),
                      // หมุดตัวอย่างรถคันที่ 1
                      Marker(
                        point: const LatLng(13.7960, 100.3260),
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFFE91E63),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.directions_car, color: Colors.white, size: 20),
                        ),
                      ),
                      // หมุดตัวอย่างมอเตอร์ไซค์
                      Marker(
                        point: const LatLng(13.7920, 100.3210),
                        width: 40,
                        height: 40,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF9C27B0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.two_wheeler, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}