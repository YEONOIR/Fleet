import 'package:flutter/material.dart';
import '../../components/request_card.dart'; // 💡 ดึง Component ใหม่เข้ามา

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  String selectedType = 'All';
  final List<String> filterTypes = ['All', 'Rent', 'Hand in'];

  final List<Map<String, dynamic>> dummyRequests = [
    {
      "Request Type": "Rent",
      "Rent Status": "Pending",
      "Rent_Start": "08-02-2026 12:00",
      "Rent Handin": "12-02-2026 14:00",
      "Rent Price": 750.0,
      "Acc FName": "Sukrit",
      "Acc LName": "Chatchawal",
      "Acc Phone": "0848978975",
      "Acc Rate": 3.0,
      "renterImage": "assets/icons/avatar.jpg", // รูป Mockup ผู้เช่า
      "vehicleData": {
        "V Name": "Pimthida's Bike",
        "V_Rate": 4.5,
        "imagePath": "assets/images/bike.jpg", // รูป Mockup รถ
        "V Plate": "BB 567",
        "V Brand": "Yamaha",
        "V Model": "GRAND FILANO HYBRID",
        "V Type": "Motorcycle",
        "V Fuel": "Hybrid",
        "V Address": "222 JJ village, Bangkok 10120",
        "V Price": 300.0,
      },
    },
    {
      "Request Type": "Hand in",
      "Rent Status": "Using",
      "Rent_Start": "01-02-2026 10:00",
      "Rent Handin": "05-02-2026 10:00",
      "Rent Price": 1000.0,
      "Acc FName": "Pimthida",
      "Acc LName": "Butsra",
      "Acc Phone": "0812345678",
      "Acc Rate": 3.7,
      "renterImage": "assets/icons/avatar.jpg", // รูป Mockup ผู้เช่า
      "vehicleData": {
        "V Name": "Sukrit's Honda",
        "V_Rate": 4.5,
        "imagePath": "assets/images/car.jpg", // รูป Mockup รถ
        "V Plate": "AB 1222",
        "V Brand": "Honda",
        "V Model": "Civic e:HEV",
        "V Type": "4 Door Car",
        "V Fuel": "Hybrid",
        "V Address": "111/11, Ander Road, Bangkok 11111",
        "V Price": 250.0,
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    int totalReq = dummyRequests.length;
    int rentReq = dummyRequests.where((r) => r['Request Type'] == 'Rent').length;
    int handInReq = dummyRequests.where((r) => r['Request Type'] == 'Hand in').length;

    List<Map<String, dynamic>> filteredRequests = selectedType == 'All'
        ? dummyRequests
        : dummyRequests.where((r) => r['Request Type'] == selectedType).toList();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      
      // 1. AppBar
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good Morning,', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.white70)),
            Text('Sukrit! 👋', style: TextStyle(fontFamily: 'Poppins', fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        centerTitle: false,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2. Dashboard
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

          // 3. Filter Chips
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

          // 4. Request List
          Expanded(
            child: filteredRequests.isEmpty
                ? const Center(child: Text('No requests found.', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 120),
                    itemCount: filteredRequests.length,
                    itemBuilder: (context, index) {
                      // 💡 เรียกใช้ Component ที่เราเพิ่งสร้าง
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