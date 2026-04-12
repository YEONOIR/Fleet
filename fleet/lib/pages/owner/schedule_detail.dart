import 'package:flutter/material.dart';
import '../../components/tenant_card.dart';
import '../review_page.dart'; // 💡 อย่าลืมเช็ค path หน้ารีวิวให้ตรงกับของคุณด้วยนะครับ

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
  // 1. วิดเจ็ต: แถบรูปภาพรถ
  // ==========================================
  Widget _buildImageGallery() {
    final List<String> assetImages = [
      'assets/images/car.jpg',
      'assets/images/bike.jpg',
      'assets/images/car2.jpg',
    ];

    return Container(
      height: 200, 
      color: Colors.grey.shade200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(15),
        itemCount: assetImages.length, 
        itemBuilder: (context, index) {
          return Container(
            width: 250, 
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(assetImages[index]), 
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // 2. วิดเจ็ต: ข้อมูลรถ (จัด Layout ใหม่)
  // ==========================================
  Widget _buildVehicleInfo(BuildContext context, Color statusColor, String status) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -- โซนข้อมูลรถ และ ไอคอนพลังงาน (Status) --
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoColumn('License Plate', 'AB 1222'),
                    const SizedBox(height: 20),
                    _buildInfoColumn('Brand', 'Honda'),
                    const SizedBox(height: 20),
                    _buildInfoColumn('Model', 'Civic e:HEV'),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(Icons.electric_car, size: 45, color: Color.fromRGBO(7, 14, 42, 1.0)),
                    const SizedBox(height: 5),
                    const Text('ENERGY', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    const SizedBox(height: 15),
                    _buildStatusBadge(status, statusColor),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // -- โซนประเภทรถ, เรทติ้ง และ คอมเมนต์ (ย้าย Comment ขึ้นมาต่อท้าย Rating) --
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoColumn('Vehicle Type', 'Sedan'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rating', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // ส่วนของ Rating (กดดู Vehicle Reviews)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const FleetEntityReviewPage(
                              isCar: true, 
                              entityName: 'Vehicle Reviews'
                            )
                          ));
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 20),
                            SizedBox(width: 5),
                            Text('4.5', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15), // ระยะห่างระหว่าง Rating กับ Comment
                      // ส่วนของ Comment (กดดู User Reviews)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const FleetEntityReviewPage(
                              isCar: false, 
                              entityName: 'Vehicle Reviews'
                            )
                          ));
                        },
                        child: const Text(
                          'Comment', 
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 13, decoration: TextDecoration.underline, color: Color.fromRGBO(172, 114, 161, 1.0), fontWeight: FontWeight.bold)
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),

          // -- โซนที่อยู่ (Address) --
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Address', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: const Text('111/11, Ander Road, Cromium, Roselina, Bangkok 11111', style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 25),

          // -- โซนมัดจำ และ ราคา --
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoColumn('Deposit (฿)', '1,000'),
              _buildInfoColumn('Price/Hour (฿)', '250'),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // 💡 Helper Widget
  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
      ],
    );
  }

  // 💡 Helper Widget: ป้าย Status
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
                      onPressed: () => _showRejectReasonModal(context, booking),
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
                      onPressed: () => _showAcceptModal(context, booking),
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
            
            _buildVehicleInfo(context, statusColor, status), 
            
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
  // 💡 Modal Functions
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
              Navigator.pop(context); 
              Navigator.pop(context); 
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
              Navigator.pop(context); 
              Navigator.pop(context); 
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Rental accepted successfully!', style: TextStyle(fontFamily: 'Poppins'))));
            },
            child: const Text('Confirm Rent', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}