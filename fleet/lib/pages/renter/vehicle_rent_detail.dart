import 'package:flutter/material.dart';
// 💡 เช็ค path ของไฟล์ search_calendar.dart และ time_selector.dart ให้ตรงกับโปรเจคของคุณนะครับ
import '../../components/search_calendar.dart'; 
import '../../components/time_selector.dart';
import 'rent_payment.dart';
import '../review_page.dart';

class VehicleRentDetailPage extends StatelessWidget {
  final Map<String, dynamic> vehicleData;

  const VehicleRentDetailPage({super.key, required this.vehicleData});

  @override
  Widget build(BuildContext context) {
    // 💡 เปลี่ยนสีพื้นหลังให้เหมือนหน้า Vehicle Detail เพื่อความคลุมโทน
    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      
      // ==========================================
      // 1. AppBar (Gradient + Title)
      // ==========================================
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
        title: Text(
          vehicleData['name'] ?? 'Vehicle Detail', 
          style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)
        ),
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
                  // ==========================================
                  // 2. Image Gallery (รูปแบบใหม่ใหญ่ขึ้น)
                  // ==========================================
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(15),
                      itemCount: 3,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            vehicleData['image'] ?? 'assets/images/car.jpg', 
                            fit: BoxFit.cover, 
                            width: 250,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 250, color: Colors.grey.shade200, child: const Icon(Icons.directions_car, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ==========================================
                  // 3. Information Details (UI แบบใหม่)
                  // ==========================================
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // -- โซนข้อมูลรถ และ ไอคอนพลังงาน --
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoColumn('License Plate', vehicleData['plate'] ?? '-'),
                                  const SizedBox(height: 20),
                                  _buildInfoColumn('Brand', vehicleData['brand'] ?? vehicleData['name'].toString().split(' ').last),
                                  const SizedBox(height: 20),
                                  _buildInfoColumn('Model', vehicleData['model'] ?? '-'),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Icon(Icons.electric_car, size: 45, color: Color.fromRGBO(7, 14, 42, 1.0)),
                                  const SizedBox(height: 5),
                                  const Text('ENERGY', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                  const SizedBox(height: 15),
                                  _buildStatusBadge('Available', const Color(0xFF6DDA75)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // -- โซนประเภทรถ, เรทติ้ง และ คอมเมนต์ (ปรับใหม่) --
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoColumn('Vehicle Type', vehicleData['vType'] ?? '-'),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Rating', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 5),
                                    Text(vehicleData['rating']?.toString() ?? '-', style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 15), // ระยะห่างระหว่างเรทติ้งกับปุ่ม Comment
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => const FleetEntityReviewPage(
                                            isCar: true, 
                                            entityName: 'Vehicle Reviews'
                                          )
                                        ));
                                      },
                                      child: const Text(
                                        'Comment', 
                                        style: TextStyle(
                                          fontFamily: 'Poppins', 
                                          fontSize: 13, 
                                          decoration: TextDecoration.underline, 
                                          color: Color.fromRGBO(172, 114, 161, 1.0), // 💡 สีม่วงตามที่ต้องการ
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

                        // -- โซนที่อยู่ (Address) --
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Address', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: Text(vehicleData['address'] ?? '-', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // -- โซนมัดจำ และ ราคา (ย้ายมาอยู่คู่กัน) --
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn('Deposit (฿)', vehicleData['deposit']?.toString() ?? '1000'),
                            _buildInfoColumn('Price/Hour (฿)', vehicleData['price']?.toString() ?? '-'),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // 4. Bottom Rent Button (คงไว้เหมือนเดิม)
          // ==========================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A65C8), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: () {
                  _showRentCalendarModal(context);
                },
                child: const Text(
                  'Rent', 
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 💡 Helper Widgets 
  // ==========================================
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
  // 💡 Modal เลือกวันเช่าและเวลา (คงเดิมไม่แตะต้อง)
  // ==========================================
  void _showRentCalendarModal(BuildContext context) {
    final DateTime now = DateTime.now();
    DateTime? startDate = now;
    DateTime? endDate;
    TimeOfDay? startTime; 
    TimeOfDay? endTime;   
    DateTime calendarMonth = DateTime(now.year, now.month, 1); 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            
            void handleDateTap(DateTime date) {
              setModalState(() {
                if (startDate == null || (startDate != null && endDate != null)) {
                  startDate = date;
                  endDate = null;
                } else {
                  if (date.isBefore(startDate!)) {
                    endDate = startDate;
                    startDate = date;
                  } else {
                    endDate = date;
                  }
                }
              });
            }

            return Container(
              padding: const EdgeInsets.only(top: 15, bottom: 30),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(248, 248, 250, 1.0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 45, height: 5,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 20),
                    const Text('Select Rental Period', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF070E2A))),
                    const SizedBox(height: 10),
                    
                    SearchCalendar(
                      startDate: startDate,
                      endDate: endDate,
                      calendarMonth: calendarMonth,
                      onDateTap: handleDateTap,
                      onMonthChanged: (month) => setModalState(() => calendarMonth = month),
                    ),

                    const SizedBox(height: 10),
                    TimeSelector(
                      startTime: startTime,
                      endTime: endTime,
                      onStartTimeSelected: (time) => setModalState(() => startTime = time),
                      onEndTimeSelected: (time) => setModalState(() => endTime = time),
                    ),
                    const SizedBox(height: 25),
                    
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6A65C8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          onPressed: () {
                            if (startDate != null) {
                              DateTime finalStartDate = startDate!;
                              DateTime finalEndDate = endDate ?? finalStartDate;
                              TimeOfDay finalStartTime = startTime ?? const TimeOfDay(hour: 0, minute: 0);
                              TimeOfDay finalEndTime = endTime ?? const TimeOfDay(hour: 0, minute: 0);

                              Navigator.pop(context); 
                              
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RentPaymentPage(
                                    vehicleData: vehicleData,
                                    startDate: finalStartDate,
                                    endDate: finalEndDate,
                                    startTime: finalStartTime,
                                    endTime: finalEndTime,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please select a Date.')),
                              );
                            }
                          },
                          child: const Text('Confirm', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}