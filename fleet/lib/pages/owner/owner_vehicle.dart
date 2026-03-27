import 'package:flutter/material.dart';
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

  // ==========================================
  // 💡 Dummy Data ชุดสมบูรณ์ (รองรับ Logic พลังงานและสถานะ Using)
  // ==========================================
  final List<Map<String, dynamic>> dummyVehicles = [
    {
      "V Name": "Sukrit's Honda",
      "V Plate": "AB 1222",
      "V Brand": "Honda",
      "V Model": "Civic e:HEV",
      "V Type": "4 Door Car",
      "V Fuel": "Sohol 95", // ⛽ น้ำมัน -> จะแสดงไอคอนปั๊มน้ำมัน + "Sohol 95"
      "V Address": "111/11, Ander Road, Cromium, Roselina, Bangkok 11111",
      "V Price": 250.0,
      "V Deposit": 5000.0,
      "V Status": "Using", // 🟣 กำลังใช้งาน
      "V_Rate": 4.5,
      "imagePath": "assets/images/car.jpg",
      "statusColor": const Color.fromRGBO(172, 114, 161, 1.0),
      "renterData": {
        "name": "Pimthida Butsra",
        "phone": "0848978975",
        "rating": 3.7,
        "startDate": "08/02/2026",
        "endDate": "12/02/2026",
        "startTime": "12:00",
        "endTime": "14:00",
        "renterImage": "assets/icons/avatar.jpg",
        "totalPrice": "12,000",
      },
    },
    {
      "V Name": "Pimthida's EV",
      "V Plate": "EV 8888",
      "V Brand": "Tesla",
      "V Model": "Model 3",
      "V Type": "4 Door Car",
      "V Fuel": "EV", // ⚡ ไฟฟ้า -> จะแสดงไอคอนสายชาร์จ + "ENERGY"
      "V Address": "222 JJ village, Bangkok 10120",
      "V Price": 500.0,
      "V Deposit": 10000.0,
      "V Status": "Available", // 🟢 ว่าง
      "V_Rate": 4.9,
      "imagePath": "assets/images/car.jpg",
      "statusColor": const Color(0xFF75DB73),
      "renterData": null,
    },
    {
      "V Name": "LPG Delivery Van",
      "V Plate": "ถน 555",
      "V Brand": "Toyota",
      "V Model": "Commuter",
      "V Type": "Van",
      "V Fuel": "LPG", // 💨 ก๊าซ -> จะแสดงไอคอนเครื่องวัดก๊าซ + "LPG"
      "V Address": "55/9 Sukhumvit, Bangkok",
      "V Price": 400.0,
      "V Deposit": 3000.0,
      "V Status": "Pending", // 🟠 รอตรวจสอบ
      "V_Rate": 4.0,
      "imagePath": "assets/images/car.jpg",
      "statusColor": const Color(0xFFD39A3D),
      "renterData": null,
    },
    {
      "V Name": "Pimthida's Scooter",
      "V Plate": "กทม 987",
      "V Brand": "Vespa",
      "V Model": "Sprint 150",
      "V Type": "Motorcycle",
      "V Fuel": "Sohol 91", // ⛽ น้ำมัน
      "V Address": "222 JJ village, Bangkok 10120",
      "V Price": 200.0,
      "V Deposit": 500.0,
      "V Status": "Unavailable", // 🔴 ปิดการเช่า
      "V_Rate": 4.2,
      "imagePath": "assets/images/bike.jpg",
      "statusColor": const Color(0xFFF07B75),
      "renterData": null,
    },
  ];
  @override
  Widget build(BuildContext context) {
    int totalCars = dummyVehicles.length;
    int availableCars = dummyVehicles
        .where((v) => v['V Status'] == 'Available')
        .length;
    int usingCars = dummyVehicles.where((v) => v['V Status'] == 'Using').length;

    List<Map<String, dynamic>> filteredVehicles = selectedStatus == 'All'
        ? dummyVehicles
        : dummyVehicles.where((v) => v['V Status'] == selectedStatus).toList();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),

      // ==========================================
      // 💡 1. App Bar พร้อมปุ่มบวกทางขวา
      // ==========================================
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(172, 114, 161, 1.0),
                Color.fromRGBO(7, 14, 42, 1.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          'Smart Garage',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        // 💡 ย้ายปุ่มเพิ่มรถมาไว้ตรงนี้ครับ
        actions: [
          IconButton(
            onPressed: () {
              // 💡 เปลี่ยนให้พาไปหน้า TakePhotoPage แทน
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TakePhotoPage(vehicleName: 'New Vehicle'),
                ),
              );
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 10),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 💡 2. Garage Dashboard
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', totalCars.toString(), Colors.black87),
                _buildDivider(),
                _buildStatItem(
                  'Available',
                  availableCars.toString(),
                  const Color(0xFF75DB73),
                ),
                _buildDivider(),
                _buildStatItem(
                  'Using',
                  usingCars.toString(),
                  const Color.fromRGBO(172, 114, 161, 1.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 💡 3. Filter Chips
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color.fromRGBO(7, 14, 42, 1.0)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.white : Colors.grey.shade600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 15),

          // 💡 4. Vehicle List (ใส่ onTap ตรงนี้)
          Expanded(
            child: filteredVehicles.isEmpty
                ? const Center(
                    child: Text(
                      'No vehicles found.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 10,
                      left: 20,
                      right: 20,
                      bottom: 120,
                    ),
                    itemCount: filteredVehicles.length,
                    itemBuilder: (context, index) {
                      final v = filteredVehicles[index];

                      return GestureDetector(
                        // 💡 1. แตะปกติเพื่อไปหน้า Detail
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VehicleDetailPage(vehicle: v),
                            ),
                          );
                        },
                        // 💡 2. กดค้างเพื่อจัดการ Edit/Delete
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
      // 💡 เอาปุ่ม FAB เดิมออกไปแล้วนะครับ เพราะย้ายขึ้นข้างบนแล้ว
    );
  }

  // ==========================================
  // Modal สำหรับจัดการรถ (เมื่อกดค้างที่การ์ด)
  // ==========================================
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() =>
      Container(height: 30, width: 1, color: Colors.grey.shade300);

  void _showVehicleOptionsModal(BuildContext context, String vehicleName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Manage $vehicleName',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Details'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text(
                'Delete Vehicle',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
