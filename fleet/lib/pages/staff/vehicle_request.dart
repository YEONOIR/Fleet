import 'package:flutter/material.dart';
import '../../utils/vehicle_utils.dart'; // 💡 อย่าลืมเช็ค path utils ของคุณ
// 💡 Import หน้า Take Photo เข้ามา (แก้ path และชื่อคลาสให้ตรงกับของคุณนะ)
import '../take_photo.dart';

class VehicleRequestPage extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleRequestPage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    // เช็คประเภทของคำขอ (Add หรือ Delete)
    final String requestType = vehicle['type'] ?? 'Add';

    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),

      // ==========================================
      // 1. AppBar
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
          'Request Details',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          // ==========================================
          // 2. ส่วนเนื้อหา (เลื่อนได้)
          // ==========================================
          Expanded(
            // 💡 หุ้มด้วย Expanded เสมอเพื่อให้ใช้พื้นที่ที่เหลือทั้งหมด
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Gallery
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
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            vehicle['imagePath'] ?? 'assets/images/car.jpg',
                            fit: BoxFit.cover,
                            width: 250,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Info Section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoColumn(
                                    'License Plate',
                                    vehicle['V Plate'] ?? '-',
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInfoColumn(
                                    'Brand',
                                    vehicle['V Brand'] ?? '-',
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInfoColumn(
                                    'Model',
                                    vehicle['V Model'] ?? '-',
                                  ),
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
                                    color: const Color.fromRGBO(7, 14, 42, 1.0),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    vehicle['V Fuel']
                                                .toString()
                                                .toUpperCase() ==
                                            'EV'
                                        ? 'ENERGY'
                                        : (vehicle['V Fuel'] ?? 'FUEL')
                                              .toString()
                                              .toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn(
                              'Vehicle Type',
                              vehicle['V Type'] ?? '-',
                            ),
                            _buildInfoColumn(
                              'Deposit (฿)',
                              (vehicle['V Deposit'] ?? 0).toString(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // Address Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Address',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                vehicle['V Address'] ?? '-',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // Pricing & Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn(
                              'Price/Hour (฿)',
                              (vehicle['V Price'] ?? 0).toString(),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Rating',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      (vehicle['V_Rate'] ?? 0.0).toString(),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Comment Link
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Comment',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              decoration: TextDecoration.underline,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // 3. แถบปุ่ม Action ด้านล่างสุด
          // ==========================================
          SafeArea(
            // 💡 หุ้มด้วย SafeArea เพื่อป้องกันขอบจอด้านล่าง (เช่น เส้น Home ของ iPhone)
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // 🔴 ปุ่ม Reject
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.red.shade400,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        _showRejectReasonModal(context);
                      },
                      child: Text(
                        'Reject',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.red.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  // 🔵 ปุ่ม Approve
                  // 🔵 ปุ่ม Approve
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CA0E6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (requestType == 'Delete') {
                          _showConfirmApproveDeleteModal(
                            context,
                            vehicle['V Name'] ?? 'this vehicle',
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TakePhotoPage(
                                vehicleName: vehicle['V Name'] ?? 'New Vehicle',
                                isStaff: true, // 💡 เพิ่มบรรทัดนี้เข้าไปครับ!
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Approve',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Helper: Widget สำหรับสร้างคอลัมน์ข้อมูล
  // ==========================================
  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 💡 Modal 1: กรอกเหตุผลที่ Reject
  // ==========================================
  void _showRejectReasonModal(BuildContext context) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Reject Request',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          // 💡 หุ้ม content ด้วย SingleChildScrollView เพื่อไม่ให้พังตอนคีย์บอร์ดเด้งขึ้นมา
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please provide a reason for rejection:',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter reason here...',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Reason cannot be empty',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                      backgroundColor: Colors.black87,
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                _showConfirmRejectModal(context, reasonController.text);
              },
              child: const Text(
                'Next',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // 💡 Modal 2: ยืนยันการ Reject อีกครั้ง
  // ==========================================
  void _showConfirmRejectModal(BuildContext context, String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.redAccent,
                size: 28,
              ),
              const SizedBox(width: 10),
              const Text(
                'Confirm Rejection',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.black87,
                ),
                children: [
                  const TextSpan(
                    text: 'Are you sure you want to reject this request?\n\n',
                  ),
                  const TextSpan(
                    text: 'Reason:\n',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '"$reason"',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Request has been rejected.',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(20),
                  ),
                );
              },
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // 💡 Modal 3: ยืนยันการ Approve (สำหรับ Type: Delete)
  // ==========================================
  void _showConfirmApproveDeleteModal(
    BuildContext context,
    String vehicleName,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF4CA0E6),
                size: 28,
              ),
              const SizedBox(width: 10),
              const Text(
                'Confirm Approve',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CA0E6),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to approve the deletion of "$vehicleName"?\nThis action will remove the vehicle from the system.',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CA0E6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Deletion request has been approved.',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    backgroundColor: const Color(0xFF4CA0E6),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.all(20),
                  ),
                );
              },
              child: const Text(
                'Confirm',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
