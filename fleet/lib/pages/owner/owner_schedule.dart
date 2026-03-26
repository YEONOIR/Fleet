import 'package:flutter/material.dart';
import '../../components/tenant_card.dart'; 
import 'schedule_detail.dart'; // 💡 นำเข้าหน้า Detail ที่เราเพิ่งสร้าง (แก้ Path ให้ตรงถ้าอยู่คนละโฟลเดอร์นะครับ)

class OwnerSchedulePage extends StatefulWidget {
  const OwnerSchedulePage({super.key});

  @override
  State<OwnerSchedulePage> createState() => _OwnerSchedulePageState();
}

class _OwnerSchedulePageState extends State<OwnerSchedulePage> {
  // 💡 ข้อมูล Dummy ครบทั้ง 5 สถานะ
  final List<Map<String, dynamic>> mockBookings = [
    {
      'renterName': 'Sukrit Chatchawal',
      'tel': '0848978975',
      'rating': '3.0',
      'startDate': '08/02/2026',
      'endDate': '12/02/2026',
      'startTime': '12:00',
      'endTime': '14:00',
      'status': 'Pending',
    },
    {
      'renterName': 'Sukrit Chatchawal',
      'tel': '0848978975',
      'rating': '3.0',
      'startDate': '08/02/2026',
      'endDate': '12/02/2026',
      'startTime': '12:00',
      'endTime': '14:00',
      'status': 'Accept',
    },
    {
      'renterName': 'Nadech Kugimiya',
      'tel': '0812345678',
      'rating': '4.5',
      'startDate': '15/03/2026',
      'endDate': '17/03/2026',
      'startTime': '09:00',
      'endTime': '18:00',
      'status': 'Using',
    },
    {
      'renterName': 'Yaya Urassaya',
      'tel': '0898765432',
      'rating': '5.0',
      'startDate': '01/01/2026',
      'endDate': '05/01/2026',
      'startTime': '10:00',
      'endTime': '10:00',
      'status': 'Complete',
      'remark': 'A small scratch on the front left bumper.', // 💡 เพิ่มบรรทัดนี้ลงไปใน Dummy ของ Complete
    },
    {
      'renterName': 'Mario Maurer',
      'tel': '0887776655',
      'rating': '4.8',
      'startDate': '20/02/2026',
      'endDate': '22/02/2026',
      'startTime': '13:00',
      'endTime': '15:00',
      'status': 'Cancel',
      'remark': 'I changed my travel plans and no longer need the car.', // 💡 เพิ่มบรรทัดนี้ลงไปใน Dummy ของ Cancel
    },
  ];

  @override
  Widget build(BuildContext context) {
    // แยกข้อมูลตามหน้า Active กับ History
    List<Map<String, dynamic>> activeBookings = mockBookings.where((b) => ['Pending', 'Accept', 'Using'].contains(b['status'])).toList();
    List<Map<String, dynamic>> historyBookings = mockBookings.where((b) => ['Complete', 'Cancel'].contains(b['status'])).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
        appBar: AppBar(
          elevation: 0,
          centerTitle: false, 
          title: const Text('Schedule', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: const TabBar(
                indicatorColor: Color.fromRGBO(172, 114, 161, 1.0),
                indicatorWeight: 3,
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                labelColor: Color.fromRGBO(7, 14, 42, 1.0), 
                unselectedLabelColor: Colors.grey, 
                labelStyle: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15),
                tabs: [
                  Tab(text: 'Active Rentals'),
                  Tab(text: 'History'),
                ],
              ),
            ),
            
            Expanded(
              child: TabBarView(
                children: [
                  // 💡 หน้า Active Rentals
                  ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: activeBookings.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // 💡 กดแล้ววิ่งไปหน้า Detail พร้อมส่งข้อมูลการจองไปด้วย
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScheduleDetailPage(booking: activeBookings[index]),
                            ),
                          );
                        },
                        child: TenantCard(booking: activeBookings[index]), 
                      );
                    },
                  ),
                  
                  // 💡 หน้า History
                  ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: historyBookings.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          // 💡 กดแล้ววิ่งไปหน้า Detail พร้อมส่งข้อมูลการจองไปด้วย
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ScheduleDetailPage(booking: historyBookings[index]),
                            ),
                          );
                        },
                        child: TenantCard(booking: historyBookings[index]),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}