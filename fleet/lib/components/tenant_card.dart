import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 เพิ่ม Import Firestore
import '../pages/review_page.dart';

class TenantCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const TenantCard({super.key, required this.booking});

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accept': 
      case 'accepted': return const Color(0xFF2E8B57); 
      case 'complete': 
      case 'completed': return const Color(0xFF28A4C9); 
      case 'cancel': 
      case 'cancelled': 
      case 'reject': 
      case 'rejected': return const Color(0xFFA52A2A); 
      case 'pending': return Colors.orange; 
      case 'using': return const Color.fromRGBO(172, 114, 161, 1.0); 
      default: return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentStatus = booking['status'] ?? 'Pending';
    Color statusColor = _getStatusColor(currentStatus);
    
    String startDate = booking['startDate'] ?? '-';
    String endDate = booking['endDate'] ?? '-';
    String startTime = booking['startTime'] ?? '-';
    String endTime = booking['endTime'] ?? '-';

    // 💡 ดึง ID ผู้เช่าเพื่อเอาไปค้นหาข้อมูลใน Collection 'users'
    String renterId = booking['renter_id'] ?? booking['renterId'] ?? '';

    return FutureBuilder<DocumentSnapshot>(
      // 💡 ค้นหาข้อมูลผู้เช่าจาก Firestore แบบ Real-time
      future: renterId.isNotEmpty ? FirebaseFirestore.instance.collection('users').doc(renterId).get() : null,
      builder: (context, snapshot) {
        
        // 💡 ค่าตั้งต้น (ดึงจากข้อมูลเก่าไปก่อนระหว่างรอโหลด)
        String renterName = booking['renterName'] ?? 'Unknown';
        String rating = booking['rating']?.toString() ?? '0.0';
        String tel = booking['tel'] ?? '-';
        String rImage = booking['renterImage'] ?? 'assets/icons/avatar.jpg';

        // 💡 ถ้าโหลดข้อมูล User สำเร็จ ให้เอาข้อมูลล่าสุดจาก Database มาทับเลย
        if (snapshot.hasData && snapshot.data!.exists) {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          renterName = userData['first_name'] ?? renterName;
          
          // 💡 ดึงฟิลด์ rating ตรงๆ จาก Collection users (ตรงตามที่คุณให้ดูในรูป)
          double rawRating = (userData['rating'] ?? 0).toDouble();
          rating = rawRating.toStringAsFixed(1); // ปัดทศนิยม 1 ตำแหน่ง (เช่น 4.5)
          
          tel = userData['phone'] ?? tel;
          if (userData['profile_image'] != null && userData['profile_image'].toString().isNotEmpty) {
            rImage = userData['profile_image'];
          }
        }

        // 💡 เช็คว่าเป็นรูปภาพจากเน็ตหรือในเครื่อง สำหรับ Avatar ผู้เช่า
        ImageProvider avatarImage = rImage.startsWith('http') 
            ? NetworkImage(rImage) 
            : AssetImage(rImage) as ImageProvider;

        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(18), 
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color.fromRGBO(172, 114, 161, 0.4), width: 1.5), 
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center, 
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: avatarImage, 
                  ),
                  const SizedBox(width: 15),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                             Expanded(
                              child: Text(
                                renterName,
                                style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold, color: Color.fromRGBO(7, 14, 42, 1.0)),
                                overflow: TextOverflow.ellipsis, 
                              ),
                            ),

                           GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => FleetEntityReviewPage( 
                                    isCar: false, 
                                    entityName: 'User Reviews',
                                    targetId: renterId, 
                                  )
                                ));
                              },
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Color(0xFFFFD700), size: 18),
                                  const SizedBox(width: 4),
                                  // 💡 แสดงคะแนนล่าสุดที่ดึงมาจากฐานข้อมูล
                                  Text(rating, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  const SizedBox(width: 8),
                                  const Text('(Check Reviews)', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, decoration: TextDecoration.underline, color: Color.fromRGBO(172, 114, 161, 1.0))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5), 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Tel: $tel', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
                            
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                                  const SizedBox(width: 6),
                                  Text(currentStatus.toUpperCase(), style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Colors.grey.shade200, thickness: 1.5),
              ),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(startDate, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined, size: 16, color: Colors.transparent), 
                          const SizedBox(width: 6),
                          Text(endDate, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 6),
                          Text(startTime, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 16, color: Colors.transparent),
                          const SizedBox(width: 6),
                          Text(endTime, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      }
    );
  }
}