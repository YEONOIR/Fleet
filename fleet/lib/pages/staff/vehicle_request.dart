import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../utils/vehicle_utils.dart'; 
import '../take_photo.dart';
import '../review_page.dart'; 

class VehicleRequestPage extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleRequestPage({super.key, required this.vehicle});

  // ==========================================
  // 💡 ฟังก์ชัน Helper สำหรับส่ง Notification ลง Firebase (แยก Role)
  // ==========================================
  Future<void> _sendNotification(String ownerId, String title, String message, String type, String targetRole) async {
      try {
        await FirebaseFirestore.instance.collection('notifications').add({
          'user_id': ownerId,
          'title': title,
          'message': message,
          'type': type,
          'target_role': targetRole, 
          'is_read': false,
          'created_at': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print("Error sending notification: $e");
      }
  }

  @override
  Widget build(BuildContext context) {
    final String requestType = vehicle['type'] ?? 'Add';
    final String vehicleId = vehicle['id'] ?? ''; 
    final String ownerId = vehicle['owner_id'] ?? ''; 

    List<dynamic> galleryImages = (vehicle['images'] != null && (vehicle['images'] as List).isNotEmpty)
        ? vehicle['images'] 
        : [vehicle['imagePath'] ?? 'assets/images/car.jpg'];

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
        title: const Text('Request Details', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          Expanded(
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
                      itemCount: galleryImages.length, 
                      itemBuilder: (context, index) {
                        String imgPath = galleryImages[index].toString();
                        return Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: imgPath.startsWith('http') 
                                ? Image.network(
                                    imgPath, 
                                    fit: BoxFit.cover, 
                                    width: 250,
                                    errorBuilder: (context, error, stackTrace) => Container(width: 250, color: Colors.grey[400], child: const Icon(Icons.broken_image, color: Colors.grey)),
                                  )
                                : Image.asset(imgPath, fit: BoxFit.cover, width: 250),
                          ),
                        );
                      }
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoColumn('License Plate', vehicle['V Plate'] ?? '-'),
                                  const SizedBox(height: 20),
                                  _buildInfoColumn('Brand', vehicle['V Brand'] ?? '-'),
                                  const SizedBox(height: 20),
                                  _buildInfoColumn('Model', vehicle['V Model'] ?? '-'),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(getFuelIcon(vehicle['V Fuel']), size: 45, color: const Color.fromRGBO(7, 14, 42, 1.0)),
                                  const SizedBox(height: 5),
                                  Text(
                                    vehicle['V Fuel'].toString().toUpperCase() == 'EV' ? 'ENERGY' : (vehicle['V Fuel'] ?? 'FUEL').toString().toUpperCase(),
                                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoColumn('Vehicle Type', vehicle['V Type'] ?? '-'),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end, 
                              children: [
                                const Text('Rating', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 5),
                                    Text((vehicle['V_Rate'] ?? 0.0).toString(), style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 15), 
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => const FleetEntityReviewPage(isCar: true, entityName: 'Vehicle Reviews')));
                                      },
                                      child: const Text('Comment', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, decoration: TextDecoration.underline, color: Color.fromRGBO(172, 114, 161, 1.0), fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Address', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: Text(vehicle['V Address'] ?? '-', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoColumn('Deposit (฿)', (vehicle['V Deposit'] ?? 0).toString()),
                            _buildInfoColumn('Price/Hour (฿)', (vehicle['V Price'] ?? 0).toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
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
                        _showRejectReasonModal(context, vehicleId, requestType);
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
                        if (requestType == 'Delete') {
                          _showConfirmApproveDeleteModal(context, vehicleId, vehicle['V Name'] ?? 'this vehicle');
                        } else {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TakePhotoPage(
                                vehicleName: vehicle['V Name'] ?? 'New Vehicle',
                                isStaff: true,
                                vehicleId: vehicleId,
                                ownerId: ownerId, 
                                ownerImages: galleryImages.map((e) => e.toString()).toList(),
                              ),
                            ),
                          );
                        }
                      },
                      child: const Text('Approve', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showRejectReasonModal(BuildContext context, String vehicleId, String requestType) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) { // ✅ 1. เปลี่ยนชื่อตรงนี้เป็น dialogContext
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Reject Request', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.redAccent)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please provide a reason for rejection:', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 15),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter reason here...',
                    hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.redAccent)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reason cannot be empty', style: TextStyle(fontFamily: 'Poppins')), backgroundColor: Colors.black87));
                  return;
                }
                
                Navigator.pop(dialogContext); // ✅ 2. ปิด Modal แรกด้วย dialogContext
                
                // ✅ 3. ส่ง 'context' (ของหน้าหลัก) ไปให้ _showConfirmRejectModal
                _showConfirmRejectModal(context, vehicleId, requestType, reasonController.text); 
              },
              child: const Text('Next', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmRejectModal(BuildContext parentContext, String vehicleId, String requestType, String reason) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 10),
              Text('Confirm Rejection', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.redAccent)),
            ],
          ),
          content: RichText(
            text: TextSpan(
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black87),
              children: [
                const TextSpan(text: 'Are you sure you want to reject this request?\n\n'),
                const TextSpan(text: 'Reason:\n', style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: '"$reason"', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                Navigator.pop(dialogContext); 

                try {
                  DocumentSnapshot doc = await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).get();
                  if (doc.exists) {
                    String ownerId = doc['owner_id'];
                    String vName = doc['vehicle_name'] ?? 'Vehicle';
                    
                    if (requestType == 'Add') {
                      await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).delete();
                    } else {
                      await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).update({
                        'status': 'available',
                        'pending_type': FieldValue.delete(), 
                      });
                    }

                    await _sendNotification(
                      ownerId, 
                      'Request Rejected', 
                      'Your request to $requestType "$vName" was rejected. Reason: $reason',
                      'Request Rejected',
                      'Owner'
                    );
                  }

                  if (parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('Request rejected successfully.', style: TextStyle(fontFamily: 'Poppins')), backgroundColor: Colors.redAccent));
                    // 💡 NEW: ใช้ pushNamedAndRemoveUntil เรียก Path '/staff' โดยตรง
                    Navigator.pushNamedAndRemoveUntil(parentContext, '/staff', (route) => false);
                  }
                } catch (e) {
                  print("Error rejecting: $e");
                }
              },
              child: const Text('Confirm', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmApproveDeleteModal(BuildContext parentContext, String vehicleId, String vehicleName) {
    showDialog(
      context: parentContext,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Color(0xFF4CA0E6), size: 28),
              SizedBox(width: 10),
              Text('Confirm Delete', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Color(0xFF4CA0E6))),
            ],
          ),
          content: Text('Are you sure you want to approve the deletion of "$vehicleName"?\nThis action will remove the vehicle from the system.', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black87)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CA0E6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  DocumentSnapshot doc = await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).get();
                  if (doc.exists) {
                    String ownerId = doc['owner_id'];
                    await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).delete();

                    await _sendNotification(
                      ownerId, 
                      'Vehicle Deleted', 
                      'Your vehicle "$vehicleName" has been successfully deleted from the system.',
                      'Vehicle Deleted',
                      'Owner'
                    );
                  }

                  if (parentContext.mounted) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text('Vehicle deleted successfully.', style: TextStyle(fontFamily: 'Poppins')), backgroundColor: Color(0xFF4CA0E6)));
                    // 💡 NEW: ใช้ pushNamedAndRemoveUntil เรียก Path '/staff' โดยตรง
                    Navigator.pushNamedAndRemoveUntil(parentContext, '/staff', (route) => false);
                  }
                } catch (e) {
                  print("Error deleting: $e");
                }
              },
              child: const Text('Confirm', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}