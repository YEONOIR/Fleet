import 'package:flutter/material.dart';
import 'renter_your_rent.dart';

class RentPaymentPage extends StatelessWidget {
  final Map<String, dynamic> vehicleData;
  final DateTime startDate;
  final DateTime endDate;
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  const RentPaymentPage({
    super.key,
    required this.vehicleData,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 1. รวมวันที่และเวลาเพื่อคำนวณ
    final startDateTime = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      startTime.hour,
      startTime.minute,
    );
    final endDateTime = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      endTime.hour,
      endTime.minute,
    );

    // 💡 2. คำนวณจำนวนชั่วโมง
    final duration = endDateTime.difference(startDateTime);
    int totalHours = duration.inHours;
    // ถ้ามีเศษนาที ให้ปัดขึ้นเป็น 1 ชั่วโมงเต็ม (หลักการเช่ารถทั่วไป)
    if (duration.inMinutes % 60 > 0) {
      totalHours++;
    }
    // ป้องกันกรณีเวลาติดลบหรือเป็น 0
    if (totalHours <= 0) totalHours = 1;

    // 💡 3. ดึงราคาและคำนวณยอดเงิน
    final double pricePerHour =
        double.tryParse(vehicleData['price'].toString()) ?? 0;
    final double deposit =
        double.tryParse(vehicleData['deposit'].toString()) ?? 1000;
    final double totalRentalPrice = totalHours * pricePerHour;
    final double finalTotal = totalRentalPrice + deposit;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),

      // ==========================================
      // AppBar
      // ==========================================
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFAC72A1), Color(0xFF070E2A)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: const Text(
          'Booking Summary',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==========================================
                  // Section 1: Vehicle Info Card
                  // ==========================================
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            vehicleData['image'] ?? 'assets/images/car.jpg',
                            width: 90,
                            height: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 90,
                                  height: 70,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.directions_car),
                                ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicleData['name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF070E2A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${vehicleData['model']} • ${vehicleData['plate']}',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '฿ $pricePerHour / Hr.',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFAC72A1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // ==========================================
                  // Section 2: Rental Period
                  // ==========================================
                  const Text(
                    'Rental Period',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF070E2A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildDateRow('Pick-up', startDate, startTime, context),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                        ),
                        _buildDateRow('Drop-off', endDate, endTime, context),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3E5F5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Color(0xFF7B1FA2),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Total Duration: $totalHours Hours',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF7B1FA2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // ==========================================
                  // Section 3: Payment Breakdown
                  // ==========================================
                  const Text(
                    'Payment Details',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF070E2A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildPriceRow(
                          'Rental Fee ($totalHours hrs x ฿$pricePerHour)',
                          totalRentalPrice,
                        ),
                        const SizedBox(height: 12),
                        _buildPriceRow('Refundable Deposit', deposit),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Payment',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF070E2A),
                              ),
                            ),
                            Text(
                              '฿ $finalTotal',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFAC72A1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // ==========================================
          // Section 4: Pay Now Button
          // ==========================================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF070E2A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // แสดง Modal ยืนยันการชำระเงิน
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            'Confirm Payment',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF070E2A),
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to proceed with the payment of ฿$finalTotal?',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pop(); // ปิด Modal ถ้ายกเลิก
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFAC72A1,
                                ), // ใช้สีธีมของแอป
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(); // ปิด Modal ก่อน

                                // นำทางไปยังหน้า RenterYourRentPage
                                // ใช้ pushReplacement เพื่อแทนที่หน้าปัจจุบัน ป้องกันการกดย้อนกลับมาหน้าจ่ายเงิน
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RenterYourRentPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Confirm',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Proceed to Pay  ',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '฿$finalTotal',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFAC72A1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper สำหรับวาดแถว วันที่/เวลา
  Widget _buildDateRow(
    String title,
    DateTime date,
    TimeOfDay time,
    BuildContext context,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF070E2A),
              ),
            ),
            Text(
              time.format(context),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Color(0xFFAC72A1),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper สำหรับวาดแถวแสดงราคา
  Widget _buildPriceRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Colors.grey,
          ),
        ),
        Text(
          '฿ $amount',
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF070E2A),
          ),
        ),
      ],
    );
  }
}
