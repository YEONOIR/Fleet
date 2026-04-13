import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 เพิ่ม Firestore
import '../../components/vehicle_info_card.dart'; 
import 'vehicle_request.dart'; 

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  bool isAddTab = true;

  // 💡 State สำหรับเก็บข้อมูลจริง และสถานะการโหลด
  bool _isLoading = true;
  List<Map<String, dynamic>> _pendingRequests = [];

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  // ==========================================
  // 💡 ฟังก์ชันดึงคำขอร้อง (Pending) ทั้งหมดจาก Firebase
  // ==========================================
  Future<void> _fetchPendingRequests() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('status', isEqualTo: 'pending') // ดึงเฉพาะรถที่มีสถานะ pending
          .get();

      List<Map<String, dynamic>> fetchedRequests = [];
      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        
        // ถ้าไม่มีระบุ pending_type ถือว่าเป็นคำขอแบบ Add 
        String pType = data['pending_type'] ?? 'Add';

        fetchedRequests.add({
          'id': doc.id, // เก็บ Document ID เพื่อให้หน้าถัดไปเอาไป อนุมัติ/ปฏิเสธ ได้
          'type': pType, 
          
          // ข้อมูลสำหรับ VehicleInfoCard
          'name': data['vehicle_name'] ?? 'Unknown',
          'rating': (data['rating'] ?? 0.0).toStringAsFixed(1),
          'plate': data['license_plate'] ?? '-',
          'model': data['model'] ?? '-',
          'vType': data['vehicle_type'] ?? 'Car',
          'address': data['address'] ?? '-',
          'price': (data['price_per_day'] ?? 0).toString(),
          'image': (data['images'] != null && (data['images'] as List).isNotEmpty) ? data['images'][0] : 'assets/images/car.jpg',
          
          // ข้อมูลเต็มสำหรับ VehicleDetailPage (ที่ส่งต่อไปให้ VehicleRequestPage)
          'V Name': data['vehicle_name'] ?? 'Unknown',
          'V_Rate': (data['rating'] ?? 0.0).toDouble(),
          'V Plate': data['license_plate'] ?? '-',
          'V Brand': data['brand'] ?? '-',
          'V Model': data['model'] ?? '-',
          'V Type': data['vehicle_type'] ?? 'Car',
          'V Fuel': data['fuel'] ?? '-',
          'V Address': data['address'] ?? '-',
          'V Price': (data['price_per_day'] ?? 0).toDouble(),
          'imagePath': (data['images'] != null && (data['images'] as List).isNotEmpty) ? data['images'][0] : 'assets/images/car.jpg',
          'images': data['images'] ?? [], // ส่งรูปรวมไปด้วย
        });
      }

      if (mounted) {
        setState(() {
          _pendingRequests = fetchedRequests;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching requests: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalAll = _pendingRequests.length;
    int totalAdd = _pendingRequests.where((req) => req['type'] == 'Add').length;
    int totalDelete = _pendingRequests.where((req) => req['type'] == 'Delete').length;

    List<Map<String, dynamic>> displayList = _pendingRequests
        .where((req) => req['type'] == (isAddTab ? 'Add' : 'Delete'))
        .toList();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      
      appBar: AppBar(
        toolbarHeight: 90,
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
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back,', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.white70)),
              Text('Admin Dashboard', style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dashboard
          Container(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', totalAll.toString(), Colors.black87),
                _buildDivider(),
                _buildStatItem('Add', totalAdd.toString(), const Color(0xFF4CA0E6)),
                _buildDivider(),
                _buildStatItem('Delete', totalDelete.toString(), const Color(0xFFE57373)),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // Segmented Tab Toggle
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 15),
              width: 300,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.grey.shade300), 
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    alignment: isAddTab ? Alignment.centerLeft : Alignment.centerRight,
                    child: Container(
                      width: 150,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(7, 14, 42, 1.0),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isAddTab = true),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Text('Add Request', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: isAddTab ? FontWeight.bold : FontWeight.w500, color: isAddTab ? Colors.white : Colors.grey.shade600)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isAddTab = false),
                          behavior: HitTestBehavior.opaque,
                          child: Center(
                            child: Text('Delete Request', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: !isAddTab ? FontWeight.bold : FontWeight.w500, color: !isAddTab ? Colors.white : Colors.grey.shade600)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // List View 
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color.fromRGBO(172, 114, 161, 1.0)))
                : displayList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 50, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            Text('No requests found.', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade500)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        physics: const BouncingScrollPhysics(),
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: VehicleInfoCard(
                              data: displayList[index],
                              onTap: () async {
                                // 💡 รอให้ Staff กดจัดการในหน้าถัดไปให้เสร็จ แล้วค่อยมารีเฟรชหน้านี้ใหม่
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VehicleRequestPage(vehicle: displayList[index]),
                                  ),
                                );
                                // สั่งโหลดข้อมูลใหม่เมื่อกลับมา
                                if (mounted) {
                                  setState(() => _isLoading = true);
                                  _fetchPendingRequests(); 
                                }
                              },
                            ),
                          );
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
        Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildDivider() => Container(height: 35, width: 1.5, color: Colors.grey.shade200);
}