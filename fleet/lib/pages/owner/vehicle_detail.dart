import 'package:flutter/material.dart';
import '../../components/renter_info_card.dart';
import '../../utils/vehicle_utils.dart';
import '../review_page.dart';

class VehicleDetailPage extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleDetailPage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    // ดึงสถานะมาเก็บไว้ในตัวแปรเพื่อให้เช็คง่ายๆ
    final String status = vehicle['V Status'].toString().toLowerCase();
    
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
        title: Text(vehicle['V Name'], style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              // 💡 เรียกใช้ฟังก์ชันโชว์ Modal ยืนยันการลบ
              _showDeleteConfirmation(context);
            },
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 28),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Image Gallery (Horizontal Scroll)
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(15),
                      itemCount: 3,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Image.asset(vehicle['imagePath'], fit: BoxFit.cover, width: 250),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // 2. Info & Status Section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoColumn('License Plate', vehicle['V Plate']),
                                  const SizedBox(height: 20),
                                  _buildInfoColumn('Brand', vehicle['V Brand']),
                                  const SizedBox(height: 20),
                                  _buildInfoColumn('Model', vehicle['V Model']),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(
                                    getFuelIcon(vehicle['V Fuel']), 
                                    size: 45, 
                                    color: const Color.fromRGBO(7, 14, 42, 1.0)
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    vehicle['V Fuel'].toString().toUpperCase() == 'EV' 
                                        ? 'ENERGY' 
                                        : vehicle['V Fuel'].toString(),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins', 
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.blueGrey
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  _buildStatusBadge(vehicle['V Status'], vehicle['statusColor']),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // -- โซนประเภทรถ, เรทติ้ง และ คอมเมนต์ (เอา Rating/Comment ขึ้นมาแทน) --
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoColumn('Vehicle Type', vehicle['V Type']),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Rating', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 5),
                                    Text(vehicle['V_Rate'].toString(), style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 15), // ระยะห่างระหว่างเรทติ้งกับปุ่ม Comment
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => const FleetEntityReviewPage(
                                            isCar: true, 
                                            entityName: 'Vehicle Reviews'
                                          )
                                        ));
                                      },
                                      child: const Text(
                                        'Comment', 
                                        style: TextStyle(
                                          fontFamily: 'Poppins', 
                                          fontSize: 13, 
                                          decoration: TextDecoration.underline, 
                                          color: Color.fromRGBO(172, 114, 161, 1.0), // สีม่วงเดียวกับ Schedule Detail
                                          fontWeight: FontWeight.bold
                                        )
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // 3. Address Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Address', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: Text(vehicle['V Address'], style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // 4. Pricing & Deposit (สลับ Deposit ลงมาคู่กับ Price/Hour)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn('Deposit (฿)', vehicle['V Deposit'].toString()),
                            _buildInfoColumn('Price/Hour (฿)', vehicle['V Price'].toString()),
                          ],
                        ),
                        const SizedBox(height: 10),
                        
                        // 5. ส่วนแสดงข้อมูลเพิ่มเติมสำหรับสถานะ PENDING
                        if (status == 'pending') _buildPendingInfo(),

                        // 6. ส่วนแสดงข้อมูลผู้เช่าและรูปภาพสำหรับสถานะ USING เท่านั้น
                        if (status == 'using') _buildUsingInfo(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 7. ส่วนแสดงปุ่ม Action ตามสถานะ (AVAILABLE / UNAVAILABLE)
          if (status == 'available' || status == 'unavailable')
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildActionButton(status),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // 💡 Widget สำหรับสถานะ USING (ข้อมูลผู้เช่า + รูป Before Rent)
  // ==========================================
  Widget _buildUsingInfo(BuildContext context) {
    final renter = vehicle['renterData'];

    if (renter == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        
        RenterInfoCard(
          name: renter['name'],
          phone: renter['phone'],
          rating: renter['rating'],
          startDate: renter['startDate'],
          endDate: renter['endDate'],
          startTime: renter['startTime'],
          endTime: renter['endTime'],
          renterImage: renter['renterImage'],
        ),

        const SizedBox(height: 25),
        // 2. ส่วนของ Total Price (รูปแบบเดียวกับ ScheduleDetailPage)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Price', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold)),
            Text(
              '฿ ${renter['totalPrice']}', 
              style: const TextStyle(
                fontFamily: 'Poppins', 
                fontSize: 18, 
                color: Color.fromRGBO(172, 114, 161, 1.0), // สีม่วง
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),

        // 3. ส่วนของ Pictures before rent (รูปแบบเดียวกับ ScheduleDetailPage)
        const Text('Pictures before rent', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        Container(
          height: 200, 
          color: Colors.grey.shade200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(15),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                width: 250, 
                margin: const EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(vehicle['imagePath']), // ดึงจาก path ที่คุณมี
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Widget สำหรับสถานะ Pending
  Widget _buildPendingInfo() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Icon(Icons.hourglass_empty_rounded, size: 50, color: Color(0xFFD39A3D)),
          SizedBox(height: 15),
          Text(
            'Staff is currently considering your request\nplease wait for 2 - 3 days for confirmation',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // Widget สำหรับสร้างปุ่มด้านล่าง
  Widget _buildActionButton(String status) {
    bool isAvailable = status == 'available';
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isAvailable ? const Color(0xFFF07B75) : const Color(0xFF75DB73),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () {},
        child: Text(
          isAvailable ? 'Set as unavailable' : 'Set as available',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  // Helper สำหรับสร้างคอลัมน์ข้อมูล
  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // Helper สำหรับสร้างป้ายสถานะ
  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 4, backgroundColor: Colors.white),
          const SizedBox(width: 8),
          Text(status, style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ==========================================
  // 💡 Modal ยืนยันการลบรถ (Delete Confirmation)
  // ==========================================
  void _showDeleteConfirmation(BuildContext context) {
    String vehicleName = vehicle['V Name'] ?? 'this vehicle'; 

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
            const SizedBox(width: 10),
            const Text('Delete Vehicle', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.redAccent)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "$vehicleName"?\nThis action cannot be undone.', 
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () {
              Navigator.pop(context); 
              Navigator.pop(context); 
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Vehicle "$vehicleName" has been deleted.', style: const TextStyle(fontFamily: 'Poppins')),
                  backgroundColor: Colors.black87,
                )
              );
            },
            child: const Text('Delete', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}