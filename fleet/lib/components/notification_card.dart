import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationCard({super.key, required this.notification});

  // 💡 แมปปิ้งไอคอนและสีให้ตรงกับเหตุการณ์แต่ละแบบ
  Map<String, dynamic> _getNotificationStyle(String type) {
    switch (type) {
      // ==========================================
      // 🧑‍💼 ฝั่ง Owner
      // ==========================================
      case 'Return Success': // รับรถที่คืนสำเร็จ
        return {'icon': Icons.check_circle, 'color': const Color(0xFF75DB73)}; 
      case 'Rent Request': // คำขอการเช่ารถ
        return {'icon': Icons.car_rental, 'color': const Color(0xFFE8D354)}; 
      case 'Hand in Request': // มีคำขอการคืนรถใหม่
        return {'icon': Icons.assignment_return, 'color': const Color(0xFF6B66CA)}; 
      case 'Car in Use': // ผู้เช่ารับรถไปใช้แล้ว
        return {'icon': Icons.drive_eta, 'color': const Color(0xFF28A4C9)}; 
      
      // ==========================================
      // 👱‍♂️ ฝั่ง Renter
      // ==========================================
      case 'Top up Success': // เติมเงินสำเร็จ
        return {'icon': Icons.account_balance_wallet, 'color': const Color(0xFF75DB73)}; 
      case 'Rent Accepted': // คำขอเช่ารถได้รับการยืนยันแล้ว
        return {'icon': Icons.fact_check, 'color': const Color(0xFF6B66CA)}; 
      case 'Upcoming Pick-up': // ใกล้ถึงวัน/เวลาที่รับรถแล้ว
        return {'icon': Icons.access_time_filled, 'color': Colors.orange}; 
      case 'Upcoming Return': // ใกล้ถึงเวลาที่ต้องคืนรถแล้ว
        return {'icon': Icons.timer_outlined, 'color': const Color(0xFFF07B75)}; 

      // ==========================================
      // 🛡️ ฝั่ง Staff
      // ==========================================
      case 'New Vehicle Request': // มีคำขอเพิ่มรถใหม่
        return {'icon': Icons.add_circle_outline, 'color': const Color(0xFF28A4C9)}; 
      case 'Delete Vehicle Request': // มีคำขอให้ลบรถ
        return {'icon': Icons.delete_forever, 'color': const Color(0xFFF07B75)}; 
        
      default:
        return {'icon': Icons.notifications_none, 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getNotificationStyle(notification['type']);
    final bool isRead = notification['isRead'] ?? false;

    return Container(
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
                  notification['title'],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: isRead ? FontWeight.w600 : FontWeight.bold, 
                    color: const Color.fromRGBO(7, 14, 42, 1.0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notification['message'],
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification['time'],
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
    );
  }
}