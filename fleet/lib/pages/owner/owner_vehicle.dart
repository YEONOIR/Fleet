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

  bool _isLoading = true;
  List<Map<String, dynamic>> _myVehicles = [];

  @override
  void initState() {
    super.initState();
    _fetchMyVehicles();
  }

  Future<void> _fetchMyVehicles() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      QuerySnapshot snap = await FirebaseFirestore.instance
          .collection('vehicles')
          .where('owner_id', isEqualTo: user.uid)
          .get();

      List<Map<String, dynamic>> fetched = [];
      for (var doc in snap.docs) {
        var data = doc.data() as Map<String, dynamic>;

        // 💡 ปรับการดึงสถานะให้รองรับตัวพิมพ์เล็ก/ใหญ่จาก Firebase
        String rawStatus = data['status'] ?? 'Available';
        String statusStr = rawStatus.substring(0, 1).toUpperCase() + rawStatus.substring(1).toLowerCase();
        
        Color sColor = const Color(0xFF75DB73); 
        if (statusStr == 'Using') sColor = const Color.fromRGBO(172, 114, 161, 1.0);
        else if (statusStr == 'Pending') sColor = const Color(0xFFD39A3D);
        else if (statusStr == 'Unavailable') sColor = const Color(0xFFF07B75);

        fetched.add({
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
        });
      }

      if (mounted) {
        setState(() {
          _myVehicles = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching owner vehicles: $e");
      if (mounted) setState(() {
        _myVehicles = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalCars = _myVehicles.length;
    int availableCars = _myVehicles.where((v) => v['V Status'] == 'Available').length;
    int usingCars = _myVehicles.where((v) => v['V Status'] == 'Using').length;

    List<Map<String, dynamic>> filteredVehicles = selectedStatus == 'All'
        ? _myVehicles
        : _myVehicles.where((v) => v['V Status'] == selectedStatus).toList();

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
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TakePhotoPage(vehicleName: 'New Vehicle')),
              );
              if (mounted) {
                setState(() => _isLoading = true);
                _fetchMyVehicles();
              }
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 10),
        ],
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
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFAC72A1)))
                : filteredVehicles.isEmpty
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
                            onTap: () async {
                              // 💡 1. เพิ่มการรอรับค่า (await) เมื่อปิดหน้า Detail
                              final bool? shouldRefresh = await Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (context) => VehicleDetailPage(vehicle: v))
                              );
                              
                              // 💡 2. ถ้าได้รับค่า true กลับมา ให้รีเฟรชหน้าจอทันที
                              if (shouldRefresh == true && mounted) {
                                setState(() => _isLoading = true);
                                _fetchMyVehicles();
                              }
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