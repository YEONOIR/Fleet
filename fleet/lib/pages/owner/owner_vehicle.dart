import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; 

import '../../components/vehicle_card.dart';
import 'vehicle_detail.dart';
import '../take_photo.dart';

class OwnerVehiclePage extends StatefulWidget {
  const OwnerVehiclePage({super.key});

  @override
  State<OwnerVehiclePage> createState() => _OwnerVehiclePageState();
}

class _OwnerVehiclePageState extends State<OwnerVehiclePage> {
  String selectedStatus = 'All';
  final List<String> statusTypes = [
    'All',
    'Available',
    'Using',
    'Pending',
    'Unavailable',
  ];

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      appBar: AppBar(
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
        title: const Text('Smart Garage', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              // 💡 ไม่ต้องใช้ await หรือ setState แล้ว StreamBuilder จะจัดการให้เอง
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TakePhotoPage(vehicleName: 'New Vehicle')),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 10),
        ],
      ),
      // 💡 เปลี่ยนมาใช้ StreamBuilder เพื่อให้ข้อมูลอัปเดตอัตโนมัติ (Real-time)
      body: user == null 
        ? const Center(child: Text("Please login to see your vehicles", style: TextStyle(fontFamily: 'Poppins')))
        : StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('vehicles')
                .where('owner_id', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFAC72A1)));
              }

              if (snapshot.hasError) {
                return const Center(child: Text("Something went wrong", style: TextStyle(fontFamily: 'Poppins')));
              }

              // นำข้อมูลจาก Firestore มาแปลงให้อยู่ในรูปแบบ List ที่เราใช้งาน
              List<Map<String, dynamic>> myVehicles = snapshot.data!.docs.map((doc) {
                var data = doc.data() as Map<String, dynamic>;

                String rawStatus = data['status'] ?? 'Available';
                String statusStr = rawStatus.substring(0, 1).toUpperCase() + rawStatus.substring(1).toLowerCase();
                
                Color sColor = const Color(0xFF75DB73); 
                if (statusStr == 'Using') sColor = const Color.fromRGBO(172, 114, 161, 1.0);
                else if (statusStr == 'Pending') sColor = const Color(0xFFD39A3D);
                else if (statusStr == 'Unavailable') sColor = const Color(0xFFF07B75);

                return {
                  "id": doc.id,
                  "V Name": data['vehicle_name'] ?? "Unknown Vehicle", 
                  "V Plate": data['license_plate'] ?? '-',
                  "V Brand": data['brand'] ?? '-',
                  "V Model": data['model'] ?? '-',
                  "V Type": data['vehicle_type'] ?? 'Car',
                  "V Fuel": data['fuel'] ?? 'N/A',
                  "V Address": data['address'] ?? 'No address', 
                  "V Price": (data['price_per_day'] ?? 0).toDouble(),
                  "V Deposit": (data['deposit'] ?? 0).toDouble(),
                  "V Status": statusStr,
                  "V_Rate": (data['rating'] ?? 0).toDouble(),
                  "imagePath": (data['images'] != null && (data['images'] as List).isNotEmpty) ? data['images'][0] : 'assets/images/car.jpg',
                  "images": data['images'] ?? [], 
                  "statusColor": sColor,
                  "renterData": null, 
                };
              }).toList();

              // คำนวณตัวเลขสถิติต่างๆ
              int totalCars = myVehicles.length;
              int availableCars = myVehicles.where((v) => v['V Status'] == 'Available').length;
              int usingCars = myVehicles.where((v) => v['V Status'] == 'Using').length;

              // กรองข้อมูลตาม Status ที่เลือก
              List<Map<String, dynamic>> filteredVehicles = selectedStatus == 'All'
                  ? myVehicles
                  : myVehicles.where((v) => v['V Status'] == selectedStatus).toList();

              return Column(
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
                        _buildStatItem('Total', totalCars.toString(), Colors.black87),
                        _buildDivider(),
                        _buildStatItem('Available', availableCars.toString(), const Color(0xFF75DB73)),
                        _buildDivider(),
                        _buildStatItem('Using', usingCars.toString(), const Color.fromRGBO(172, 114, 161, 1.0)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: statusTypes.map((status) {
                        bool isSelected = selectedStatus == status;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedStatus = status;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color.fromRGBO(7, 14, 42, 1.0) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: isSelected ? Colors.transparent : Colors.grey.shade300),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
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
                    child: filteredVehicles.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey.withOpacity(0.3)),
                                const SizedBox(height: 12),
                                Text('No vehicles found in your garage.', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey.withOpacity(0.8))),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 120),
                            itemCount: filteredVehicles.length,
                            itemBuilder: (context, index) {
                              final v = filteredVehicles[index];
                              return GestureDetector(
                                onTap: () {
                                  // 💡 ไม่ต้องใช้ await เพื่อรอค่ากลับมาแล้ว StreamBuilder จะอัปเดตให้เองถ้ามีการเปลี่ยนแปลง
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(builder: (context) => VehicleDetailPage(vehicle: v))
                                  );
                                },
                                onLongPress: () {
                                  _showVehicleOptionsModal(context, v['V Name']);
                                },
                                child: VehicleCard(
                                  vName: v["V Name"],
                                  vRate: v["V_Rate"],
                                  imagePath: v["imagePath"],
                                  vPlate: v["V Plate"],
                                  vBrand: v["V Brand"],
                                  vModel: v["V Model"],
                                  vType: v["V Type"],
                                  vFuel: v["V Fuel"],
                                  vAddress: v["V Address"],
                                  vPrice: v["V Price"],
                                  vDeposit: v["V Deposit"],
                                  vStatus: v["V Status"],
                                  statusColor: v["statusColor"],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
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

  void _showVehicleOptionsModal(BuildContext context, String vehicleName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Manage $vehicleName', style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red), 
              title: const Text('Delete Vehicle', style: TextStyle(color: Colors.red)), 
              onTap: () => Navigator.pop(context)
            ),
          ],
        ),
      ),
    );
  }
}