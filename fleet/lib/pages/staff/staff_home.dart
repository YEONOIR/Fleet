import 'package:flutter/material.dart';
// อย่าลืม import ไฟล์ VehicleInfoCard ของคุณเข้ามาด้วยนะ
import '../../components/vehicle_info_card.dart'; 
// 💡 Import หน้า vehicle_request.dart เข้ามา (ปรับ path ให้ตรงกับโฟลเดอร์ในโปรเจคของคุณนะ)
import 'vehicle_request.dart'; 

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({super.key});

  @override
  State<StaffHomePage> createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  // State ควบคุม Tab
  bool isAddTab = true;

  // Dummy Data (เพิ่ม Key สำหรับส่งไปหน้า VehicleDetailPage ให้ครบถ้วน)
  final List<Map<String, dynamic>> mockRequests = [
    {
      'type': 'Add',
      // Keys สำหรับ VehicleInfoCard
      'name': "Pimthida's Bike",
      'rating': '4.5',
      'plate': 'BB 567',
      'model': 'GRAND FILANO HYBRID',
      'vType': 'Motorcycle',
      'address': '222 JJ village, Loo Road, Llama, Penguin, Bangkok 10120',
      'price': '300',
      'image': 'assets/images/bike.jpg',
      
      // Keys สำหรับ VehicleDetailPage
      'V Name': "Pimthida's Bike",
      'V_Rate': 4.5,
      'V Plate': 'BB 567',
      'V Brand': 'Yamaha',
      'V Model': 'GRAND FILANO HYBRID',
      'V Type': 'Motorcycle',
      'V Fuel': 'Hybrid',
      'V Address': '222 JJ village, Loo Road, Llama, Penguin, Bangkok 10120',
      'V Price': 300,
      'imagePath': 'assets/images/bike.jpg',
    },
    {
      'type': 'Add',
      'name': "Sukrit's Honda",
      'rating': '4.8',
      'plate': 'AB 1222',
      'model': 'Civic e:HEV',
      'vType': '4 Door Car',
      'address': '111/11, Ander Road, Cromium, Bangkok 11111',
      'price': '250',
      'image': 'assets/images/car.jpg',
      
      'V Name': "Sukrit's Honda",
      'V_Rate': 4.8,
      'V Plate': 'AB 1222',
      'V Brand': 'Honda',
      'V Model': 'Civic e:HEV',
      'V Type': '4 Door Car',
      'V Fuel': 'Hybrid',
      'V Address': '111/11, Ander Road, Cromium, Bangkok 11111',
      'V Price': 250,
      'imagePath': 'assets/images/car.jpg',
    },
    {
      'type': 'Delete',
      'name': "Mario's Truck",
      'rating': '3.9',
      'plate': 'ZZ 9999',
      'model': 'Hilux Revo',
      'vType': 'Pickup Truck',
      'address': '55 Moo 5, Chiang Mai, Thailand 50000',
      'price': '500',
      'image': 'assets/images/car2.jpg',

      'V Name': "Mario's Truck",
      'V_Rate': 3.9,
      'V Plate': 'ZZ 9999',
      'V Brand': 'Toyota',
      'V Model': 'Hilux Revo',
      'V Type': 'Pickup Truck',
      'V Fuel': 'Diesel',
      'V Address': '55 Moo 5, Chiang Mai, Thailand 50000',
      'V Price': 500,
      'imagePath': 'assets/images/car2.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    int totalAll = mockRequests.length;
    int totalAdd = mockRequests.where((req) => req['type'] == 'Add').length;
    int totalDelete = mockRequests.where((req) => req['type'] == 'Delete').length;

    List<Map<String, dynamic>> displayList = mockRequests
        .where((req) => req['type'] == (isAddTab ? 'Add' : 'Delete'))
        .toList();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      
      // ==========================================
      // 1. AppBar 
      // ==========================================
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
          // ==========================================
          // 2. Dashboard
          // ==========================================
          Container(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
              ],
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

          // ==========================================
          // 3. Segmented Tab Toggle
          // ==========================================
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

          // ==========================================
          // 4. List View 
          // ==========================================
          Expanded(
            child: displayList.isEmpty
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
                        // 💡 เปลี่ยนมาส่ง onTap เข้าไปในการ์ดโดยตรง
                        child: VehicleInfoCard(
                          data: displayList[index],
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // หน้า staff จะส่งไปที่ VehicleRequestPage
                                builder: (context) => VehicleRequestPage(vehicle: displayList[index]),
                              ),
                            );
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

  // ==========================================
  // Helper Widgets
  // ==========================================
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