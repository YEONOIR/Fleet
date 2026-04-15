import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import '../../components/search_calendar.dart'; 
import '../../components/time_selector.dart';
import '../../utils/vehicle_utils.dart'; 
import 'rent_payment.dart';
import '../review_page.dart';

class VehicleRentDetailPage extends StatelessWidget {
  final Map<String, dynamic> vehicleData;

  const VehicleRentDetailPage({super.key, required this.vehicleData});

  @override
  Widget build(BuildContext context) {
    List<dynamic> galleryImages = (vehicleData['images'] != null && (vehicleData['images'] as List).isNotEmpty)
        ? vehicleData['images'] 
        : [vehicleData['imagePath'] ?? 'assets/images/car.jpg'];

    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
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
          vehicleData['V Name'] ?? 'Vehicle Detail', 
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
                  // Image Gallery 
                  // ==========================================
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(15),
                      itemCount: galleryImages.length,
                      itemBuilder: (context, index) {
                        String imgPath = galleryImages[index].toString();
                        return Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: imgPath.startsWith('http')
                                ? Image.network(imgPath, fit: BoxFit.cover, width: 250, errorBuilder: (ctx, err, stack) => Container(width: 250, color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey)))
                                : Image.asset(imgPath, fit: BoxFit.cover, width: 250, errorBuilder: (ctx, err, stack) => Container(width: 250, color: Colors.grey.shade200, child: const Icon(Icons.directions_car, color: Colors.grey))),
                          ),
                        );
                      }
                    ),
                  ),

                  // ==========================================
                  // Information Details 
                  // ==========================================
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoColumn('License Plate', vehicleData['V Plate'] ?? '-'),
                                  const SizedBox(height: 20),
                                  _buildInfoColumn('Brand', vehicleData['V Brand'] ?? '-'),
                                  const SizedBox(height: 20),
                                  _buildInfoColumn('Model', vehicleData['V Model'] ?? '-'),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(getFuelIcon(vehicleData['V Fuel'] ?? ''), size: 45, color: const Color.fromRGBO(7, 14, 42, 1.0)),
                                  const SizedBox(height: 5),
                                  Text(
                                    vehicleData['V Fuel']?.toString().toUpperCase() == 'EV' ? 'ENERGY' : (vehicleData['V Fuel'] ?? 'FUEL').toString().toUpperCase(),
                                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)
                                  ),
                                  const SizedBox(height: 15),
                                  _buildStatusBadge('Available', const Color(0xFF6DDA75)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoColumn('Vehicle Type', vehicleData['V Type'] ?? '-'),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Rating', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 5),
                                    Text(vehicleData['V_Rate']?.toString() ?? '0.0', style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 15), 
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => FleetEntityReviewPage( // 💡 เอา const ออก
                                          isCar: true, 
                                          entityName: 'Vehicle Reviews',
                                          targetId: vehicleData['id'] ?? vehicleData['vehicle_id'] ?? '', // 💡 เพิ่มบรรทัดนี้
                                        )));
                                      },
                                      child: const Text('Comment', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, decoration: TextDecoration.underline, color: Color.fromRGBO(172, 114, 161, 1.0), fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Address', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: Text(vehicleData['V Address'] ?? '-', style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn('Deposit (฿)', vehicleData['V Deposit']?.toString() ?? '0'),
                            _buildInfoColumn('Price/Hour (฿)', vehicleData['V Price']?.toString() ?? '-'),
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
          // Bottom Rent Button
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
                child: const Text('Rent', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
  // Modal เลือกวันเช่าและเวลา พร้อมเช็คคิว
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
                          onPressed: () async {
                            if (startDate != null) {
                              DateTime finalStartDate = startDate!;
                              DateTime finalEndDate = endDate ?? finalStartDate;
                              TimeOfDay finalStartTime = startTime ?? const TimeOfDay(hour: 0, minute: 0);
                              TimeOfDay finalEndTime = endTime ?? const TimeOfDay(hour: 0, minute: 0);

                              // 💡 1. รวมวันที่และเวลาเพื่อใช้เปรียบเทียบ
                              final newStart = DateTime(finalStartDate.year, finalStartDate.month, finalStartDate.day, finalStartTime.hour, finalStartTime.minute);
                              final newEnd = DateTime(finalEndDate.year, finalEndDate.month, finalEndDate.day, finalEndTime.hour, finalEndTime.minute);

                              // 💡 2. ดักจับเวลาผิดพลาดเป็น Popup (เวลาคืนรถต้องมากกว่าเวลารับรถเสมอ)
                              if (newEnd.isBefore(newStart) || newEnd.isAtSameMomentAs(newStart)) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) => AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    title: const Row(
                                      children: [
                                        Icon(Icons.access_time, color: Colors.redAccent, size: 28),
                                        SizedBox(width: 10),
                                        Text('Invalid Time', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 18)),
                                      ],
                                    ),
                                    content: const Text(
                                      'End time must be after start time.\nPlease adjust your rental period.',
                                      style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                                    ),
                                    actions: [
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12)),
                                          onPressed: () => Navigator.pop(dialogContext),
                                          child: const Text('OK', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                return;
                              }

                              // แสดงวงแหวนโหลดขณะเช็คคิว
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFFAC72A1))),
                              );

                              try {
                                String vId = vehicleData['id'] ?? '';
                                bool isOverlap = false;

                                // 💡 3. ดึงคิวทั้งหมดของรถคันนี้ ที่สถานะเป็นกำลังรอ/กำลังใช้งาน
                                QuerySnapshot bookingsSnap = await FirebaseFirestore.instance
                                    .collection('bookings')
                                    .where('vehicle_id', isEqualTo: vId)
                                    .where('status', whereIn: ['pending', 'accept', 'accepted', 'using']) 
                                    .get();

                                // 💡 4. วนลูปเช็คว่าเวลาไปทับซ้อนกับใครไหม
                                for(var doc in bookingsSnap.docs) {
                                  var data = doc.data() as Map<String, dynamic>;
                                  Timestamp? existingStartTs = data['start_time'];
                                  Timestamp? existingEndTs = data['end_time'];

                                  if (existingStartTs != null && existingEndTs != null) {
                                    DateTime existingStart = existingStartTs.toDate();
                                    DateTime existingEnd = existingEndTs.toDate();

                                    // สูตรเช็ค Overlap: (เริ่มใหม่ < จบเก่า) AND (จบใหม่ > เริ่มเก่า)
                                    if (newStart.isBefore(existingEnd) && newEnd.isAfter(existingStart)) {
                                      isOverlap = true;
                                      break; 
                                    }
                                  }
                                }

                                Navigator.pop(context); // ปิดหน้าโหลด

                                // 💡 5. ถ้าคิวชนกัน ให้เด้งเป็น Popup กลางจอแทน เพื่อไม่ให้ Modal ปฏิทินบัง
                                if (isOverlap) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext dialogContext) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      title: const Row(
                                        children: [
                                          Icon(Icons.event_busy, color: Colors.redAccent, size: 28),
                                          SizedBox(width: 10),
                                          Text('Time Unavailable', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.redAccent, fontSize: 18)),
                                        ],
                                      ),
                                      content: const Text(
                                        'This vehicle is already booked for the selected time.\nPlease choose another time.',
                                        style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                                      ),
                                      actions: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                            ),
                                            onPressed: () => Navigator.pop(dialogContext), // ปิดแค่ Dialog
                                            child: const Text('OK', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  return; // หยุดการทำงาน ไม่ไปหน้าถัดไป
                                }

                                // 💡 6. ถ้าคิวว่างผ่านฉลุย ปิด Modal ปฏิทินและไปหน้าจ่ายเงิน
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

                              } catch (e) {
                                Navigator.pop(context); // ปิดหน้าโหลด
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error checking availability: $e')));
                              }
                            } else {
                              // 💡 เปลี่ยนแจ้งเตือนไม่ได้เลือกวันเป็น Popup
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  title: const Row(
                                    children: [
                                      Icon(Icons.calendar_today, color: Colors.orange, size: 28),
                                      SizedBox(width: 10),
                                      Text('Date Required', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 18)),
                                    ],
                                  ),
                                  content: const Text(
                                    'Please select a start date for your rental period.',
                                    style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                                  ),
                                  actions: [
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(vertical: 12)),
                                        onPressed: () => Navigator.pop(dialogContext),
                                        child: const Text('OK', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
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