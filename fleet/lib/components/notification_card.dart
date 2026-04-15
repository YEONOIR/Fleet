import 'package:flutter/material.dart';
import '../pages/rating.dart'; // 💡 อย่าลืม import หน้า Rating ของเราเข้ามาด้วยนะ

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key, 
    required this.notification,
    this.onTap,
  });

  Map<String, dynamic> _getNotificationStyle(String type) {
    // 💡 แปลงเป็นตัวพิมพ์เล็กทั้งหมดเวลาเช็ค เพื่อป้องกันการเขียนผิด (Case-insensitive)
    switch (type.toLowerCase()) {
      // ==========================================
      // 🧑‍💼 ฝั่ง Owner
      // ==========================================
      case 'return success': 
        return {'icon': Icons.check_circle, 'color': const Color(0xFF75DB73)}; 
      case 'rent request': 
        return {'icon': Icons.car_rental, 'color': const Color(0xFFE8D354)}; 
      case 'hand in request': 
        return {'icon': Icons.assignment_return, 'color': const Color(0xFF6B66CA)}; 
      case 'car in use': 
        return {'icon': Icons.drive_eta, 'color': const Color(0xFF28A4C9)}; 
        
      // 💡 รองรับ Type ที่มาจากหน้า Vehicle Request (Staff Action)
      case 'approve_add':
      case 'vehicle approved': 
        return {'icon': Icons.check_circle_outline, 'color': const Color(0xFF75DB73)}; 
      case 'approve_delete':
      case 'vehicle deleted': 
        return {'icon': Icons.delete_outline, 'color': const Color(0xFFF07B75)}; 
      case 'reject':
      case 'request rejected': 
        return {'icon': Icons.cancel_outlined, 'color': Colors.redAccent}; 
      
      // ==========================================
      // 👱‍♂️ ฝั่ง Renter
      // ==========================================
      case 'top up success': 
        return {'icon': Icons.account_balance_wallet, 'color': const Color(0xFF75DB73)}; 
      case 'rent accepted': 
        return {'icon': Icons.fact_check, 'color': const Color(0xFF6B66CA)}; 
      case 'upcoming pick-up': 
        return {'icon': Icons.access_time_filled, 'color': Colors.orange}; 
      case 'upcoming return': 
        return {'icon': Icons.timer_outlined, 'color': const Color(0xFFF07B75)}; 

      // ==========================================
      // 🛡️ ฝั่ง Staff
      // ==========================================
      case 'new vehicle request': 
        return {'icon': Icons.add_circle_outline, 'color': const Color(0xFF28A4C9)}; 
      case 'delete vehicle request': 
        return {'icon': Icons.delete_forever, 'color': const Color(0xFFF07B75)}; 
        
      default:
        return {'icon': Icons.notifications_none, 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getNotificationStyle(notification['type'] ?? '');
    final bool isRead = notification['is_read'] ?? false; 

    return GestureDetector(
      // 💡 ฝัง Logic การเปลี่ยนหน้าเข้าไปที่นี่เลย
      onTap: () {
        // 1. เช็คว่าเป็นการแจ้งเตือนให้ประเมินรถหรือไม่
        if (notification['action_type'] == 'rate_vehicle') {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => RatingPage(
              isRatingRenter: false, // ฝั่งผู้เช่าประเมินรถ
              targetId: notification['vehicle_id'] ?? '',
              bookingId: notification['booking_id'] ?? '',
              targetName: notification['vehicle_name'] ?? 'the vehicle',
              // targetImage: notification['vehicle_image'], // เปิดใช้บรรทัดนี้ถ้าตอนสร้าง Noti มีการส่ง URL รูปมาด้วย
            ),
          ));
        }

        // 2. เรียก onTap ที่ถูกส่งมาจาก Parent (เผื่อมีการอัปเดตสถานะ is_read ในหน้าหลัก)
        if (onTap != null) {
          onTap!();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color.fromRGBO(172, 114, 161, 0.05), 
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isRead ? Colors.grey.shade200 : const Color.fromRGBO(172, 114, 161, 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: style['color'].withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(style['icon'], color: style['color'], size: 24),
            ),
            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification['title'] ?? 'Notification',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.bold, 
                      color: const Color.fromRGBO(7, 14, 42, 1.0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification['message'] ?? '',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification['time'] ?? 'Just now',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            if (!isRead)
              Container(
                margin: const EdgeInsets.only(top: 5),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(172, 114, 161, 1.0),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}