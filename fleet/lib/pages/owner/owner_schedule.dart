import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/tenant_card.dart';
import 'schedule_detail.dart';

class OwnerSchedulePage extends StatefulWidget {
  const OwnerSchedulePage({super.key});

  @override
  State<OwnerSchedulePage> createState() => _OwnerSchedulePageState();
}

class _OwnerSchedulePageState extends State<OwnerSchedulePage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _activeBookings = [];
  List<Map<String, dynamic>> _historyBookings = [];
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    _listenToBookings();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // ==========================================
  // ดึงข้อมูลการจองทั้งหมดของ Owner จาก Firestore แบบ Real-time
  // ==========================================
  void _listenToBookings() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Active = สถานะที่ยังไม่จบ (ยกเว้น pending เพราะ owner_home จัดการแล้ว)
    // ดึงทุก status ของ Owner คนนี้ แล้วค่อยแยก Active/History ในแอพ
    _subscription = FirebaseFirestore.instance
        .collection('bookings')
        .where('owner_id', isEqualTo: user.uid)
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) async {
      List<Map<String, dynamic>> active = [];
      List<Map<String, dynamic>> history = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String status = (data['status'] ?? 'pending').toString().toLowerCase();

        // ดึงข้อมูลผู้เช่า
        String renterId = data['renter_id'] ?? '';
        String fName = 'Unknown';
        String lName = '';
        String phone = '-';
        String renterImage = 'assets/icons/avatar.jpg';

        if (renterId.isNotEmpty) {
          try {
            var rDoc = await FirebaseFirestore.instance.collection('users').doc(renterId).get();
            if (rDoc.exists) {
              final rData = rDoc.data() as Map<String, dynamic>;
              fName = rData['first_name'] ?? 'Unknown';
              lName = rData['last_name'] ?? '';
              phone = rData['phone'] ?? '-';
              if (rData['profile_image'] != null && rData['profile_image'].toString().startsWith('http')) {
                renterImage = rData['profile_image'];
              }
            }
          } catch (_) {}
        }

        // ดึงข้อมูลรถ
        String vehicleId = data['vehicle_id'] ?? '';
        String vehicleName = 'Unknown Vehicle';
        String vehicleImage = 'assets/images/car.jpg';

        if (vehicleId.isNotEmpty) {
          try {
            var vDoc = await FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).get();
            if (vDoc.exists) {
              final vData = vDoc.data() as Map<String, dynamic>;
              vehicleName = vData['vehicle_name'] ?? vData['brand'] ?? 'Unknown';
              if (vData['images'] != null && (vData['images'] as List).isNotEmpty) {
                vehicleImage = vData['images'][0];
              }
            }
          } catch (_) {}
        }

        // จัดรูปแบบวันที่
        String formatDate(dynamic ts) {
          if (ts == null) return 'N/A';
          final DateTime d = (ts as Timestamp).toDate();
          return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
        }

        String formatTime(dynamic ts) {
          if (ts == null) return '';
          final DateTime d = (ts as Timestamp).toDate();
          return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
        }

        // สร้าง booking map ที่ครบถ้วนสำหรับส่งไปหน้า Detail
        final Map<String, dynamic> bookingMap = {
          // ✅ ID สำคัญ — ต้องครบทั้ง 2 ตัว
          'bookingId': doc.id,
          'vehicleId': vehicleId,
          'renterId': renterId,

          // ข้อมูลผู้เช่า
          'renterName': '$fName $lName',
          'tel': phone,
          'rating': '0.0',
          'renterImage': renterImage,

          // ข้อมูลรถ
          'vehicleName': vehicleName,
          'vehicleImage': vehicleImage,

          // วันเวลา
          'startDate': formatDate(data['start_time']),
          'endDate': formatDate(data['end_time']),
          'startTime': formatTime(data['start_time']),
          'endTime': formatTime(data['end_time']),

          // สถานะ
          'status': _capitalizeFirst(status),
          'pendingType': data['pending_type'] ?? 'rent',
          'remark': data['handin_defect'] ?? data['cancel_reason'] ?? '-',
        };

        // แยก Active กับ History
        // Active: accept, using, pending (ที่เป็น return request)
        // History: complete, cancel, reject
        if (['complete', 'completed', 'cancel', 'cancelled', 'reject'].contains(status)) {
          history.add(bookingMap);
        } else if (['accept', 'accepted', 'using'].contains(status)) {
          // pending ธรรมดา (rent request) แสดงใน owner_home แล้ว ไม่ต้องซ้ำ
          // แต่ pending ที่เป็น return request ให้แสดงใน active ด้วย
          active.add(bookingMap);
        } else if (status == 'pending' && (data['pending_type'] ?? '') == 'return') {
          active.add(bookingMap);
        }
      }

      if (mounted) {
        setState(() {
          _activeBookings = active;
          _historyBookings = history;
          _isLoading = false;
        });
      }
    });
  }

  String _capitalizeFirst(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color.fromRGBO(172, 114, 161, 1.0)))
                  : TabBarView(
                      children: [
                        // Tab 1: Active Rentals
                        _activeBookings.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.event_available_outlined, size: 60, color: Colors.grey),
                                    SizedBox(height: 10),
                                    Text('No active rentals.', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: _activeBookings.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ScheduleDetailPage(booking: _activeBookings[index]),
                                      ),
                                    ),
                                    child: TenantCard(booking: _activeBookings[index]),
                                  );
                                },
                              ),

                        // Tab 2: History
                        _historyBookings.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.history_outlined, size: 60, color: Colors.grey),
                                    SizedBox(height: 10),
                                    Text('No rental history yet.', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: _historyBookings.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ScheduleDetailPage(booking: _historyBookings[index]),
                                      ),
                                    ),
                                    child: TenantCard(booking: _historyBookings[index]),
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