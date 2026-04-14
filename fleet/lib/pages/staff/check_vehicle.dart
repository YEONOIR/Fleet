import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
// 💡 เปลี่ยน Path นี้ให้ตรงกับที่เก็บไฟล์ reject_modal.dart ของคุณนะ
import '../../components/reject_modal.dart'; 
// 💡 นำเข้า StaffMainPage เพื่อรักษาระยะ Navbar
import 'staff_main.dart'; 

class CheckVehiclePage extends StatelessWidget {
  final String vehicleId; 
  final String vehicleName;
  final String ownerId; 
  final List<String> ownerImages; 
  final List<File> staffImages;   

  const CheckVehiclePage({
    super.key,
    required this.vehicleId, 
    required this.vehicleName,
    required this.ownerId, 
    required this.ownerImages,
    required this.staffImages,
  });

  // ฟังก์ชันสำหรับยิงแจ้งเตือนเข้า Firestore
  Future<void> _sendNotificationToOwner(String type, String title, String message) async {
    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'user_id': ownerId, 
        'target_role': 'Owner', 
        'type': type, 
        'title': title,
        'message': message,
        'is_read': false,
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Check Vehicle', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. สไลด์รูปของ Owner
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Photos from Owner', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: ownerImages.isEmpty ? 1 : ownerImages.length,
                      itemBuilder: (context, index) {
                        String imgPath = ownerImages.isNotEmpty ? ownerImages[index] : '';
                        return Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ownerImages.isNotEmpty 
                              ? (imgPath.startsWith('http') 
                                  ? Image.network(imgPath, fit: BoxFit.cover, width: 250, errorBuilder: (ctx, err, stack) => Container(width: 250, color: Colors.grey[300], child: const Icon(Icons.broken_image)))
                                  : Image.asset(imgPath, fit: BoxFit.cover, width: 250))
                              : Image.asset('assets/images/car.jpg', fit: BoxFit.cover, width: 250),
                          ),
                        );
                      }
                    ),
                  ),
                  const SizedBox(height: 35),

                  // 2. สไลด์รูปของ Staff (ถ่ายล่าสุด)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Latest Condition (Staff)', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: staffImages.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            staffImages[index],
                            fit: BoxFit.cover,
                            width: 250,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. แถบปุ่มด้านล่าง
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade400, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        RejectModal.show(
                          context, 
                          onConfirm: (String reason) async {
                            try {
                              // ลบข้อมูลทิ้งเมื่อกด Reject
                              await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).delete();

                              await _sendNotificationToOwner(
                                'request rejected', 
                                'Vehicle Rejected', 
                                'Your request to add "$vehicleName" has been rejected. Reason: $reason'
                              );

                              if (!context.mounted) return;
                              
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Request rejected and vehicle deleted.', style: TextStyle(fontFamily: 'Poppins')),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );

                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const StaffMainPage()),
                                (route) => false,
                              );
                            } catch (e) {
                              debugPrint('Error deleting vehicle: $e');
                            }
                          }
                        );
                      },
                      child: Text('Reject', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.red.shade400, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CA0E6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        try {
                          await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).update({
                            'status': 'available' // 💡 แก้สถานะเป็น available แล้ว
                          });

                          await _sendNotificationToOwner(
                            'vehicle approved', 
                            'Vehicle Approved', 
                            'Your vehicle "$vehicleName" has been approved and is now listed.'
                          );

                          if (!context.mounted) return;
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vehicle added successfully!', style: TextStyle(fontFamily: 'Poppins')),
                              backgroundColor: Color(0xFF4CA0E6),
                            ),
                          );

                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const StaffMainPage()),
                            (route) => false,
                          );
                        } catch (e) {
                          debugPrint('Error approving vehicle: $e');
                        }
                      },
                      child: const Text('Confirm Add', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
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
}