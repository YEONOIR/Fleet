import 'package:flutter/material.dart';

class RentHistoryDetailPage extends StatelessWidget {
  final Map<String, dynamic> car;

  const RentHistoryDetailPage({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final int statusIndex = car['status'] as int;
    final String statusString = _getStatusString(statusIndex);
    final Color statusColor = _getStatusColor(statusIndex);

    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(172, 114, 161, 1.0),
                Color.fromRGBO(7, 14, 42, 1.0)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Text(
          car['name'] as String,
          style: const TextStyle(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Image Banner
                  Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: Image.asset(
                      car['image'] as String,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // 2. Info & Status Section
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoColumn('License Plate', car['plate']),
                                  const SizedBox(height: 20),
                                  _buildInfoColumn('Brand', car['name'].toString().split("'s ").last),
                                  const SizedBox(height: 20),
                                  _buildInfoColumn('Model', car['model']),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(
                                    car['fuel'].toString().toUpperCase() == 'EV'
                                        ? Icons.electric_car
                                        : Icons.local_gas_station,
                                    size: 45,
                                    color: const Color.fromRGBO(7, 14, 42, 1.0),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    car['fuel'].toString().toUpperCase() == 'EV'
                                        ? 'ENERGY'
                                        : car['fuel'].toString(),
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  _buildStatusBadge(statusString, statusColor),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn('Vehicle Type', car['type']),
                            _buildInfoColumn('Deposit (฿)', car['deposit'].toString()),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // 3. Address Section
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Address', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: Text(car['address'] as String, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // 4. Pricing & Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoColumn('Price/Hour (฿)', car['price'].toString()),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Rating', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 5),
                                    Text(
                                      car['rating'].toString(),
                                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        const Divider(height: 40),

                        // 5. ตรวจสอบสถานะ: ถ้า Cancel โชว์เหตุผล ถ้าไม่ใช่ โชว์ Booking Detail
                        if (statusString == 'CANCEL')
                          _buildCancelReason()
                        else
                          _buildBookingInfo(),

                        // แสดงรูป ก่อนเช่า แค่ในสถานะ USING กับ COMPLETE
                        if (statusString == 'USING' || statusString == 'COMPLETE')
                          _buildBeforeRentImages(),
                        
                        // 6. แสดงกล่อง Defect สำหรับสถานะ COMPLETE
                        if (statusString == 'COMPLETE')
                          _buildDefectInfo(),
                          
                        if (statusString == 'PENDING') _buildPendingInfo(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Button (ปุ่มด้านล่าง)
          if (statusString == 'ACCEPT' || statusString == 'PENDING' || statusString == 'USING')
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildActionButton(statusString),
            ),
        ],
      ),
    );
  }

  // ==========================================
  // Helper Methods
  // ==========================================

  Color _getStatusColor(int index) {
    switch (index) {
      case 0: return const Color(0xFF2E7D6E); // Accept
      case 1: return const Color.fromRGBO(172, 114, 161, 1.0); // Using
      case 2: return const Color(0xFF31A1D1); // Complete (สีฟ้า)
      case 3: return const Color(0xFFC62828); // Cancel
      case 4: return const Color(0xFFE6A817); // Pending
      default: return Colors.grey;
    }
  }

  String _getStatusString(int index) {
    switch (index) {
      case 0: return 'ACCEPT';
      case 1: return 'USING';
      case 2: return 'COMPLETE';
      case 3: return 'CANCEL';
      case 4: return 'PENDING';
      default: return 'UNKNOWN';
    }
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
  // ส่วน UI เฉพาะเจาะจง
  // ==========================================

  Widget _buildBookingInfo() {
    final booking = car['booking'];
    if (booking == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Booking Details', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ]
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoColumn('Date', '${booking['startDate']} - ${booking['endDate']}'),
                  _buildInfoColumn('Time', '${booking['startTime']} - ${booking['endTime']}'),
                ],
              ),
              const SizedBox(height: 20),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Price', style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey)),
                  Text(
                    '฿ ${booking['totalPrice']}',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromRGBO(7, 14, 42, 1.0)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 💡 อัปเดตกล่อง เหตุผลการยกเลิก ตามโค้ดต้นฉบับที่คุณให้มา
  // 💡 อัปเดตกล่อง เหตุผลการยกเลิก ให้พื้นหลังสีขาวเหมือน Booking Detail
  Widget _buildCancelReason() {
    final reason = car['cancelReason'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reason for cancellation',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white, // เปลี่ยนพื้นหลังเป็นสีขาว
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            reason ?? '-',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  // 💡 อัปเดตกล่อง Defect ให้พื้นหลังสีขาวเหมือน Booking Detail
  Widget _buildDefectInfo() {
    final defect = car['defect'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        const Text(
          'Defect',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF31A1D1)), 
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white, // เปลี่ยนพื้นหลังเป็นสีขาว
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            defect ?? '-',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildBeforeRentImages() {
    final List<String> images = car['beforeRentImages'] ?? [];
    if (images.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        const Text('Before rent', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) => Container(
              margin: const EdgeInsets.only(right: 10),
              width: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(images[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingInfo() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.hourglass_empty_rounded, size: 50, color: Color(0xFFE6A817)),
            SizedBox(height: 15),
            Text(
              'Waiting for owner confirmation\nplease wait for response',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String status) {
    if (status == 'PENDING' || status == 'ACCEPT') {
      return SizedBox(
        width: double.infinity,
        height: 55,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFC62828), 
            side: const BorderSide(color: Color(0xFFC62828)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: () {},
          child: const Text('Cancel Booking', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      );
    } else if (status == 'USING') {
      return SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(172, 114, 161, 1.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: () {},
          child: const Text('Return Vehicle', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}