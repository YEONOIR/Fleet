import 'package:flutter/material.dart';
import '../../components/tenant_card.dart';

class ScheduleDetailPage extends StatelessWidget {
  final Map<String, dynamic> booking;

  const ScheduleDetailPage({super.key, required this.booking});

  // ฟังก์ชันดึงสีสถานะ
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Accept': return const Color(0xFF2E8B57); 
      case 'Complete': return const Color(0xFF28A4C9); 
      case 'Cancel': return const Color(0xFFA52A2A); 
      case 'Pending': return Colors.orange; 
      case 'Using': return const Color.fromRGBO(172, 114, 161, 1.0); 
      default: return Colors.black;
    }
  }

  // ==========================================
  // 💡 1. วิดเจ็ต: แถบรูปภาพรถ (เปลี่ยนมาใช้รูป Assets ของคุณ)
  // ==========================================
  Widget _buildImageGallery() {
    // 💡 ลิสต์รายชื่อรูปภาพในโฟลเดอร์ assets ของคุณ
    final List<String> assetImages = [
      'assets/images/car.jpg',
      'assets/images/bike.jpg',
      'assets/images/car2.jpg',
    ];

    return Container(
      height: 120,
      color: Colors.grey.shade200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(15),
        itemCount: assetImages.length, // จำนวนรูปตามลิสต์
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(assetImages[index]), // 💡 ใช้ AssetImage ดึงรูปจากในเครื่อง
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // 2. วิดเจ็ต: ข้อมูลรถ (จัดแบบ Grid)
  // ==========================================
  Widget _buildVehicleInfo(Color statusColor, String status) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildInfoRow('License Plate', 'AB 1222'),
                    _buildInfoRow('Model', 'Civic e:HEV'),
                    _buildInfoRow('Vehicle Type', 'Sedan'),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildInfoRow('Brand', 'Honda'),
                    const SizedBox(height: 10),
                    // ไอคอน EV และป้าย Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Icon(Icons.electric_car, size: 35, color: Color.fromRGBO(7, 14, 42, 1.0)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
                          child: Text(status, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Text('Address', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
            child: const Text('111/11, Ander Road, Cromium, Roselina, Bangkok 11111', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87)),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(child: _buildInfoRow('Deposit (฿)', '1,000')),
              Expanded(child: _buildInfoRow('Price per hour (฿)', '250')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Rating ', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey)),
                  const Icon(Icons.star, color: Color(0xFFFFD700), size: 18),
                  const Text(' 4.5', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                ],
              ),
              const Text('Comment', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, decoration: TextDecoration.underline, color: Color.fromRGBO(172, 114, 161, 1.0), fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: Text(title, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey))),
          Expanded(flex: 1, child: Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  // ==========================================
  // 3. วิดเจ็ต: แสดงส่วนล่างสุดแยกตาม Status
  // ==========================================
  Widget _buildDynamicBottomSection(BuildContext context, String status) {
    switch (status) {
      case 'Pending':
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('Review this rental request.', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(color: Colors.redAccent, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showRejectReasonModal(context, booking), // 💡 เรียก Modal ปฏิเสธ
                      child: const Text('Decline', style: TextStyle(fontFamily: 'Poppins', color: Colors.redAccent, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: const Color(0xFF2E8B57),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showAcceptModal(context, booking), // 💡 เรียก Modal ยอมรับ
                      child: const Text('Accept', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 'Complete':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Price paid', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('฿ 9,999', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, color: Color.fromRGBO(172, 114, 161, 1.0), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Pictures upon return', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildImageGallery(),
              const SizedBox(height: 20),
              const Text('Defect', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              // 💡 กล่องข้อความ Defect (สไตล์เดียวกับ Address)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Text(booking['remark'] ?? '-', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );

      // 💡 แยก case 'Using' ออกมา เพื่อใส่ปุ่มกล้อง!
      case 'Using':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Price', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold)),
                  Text('฿ 12,000', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, color: Color.fromRGBO(172, 114, 161, 1.0), fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Pictures before rent', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildImageGallery(), 
            ],
          ),
        );

      case 'Cancel':
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reason for cancellation', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent)),
              const SizedBox(height: 5),
              // 💡 กล่องข้อความ Cancel Reason (สไตล์เดียวกับ Address)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: Text(booking['remark'] ?? '-', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87)),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );

      case 'Accept':
      default:
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Price', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold)),
              Text('฿ 7,000', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, color: Color.fromRGBO(172, 114, 161, 1.0), fontWeight: FontWeight.bold)),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    String status = booking['status'] ?? 'Pending';
    Color statusColor = _getStatusColor(status);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Sukrit's Honda", style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageGallery(),
            _buildVehicleInfo(statusColor, status),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TenantCard(booking: booking), 
            ),

            _buildDynamicBottomSection(context, status),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
  // ==========================================
  // 💡 Modal Functions (ย้ายมาจากหน้า RequestCard)
  // ==========================================
  void _showRejectReasonModal(BuildContext context, Map<String, dynamic> booking) {
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Request', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Color.fromRGBO(7, 14, 42, 1.0))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please state the reason for declining this request:', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
            const SizedBox(height: 15),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'e.g., The car is currently unavailable...',
                hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Color.fromRGBO(172, 114, 161, 1.0)), borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF07B75), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context);
              _showConfirmRejectModal(context, reasonController.text, booking['renterName']);
            },
            child: const Text('Next', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showConfirmRejectModal(BuildContext context, String reason, String renterName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Rejection', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Color.fromRGBO(7, 14, 42, 1.0))),
        content: Text('Are you sure you want to decline $renterName\'s request?\n\nYour Reason:\n"$reason"', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(42, 35, 66, 1.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context); // ปิด Modal
              Navigator.pop(context); // ปิดหน้า Detail กลับไปหน้าแรก
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rejection sent to the renter.', style: TextStyle(fontFamily: 'Poppins'))));
            },
            child: const Text('Send to Renter', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showAcceptModal(BuildContext context, Map<String, dynamic> booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Accept Request', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Color.fromRGBO(7, 14, 42, 1.0))),
        content: Text('Do you confirm to rent to ${booking['renterName']}?', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF75DB73), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: () {
              Navigator.pop(context); // ปิด Modal
              Navigator.pop(context); // ปิดหน้า Detail กลับไปหน้าแรก
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rental accepted successfully!', style: TextStyle(fontFamily: 'Poppins'))));
            },
            child: const Text('Confirm Rent', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}