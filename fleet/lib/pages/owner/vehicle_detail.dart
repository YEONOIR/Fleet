import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 เพิ่มเพื่อคุยกับ Firestore
import '../../components/renter_info_card.dart';
import '../../utils/vehicle_utils.dart';
import '../review_page.dart';

class VehicleDetailPage extends StatelessWidget {
  final Map<String, dynamic> vehicle;

  const VehicleDetailPage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final String status = vehicle['V Status'].toString().toLowerCase();
    
    // ดึงรูปภาพทั้งหมดที่มีมาเก็บเป็น List ถ้าไม่มีให้เอารูปหน้าปกมาใส่แทน
    List<dynamic> galleryImages = (vehicle['images'] != null && (vehicle['images'] as List).isNotEmpty)
        ? vehicle['images'] 
        : [vehicle['imagePath']];
    
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
          // 💡 ซ่อนปุ่มลบ ถ้าสถานะเป็น Pending อยู่แล้ว (เพราะกำลังรอคิวลบหรือเพิ่มอยู่)
          if (status != 'pending')
            IconButton(
              onPressed: () {
                // 💡 เช็คว่าสถานะเป็น using อยู่หรือไม่
                if (status == 'using') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Can not delete the vehicles. Please complete all rental arrangements first.', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                } else {
                  _showDeleteConfirmation(context);
                }
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
                  // 1. Image Gallery 
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
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 250, 
                                      color: Colors.grey[400], 
                                      child: const Icon(Icons.broken_image, color: Colors.grey)
                                    ),
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
                                    const SizedBox(width: 15), 
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => FleetEntityReviewPage(
                                            isCar: true, 
                                            entityName: 'Vehicle Reviews',
                                            targetId: vehicle['id'] ?? '', 
                                          )
                                        ));
                                      },
                                      child: const Text(
                                        'Comment', 
                                        style: TextStyle(
                                          fontFamily: 'Poppins', 
                                          fontSize: 13, 
                                          decoration: TextDecoration.underline, 
                                          color: Color.fromRGBO(172, 114, 161, 1.0), 
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

                        // 4. Pricing & Deposit 
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

                        // 6. ส่วนแสดงข้อมูลผู้เช่าและรูปภาพสำหรับสถานะ USING
                        if (status == 'using') _buildUsingInfo(context, galleryImages),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 7. ส่วนแสดงปุ่ม Action ตามสถานะ 
          if (status == 'available' || status == 'unavailable')
            Padding(
              padding: const EdgeInsets.all(20),
              // 💡 ส่ง context และ vehicle['id'] เข้าไปในฟังก์ชันด้วย
              child: _buildActionButton(context, status, vehicle['id'] ?? ''),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // Widget สำหรับสถานะ USING (ข้อมูลผู้เช่า + รูป Before Rent)
  // ==========================================
  Widget _buildUsingInfo(BuildContext context, List<dynamic> galleryImages) {
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
          renterId: renter['id'] ?? renter['renter_id'] ?? '', 
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Total Price', style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold)),
            Text(
              '฿ ${renter['totalPrice']}', 
              style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, color: Color.fromRGBO(172, 114, 161, 1.0), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 20),

        const Text('Pictures before rent', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          height: 200, 
          color: Colors.grey.shade200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(15),
            itemCount: galleryImages.length,
            itemBuilder: (context, index) {
              String imgPath = galleryImages[index].toString();
              return Container(
                width: 250, 
                margin: const EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                clipBehavior: Clip.hardEdge,
                child: imgPath.startsWith('http')
                    ? Image.network(
                        imgPath, 
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(color: Colors.grey[400], child: const Icon(Icons.broken_image, color: Colors.grey))
                      )
                    : Image.asset(imgPath, fit: BoxFit.cover),
              );
            },
          ),
        ),
      ],
    );
  }

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

  // 💡 เปลี่ยนจากรับแค่ status อย่างเดียว เป็นรับ context และ vehicleId ด้วย
  Widget _buildActionButton(BuildContext context, String status, String vehicleId) {
    bool isAvailable = status == 'available';
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isAvailable ? const Color(0xFFF07B75) : const Color(0xFF75DB73),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () async {
          if (vehicleId.isEmpty) return;

          // 💡 กำหนดสถานะใหม่ที่จะอัปเดต
          String newStatus = isAvailable ? 'unavailable' : 'available';

          // 💡 แสดง Popup วงแหวนโหลดขณะกำลังเปลี่ยนสถานะ
          showDialog(
            context: context, 
            barrierDismissible: false, 
            builder: (context) => const Center(child: CircularProgressIndicator(color: Color.fromRGBO(172, 114, 161, 1.0)))
          );

          try {
            // 💡 อัปเดตสถานะลง Firestore
            await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).update({
              'status': newStatus,
            });

            if (context.mounted) {
              Navigator.pop(context); // ปิดวงแหวนโหลด
              
              // 💡 แสดงแจ้งเตือน
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Vehicle status changed to $newStatus', style: const TextStyle(fontFamily: 'Poppins', color: Colors.white)),
                  backgroundColor: isAvailable ? Colors.redAccent : Colors.green,
                )
              );
              
              // 💡 เด้งกลับไปหน้า Home เพื่อให้ตารางรถของ Owner โหลดใหม่
              Navigator.pop(context, true); 
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context); // ปิดวงแหวนโหลด
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
            }
          }
        },
        child: Text(
          isAvailable ? 'Set as unavailable' : 'Set as available',
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
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
  // 💡 โค้ดยืนยันการส่ง Request เปลี่ยนสถานะเป็น Pending (Delete)
  // ==========================================
  void _showDeleteConfirmation(BuildContext context) {
    String vehicleName = vehicle['V Name'] ?? 'this vehicle'; 
    String vehicleId = vehicle['id'] ?? ''; 

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog( 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
            const SizedBox(width: 10),
            const Text('Delete Request', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.redAccent)),
          ],
        ),
        content: Text(
          'Are you sure you want to request deletion for "$vehicleName"?\nThe vehicle status will be changed to Pending.', 
          style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), 
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold))
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
            ),
            onPressed: () async {
              Navigator.pop(dialogContext); 

              if (vehicleId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Vehicle ID not found.')));
                return;
              }

              try {
                // อัปเดตข้อมูลใน Firestore แทนการลบทิ้ง
                await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).update({
                  'status': 'pending',
                  'pending_type': 'Delete', 
                });

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Send request successfully', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
                      backgroundColor: Colors.black87,
                      behavior: SnackBarBehavior.floating, 
                      margin: const EdgeInsets.only(
                        bottom: 80, 
                        left: 20,
                        right: 20,
                      ),
                    )
                  );
                  Navigator.pop(context, true); 
                }
              } catch (e) {
                print("Error requesting delete: $e");
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send request. Please try again.')));
                }
              }
            },
            child: const Text('Send Request', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}