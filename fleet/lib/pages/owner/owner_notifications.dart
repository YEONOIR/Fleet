import 'package:flutter/material.dart';
import '../../components/notification_card.dart'; 

class OwnerNotificationPage extends StatefulWidget {
  const OwnerNotificationPage({super.key});

  @override
  State<OwnerNotificationPage> createState() => _OwnerNotificationPageState();
}

class _OwnerNotificationPageState extends State<OwnerNotificationPage> {
  // 💡 ลองเปลี่ยนตัวแปรนี้ดูครับ! ค่าที่ใส่ได้: 'Owner', 'Renter', 'Staff'
  String currentUserRole = 'Owner'; 

  // ข้อมูลจำลองของทุก User รวบรวมไว้ที่นี่
  List<Map<String, dynamic>> allNotifications = [
    // ================= OWNER =================
    {'role': 'Owner', 'type': 'Rent Request', 'title': 'New Rent Request', 'message': 'Sukrit wants to rent your Honda Civic.', 'time': '5 mins ago', 'isRead': false},
    {'role': 'Owner', 'type': 'Hand in Request', 'title': 'Return Request', 'message': 'Pimthida is ready to return the vehicle.', 'time': '1 hour ago', 'isRead': false},
    {'role': 'Owner', 'type': 'Car in Use', 'title': 'Car Picked Up', 'message': 'The renter has successfully picked up your car.', 'time': 'Yesterday', 'isRead': true},
    {'role': 'Owner', 'type': 'Return Success', 'title': 'Return Complete', 'message': 'You have successfully received your car back.', 'time': '2 days ago', 'isRead': true},

    // ================= RENTER =================
    {'role': 'Renter', 'type': 'Top up Success', 'title': 'Top Up Successful', 'message': '฿ 2,000 has been added to your wallet.', 'time': '10 mins ago', 'isRead': false},
    {'role': 'Renter', 'type': 'Rent Accepted', 'title': 'Booking Confirmed!', 'message': 'Owner has accepted your rent request.', 'time': '2 hours ago', 'isRead': false},
    {'role': 'Renter', 'type': 'Upcoming Pick-up', 'title': 'Upcoming Pick-up', 'message': 'Don\'t forget to pick up the car tomorrow at 10:00 AM.', 'time': 'Yesterday', 'isRead': true},
    {'role': 'Renter', 'type': 'Upcoming Return', 'title': 'Time to Return', 'message': 'Your rental ends in 2 hours. Please prepare to return the car.', 'time': 'Yesterday', 'isRead': true},

    // ================= STAFF =================
    {'role': 'Staff', 'type': 'New Vehicle Request', 'title': 'New Vehicle Approval', 'message': 'Sukrit requested to add a new Honda Civic.', 'time': '30 mins ago', 'isRead': false},
    {'role': 'Staff', 'type': 'Delete Vehicle Request', 'title': 'Vehicle Deletion', 'message': 'Pimthida requested to delete a vehicle from the system.', 'time': '4 hours ago', 'isRead': true},
  ];

  void _markAllAsRead(List<Map<String, dynamic>> displayList) {
    setState(() {
      for (var notification in displayList) {
        notification['isRead'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 💡 คัดกรองเอาเฉพาะการแจ้งเตือนของ Role ปัจจุบัน
    List<Map<String, dynamic>> displayNotifications = allNotifications.where((n) => n['role'] == currentUserRole).toList();

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
            onPressed: () => _markAllAsRead(displayNotifications),
            child: const Text('Mark all read', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: displayNotifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 15),
                  Text('No notifications', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.grey.shade500)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: displayNotifications.length,
              itemBuilder: (context, index) {
                return NotificationCard(notification: displayNotifications[index]);
              },
            ),
    );
  }
}