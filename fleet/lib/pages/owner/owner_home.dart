import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../components/request_card.dart'; 

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  String selectedType = 'All';
  final List<String> filterTypes = ['All', 'Rent', 'Hand in'];

  // 💡 State สำหรับเก็บข้อมูลจริง
  bool _isLoading = true;
  String _ownerFirstName = "Owner";
  List<Map<String, dynamic>> _requests = [];
  StreamSubscription<QuerySnapshot>? _bookingSubscription;

  @override
  void initState() {
    super.initState();
    _fetchOwnerName();
    _listenToRequests();
  }

  @override
  void dispose() {
    _bookingSubscription?.cancel(); // ยกเลิกการฟังเมื่อปิดหน้า
    super.dispose();
  }

  // ==========================================
  // 💡 ดึงชื่อเจ้าของรถมาโชว์ที่ AppBar
  // ==========================================
  Future<void> _fetchOwnerName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        setState(() {
          _ownerFirstName = doc['first_name'] ?? 'Owner';
        });
      }
    }
  }

  // ==========================================
  // 💡 ฟังข้อมูล Request จาก Firebase แบบ Real-time
  // ==========================================
  void _listenToRequests() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // ดึงเฉพาะ booking ที่เกี่ยวข้องกัน Owner คนนี้ และรอการอนุมัติ (pending)
    _bookingSubscription = FirebaseFirestore.instance
        .collection('bookings')
        .where('owner_id', isEqualTo: user.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) async {
          
      List<Map<String, dynamic>> fetchedRequests = [];

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        
        // จำแนกประเภทคำขอ (ถ้ามีการขอคืนรถ จะมี pending_type = 'return')
        String pendingType = data['pending_type'] ?? 'rent';
        String reqType = pendingType == 'return' ? 'Hand in' : 'Rent';

        // 1. วิ่งไปดึงข้อมูลผู้เช่า (Renter)
        String renterId = data['renter_id'] ?? '';
        String fName = 'Unknown';
        String lName = '';
        String phone = '-';
        String renterImage = 'assets/icons/avatar.jpg';

        if (renterId.isNotEmpty) {
          var rDoc = await FirebaseFirestore.instance.collection('users').doc(renterId).get();
          if (rDoc.exists) {
            var rData = rDoc.data() as Map<String, dynamic>;
            fName = rData['first_name'] ?? 'Unknown';
            lName = rData['last_name'] ?? '';
            phone = rData['phone'] ?? '-';
            if (rData['profile_image'] != null && rData['profile_image'].toString().startsWith('http')) {
              renterImage = rData['profile_image'];
            }
          }
        }

        // 2. วิ่งไปดึงข้อมูลรถ (Vehicle)
        String vehicleId = data['vehicle_id'] ?? '';
        Map<String, dynamic> vData = {
          "id": vehicleId,
          "V Name": "Unknown Vehicle",
          "V_Rate": 0.0,
          "imagePath": "assets/images/car.jpg",
          "V Plate": "-",
          "V Brand": "-",
          "V Model": "-",
          "V Type": "Car",
          "V Fuel": "-",
          "V Address": "-",
          "V Price": 0.0,
        };

        if (vehicleId.isNotEmpty) {
          var vDoc = await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).get();
          if (vDoc.exists) {
            var vd = vDoc.data() as Map<String, dynamic>;
            vData = {
              "id": vehicleId,
              "V Name": vd['vehicle_name'] ?? vd['brand'] ?? 'Unknown',
              "V_Rate": (vd['rating'] ?? 0).toDouble(),
              "imagePath": (vd['images'] != null && (vd['images'] as List).isNotEmpty) ? vd['images'][0] : 'assets/images/car.jpg',
              "V Plate": vd['license_plate'] ?? '-',
              "V Brand": vd['brand'] ?? '-',
              "V Model": vd['model'] ?? '-',
              "V Type": vd['vehicle_type'] ?? 'Car',
              "V Fuel": vd['fuel'] ?? '-',
              "V Address": vd['address'] ?? '-',
              "V Price": (vd['price_per_day'] ?? 0).toDouble(),
            };
          }
        }

        // 3. จัดรูปแบบวันที่
        Timestamp? startTs = data['start_time'];
        Timestamp? endTs = data['end_time'];
        String formatDateTime(Timestamp? ts) {
          if (ts == null) return 'N/A';
          DateTime d = ts.toDate();
          return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
        }

        // นำมาประกอบร่างรวมกัน
        fetchedRequests.add({
          "bookingId": doc.id,
          "renterId": renterId,
          "Request Type": reqType,
          "Rent Status": data['status'],
          "Rent_Start": formatDateTime(startTs),
          "Rent Handin": formatDateTime(endTs),
          "Rent Price": data['total_price'] ?? 0.0,
          "deposit": data['deposit_paid'] ?? 0.0,
          "Acc FName": fName,
          "Acc LName": lName,
          "Acc Phone": phone,
          "Acc Rate": 0.0, 
          "renterImage": renterImage,
          "vehicleData": vData,
          "created_at": data['created_at'],
        });
      }

      // เรียงลำดับคำขอใหม่ล่าสุดอยู่บนสุด
      fetchedRequests.sort((a, b) {
        Timestamp? timeA = a['created_at'] as Timestamp?;
        Timestamp? timeB = b['created_at'] as Timestamp?;
        if (timeA == null) return 1;
        if (timeB == null) return -1;
        return timeB.compareTo(timeA);
      });

      if (mounted) {
        setState(() {
          _requests = fetchedRequests;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int totalReq = _requests.length;
    int rentReq = _requests.where((r) => r['Request Type'] == 'Rent').length;
    int handInReq = _requests.where((r) => r['Request Type'] == 'Hand in').length;

    List<Map<String, dynamic>> filteredRequests = selectedType == 'All'
        ? _requests
        : _requests.where((r) => r['Request Type'] == selectedType).toList();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      
      appBar: AppBar(
        toolbarHeight: 100,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Good Morning,', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.white70)),
            Text('$_ownerFirstName! 👋', style: const TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        centerTitle: false,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', totalReq.toString(), Colors.black87),
                _buildDivider(),
                _buildStatItem('To Rent', rentReq.toString(), const Color(0xFFD39A3D)),
                _buildDivider(),
                _buildStatItem('To Return', handInReq.toString(), const Color.fromRGBO(172, 114, 161, 1.0)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: filterTypes.map((type) {
                bool isSelected = selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => selectedType = type),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color.fromRGBO(7, 14, 42, 1.0) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 15),

          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color.fromRGBO(172, 114, 161, 1.0)))
                : filteredRequests.isEmpty
                    ? const Center(child: Text('No requests found.', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 120),
                        itemCount: filteredRequests.length,
                        itemBuilder: (context, index) {
                          return RequestCard(request: filteredRequests[index]); 
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDivider() => Container(height: 30, width: 1, color: Colors.grey.shade300);
}