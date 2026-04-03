import 'package:flutter/material.dart';
// 💡 เช็ค path ของไฟล์ search_calendar.dart และ time_selector.dart ให้ตรงกับโปรเจคของคุณนะครับ
import '../../components/search_calendar.dart'; 
import '../../components/time_selector.dart';
import 'rent_payment.dart';

class VehicleRentDetailPage extends StatelessWidget {
  final Map<String, dynamic> vehicleData;

  const VehicleRentDetailPage({super.key, required this.vehicleData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      
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
                  // =====================q=====================
                  // 2. Image Gallery (Horizontal Scroll)
                  // ==========================================
                  Container(
                    height: 140,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      itemCount: 3, 
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            vehicleData['image'] ?? 'assets/images/car.jpg', 
                            width: 130,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 130, color: Colors.grey.shade300, child: const Icon(Icons.directions_car, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ==========================================
                  // 3. Information Details
                  // ==========================================
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // -- โซนข้อมูลรถซ้าย/ขวา --
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  _buildInfoRow('License Plate', vehicleData['plate'] ?? '-'),
                                  const SizedBox(height: 12),
                                  _buildInfoRow('Model', vehicleData['model'] ?? '-'),
                                  const SizedBox(height: 12),
                                  _buildInfoRow('Vehicle type', vehicleData['vType'] ?? '-'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('Brand  ', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.black87)),
                                      Text(
                                        vehicleData['brand'] ?? vehicleData['name'].toString().split(' ').last, 
                                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  const Icon(Icons.electric_car_outlined, size: 45, color: Color(0xFF070E2A)),
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6DDA75),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircleAvatar(radius: 4, backgroundColor: Colors.white),
                                        SizedBox(width: 6),
                                        Text('Available', style: TextStyle(fontFamily: 'Poppins', fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // -- โซนที่อยู่ (Address) --
                        const Text('Address', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.black87)),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F7F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            vehicleData['address'] ?? '-', 
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 11, color: Colors.black87)
                          ),
                        ),
                        const SizedBox(height: 20),

                        // -- โซนราคา (Deposit & Price) --
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text('Deposit (฿)   ', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.black87)),
                                Text(
                                  vehicleData['deposit']?.toString() ?? '1000', 
                                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text('Price per hour (฿)   ', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.black87)),
                                Text(
                                  vehicleData['price']?.toString() ?? '-', 
                                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // -- โซนเรทติ้งและคอมเมนต์ (Rating & Comment) --
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Text('Rating', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.black87)),
                                const SizedBox(width: 10),
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  vehicleData['rating']?.toString() ?? '-', 
                                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: const Text(
                                'Comment', 
                                style: TextStyle(fontFamily: 'Poppins', fontSize: 12, decoration: TextDecoration.underline, color: Colors.black87)
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ==========================================
          // 4. Bottom Rent Button
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
                  // 💡 เรียกฟังก์ชันโชว์ Modal ปฏิทินและเวลา
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

  // Widget ตัวช่วยสำหรับสร้างแถวข้อความข้อมูลซ้ายขวาให้เป็นระเบียบ
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.black87)),
        ),
        Expanded(
          flex: 5,
          child: Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
        ),
      ],
    );
  }

  // ==========================================
  // 💡 Modal เลือกวันเช่าและเวลา (Bottom Sheet)
  // ==========================================
  void _showRentCalendarModal(BuildContext context) {
    // 💡 1. ดึงวันและเวลาปัจจุบันจากเครื่อง
    final DateTime now = DateTime.now();
    
    // 💡 2. ตั้งค่า Default ให้ startDate เป็นวันนี้
    DateTime? startDate = now;
    DateTime? endDate;
    TimeOfDay? startTime; // ไม่ตั้งค่าให้เพื่อรอดูว่าผู้ใช้จะกดเลือกไหม
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
                            // 💡 3. ไม่บังคับกรอกเวลาแล้ว แต่ยังเช็คว่าอย่างน้อยต้องมี startDate
                            if (startDate != null) {
                              
                              // ถ้าไม่ได้เลือก End Date ให้ตีซะว่าเช่าและคืนภายในวันเดียวกัน
                              DateTime finalStartDate = startDate!;
                              DateTime finalEndDate = endDate ?? finalStartDate;

                              // 💡 4. ถ้าไม่เลือกเวลา ให้ Default เป็นเที่ยงคืน (00:00)
                              TimeOfDay finalStartTime = startTime ?? const TimeOfDay(hour: 0, minute: 0);
                              TimeOfDay finalEndTime = endTime ?? const TimeOfDay(hour: 0, minute: 0);

                              Navigator.pop(context); // ปิด Modal ปฏิทิน
                              
                              // เปลี่ยนหน้าไป Payment
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