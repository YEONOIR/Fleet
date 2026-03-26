import 'package:flutter/material.dart';
import '../../components/notification_card.dart'; // 💡 เช็ค Path ให้ตรงกับโฟลเดอร์ component ของคุณ

class StaffNotificationsPage extends StatefulWidget {
  const StaffNotificationsPage({super.key});

  @override
  State<StaffNotificationsPage> createState() => _StaffNotificationsPageState();
}

class _StaffNotificationsPageState extends State<StaffNotificationsPage> {
  // 💡 ข้อมูลการแจ้งเตือนเฉพาะฝั่ง Staff
  List<Map<String, dynamic>> staffNotifications = [
    {
      'type': 'New Vehicle Request', 
      'title': 'New Vehicle Approval', 
      'message': 'Sukrit requested to add a new Honda Civic e:HEV to the system. Please review.', 
      'time': '30 mins ago', 
      'isRead': false
    },
    {
      'type': 'New Vehicle Request', 
      'title': 'New Vehicle Approval', 
      'message': 'Pimthida requested to add a Yamaha Grand Filano. Please review.', 
      'time': '2 hours ago', 
      'isRead': false
    },
    {
      'type': 'Delete Vehicle Request', 
      'title': 'Vehicle Deletion Request', 
      'message': 'Mario Maurer requested to delete Toyota Camry from the system.', 
      'time': '4 hours ago', 
      'isRead': true
    },
  ];

  void _markAllAsRead() {
    setState(() {
      for (var notification in staffNotifications) {
        notification['isRead'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: const Text('Notifications', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text('Mark all read', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: staffNotifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 15),
                  Text('No pending requests', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.grey.shade500)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: staffNotifications.length,
              itemBuilder: (context, index) {
                return NotificationCard(notification: staffNotifications[index]);
              },
            ),
    );
  }
}