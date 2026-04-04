import 'package:flutter/material.dart';
import '../../components/renter_info_card.dart'; // ใช้การ์ดเดิมที่มีอยู่
import 'renter_take_photo.dart';
import 'renter_rate_vehicle.dart';

class RenterScheduleDetailPage extends StatefulWidget {
  final Map<String, dynamic> booking;
  
  const RenterScheduleDetailPage({super.key, required this.booking});

  @override
  State<RenterScheduleDetailPage> createState() => _RenterScheduleDetailPageState();
}

class _RenterScheduleDetailPageState extends State<RenterScheduleDetailPage> {
  late int currentStatusIndex; // 0=Accept, 1=Using, 2=Complete, 3=Cancel

  @override
  void initState() {
    super.initState();
    currentStatusIndex = widget.booking['status'];
  }

  Color _getBadgeColor() {
    if (currentStatusIndex == 0) return const Color(0xFF2E8B57); // Green (Accept)
    if (currentStatusIndex == 1) return const Color(0xFFA573A1); // Purple (Using)
    if (currentStatusIndex == 2) return const Color(0xFF28A4C9); // Blue (Complete)
    return Colors.red;
  }

  String _getStatusText() {
    if (currentStatusIndex == 0) return 'Accept';
    if (currentStatusIndex == 1) return 'Using';
    if (currentStatusIndex == 2) return 'Complete';
    return 'Cancel';
  }

  // 💡 Modal: Are you sure you want to cancel?
  void _showCancelModal() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                color: Color.fromRGBO(42, 35, 66, 1.0),
              ),
              child: const Text('Are you sure you want to cancel?', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF75DB73), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: () {
                      Navigator.pop(context); // ปิด Dialog
                      Navigator.pop(context, 3); // กลับไปหน้า Your Rent พร้อมสถานะ Cancel
                    },
                    child: const Text('Yes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF07B75), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('No', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // 💡 Modal: Hand in successfully
  void _showHandInSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context); // ปิด Pop up
          // พาไปหน้า Rate Vehicle
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RenterRateVehiclePage(ownerName: widget.booking['name'], imagePath: widget.booking['image'])),
          );
        });
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  color: Color.fromRGBO(172, 114, 161, 1.0),
                ),
                child: const Text('Notice', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const Padding(
                padding: EdgeInsets.all(30),
                child: Text('Send request for hand in\nsuccessfully', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Poppins', fontSize: 16)),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(widget.booking['name'], style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gallery
            Container(
              height: 180,
              color: Colors.grey[300],
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(15),
                itemCount: 3,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Image.asset(widget.booking['image'], fit: BoxFit.cover, width: 220),
                ),
              ),
            ),
            
            // 2. Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildText('License Plate', widget.booking['plate']),
                            const SizedBox(height: 15),
                            _buildText('Model', widget.booking['model']),
                            const SizedBox(height: 15),
                            _buildText('Vehicle type', widget.booking['type'] == '4 Door Car' ? 'Car' : widget.booking['type']),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildText('Brand', widget.booking['name'].toString().split("'s")[0]), // ดึงแค่ชื่อแบรนด์แบบง่ายๆ
                              ],
                            ),
                            const SizedBox(height: 25),
                            const Icon(Icons.electric_car, size: 45, color: Color.fromRGBO(7, 14, 42, 1.0)),
                            const SizedBox(height: 10),
                            // Badge Status
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: _getBadgeColor(), borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircleAvatar(radius: 4, backgroundColor: Colors.white),
                                  const SizedBox(width: 5),
                                  Text(_getStatusText(), style: const TextStyle(color: Colors.white, fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Address', style: TextStyle(fontFamily: 'Poppins', color: Colors.black)),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    color: Colors.grey.shade100,
                    child: Text(widget.booking['address'], style: const TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildText('Deposit (฿)', '1000'),
                      _buildText('Price per hour (฿)', widget.booking['price'].toString()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('Rating ', style: TextStyle(fontFamily: 'Poppins', color: Colors.black)),
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          Text(' ${widget.booking['rating']}', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Text('Comment', style: TextStyle(fontFamily: 'Poppins', decoration: TextDecoration.underline)),
                    ],
                  ),
                  
                  const SizedBox(height: 25),
                  
                  // 3. User Card (ตามรูปเป็นชื่อคนขับ)
                  RenterInfoCard(
                    name: 'Sukrit Chatchawal', // Mockup ตามรูป
                    phone: '0848978975',
                    rating: 3.0,
                    startDate: '08/02/2026',
                    endDate: '12/02/2026',
                    startTime: '12:00',
                    endTime: '14:00',
                    renterImage: 'assets/icons/avatar.jpg',
                  ),

                  // 4. ส่วนพิเศษถ้าสถานะเป็น Complete
                  if (currentStatusIndex == 2) ...[
                     const SizedBox(height: 20),
                     const Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text('picture before return', style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                         Text('price paid 9999', style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                       ],
                     ),
                     const SizedBox(height: 10),
                     SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (context, index) => Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(image: AssetImage(widget.booking['image']), fit: BoxFit.cover)
                            ),
                          ),
                        ),
                     ),
                     const SizedBox(height: 15),
                     const Text('defect', style: TextStyle(fontFamily: 'Poppins', fontSize: 14)),
                     const Divider(color: Colors.black),
                  ] else ...[
                     const SizedBox(height: 20),
                     const Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text('Price', style: TextStyle(fontFamily: 'Poppins')),
                         Text('7000', style: TextStyle(fontFamily: 'Poppins')),
                       ],
                     ),
                     const SizedBox(height: 30),
                     
                     // 5. ปุ่มกดตามสถานะ
                     SizedBox(
                       width: double.infinity,
                       height: 50,
                       child: ElevatedButton(
                         style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B66CA), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                         onPressed: () async {
                           if (currentStatusIndex == 0) { // Accept -> ไปหน้ากล้อง
                              final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const RenterTakePhotoPage()));
                              if (result == true) {
                                // ถ้าถ่ายเสร็จให้ปรับ State หน้านี้เป็น Using
                                setState(() { currentStatusIndex = 1; });
                              }
                           } else if (currentStatusIndex == 1) { // Using -> คืนรถ
                              _showHandInSuccessModal();
                           }
                         },
                         child: Text(currentStatusIndex == 0 ? 'Pick up the vehicle' : 'Hand in vehicle', style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                       ),
                     ),
                     const SizedBox(height: 15),
                     // ปุ่ม Cancel สำหรับตอน Accept
                     if (currentStatusIndex == 0)
                       Center(
                         child: GestureDetector(
                           onTap: _showCancelModal,
                           child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                         ),
                       )
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', color: Colors.black87, fontSize: 13)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontFamily: 'Poppins', color: Colors.black, fontSize: 14)),
      ],
    );
  }
}