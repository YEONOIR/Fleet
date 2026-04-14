import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    // 1. รวมวันที่และเวลาเพื่อคำนวณ
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

    // 2. คำนวณจำนวนชั่วโมง
    final duration = endDateTime.difference(startDateTime);
    int totalHours = duration.inHours;
    if (duration.inMinutes % 60 > 0) {
      totalHours++;
    }
    if (totalHours <= 0) totalHours = 1;

    // 3. ดึงราคาและคำนวณยอดเงิน
    final double pricePerHour =
        double.tryParse(
          vehicleData['V Price']?.toString() ??
              vehicleData['price']?.toString() ??
              '0',
        ) ??
        0;
    final double deposit =
        double.tryParse(
          vehicleData['V Deposit']?.toString() ??
              vehicleData['deposit']?.toString() ??
              '1000',
        ) ??
        1000;
    final double totalRentalPrice = totalHours * pricePerHour;
    final double finalTotal = totalRentalPrice + deposit;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
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
                  // Section 1: Vehicle Info
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
                          child:
                              (vehicleData['imagePath']?.toString().startsWith(
                                    'http',
                                  ) ??
                                  false)
                              ? Image.network(
                                  vehicleData['imagePath'],
                                  width: 90,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildFallbackImage(),
                                )
                              : Image.asset(
                                  vehicleData['imagePath'] ??
                                      vehicleData['image'] ??
                                      'assets/images/car.jpg',
                                  width: 90,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildFallbackImage(),
                                ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicleData['V Name'] ??
                                    vehicleData['name'] ??
                                    'Unknown',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF070E2A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${vehicleData['V Model'] ?? '-'} • ${vehicleData['V Plate'] ?? '-'}',
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

                  // Section 2: Rental Period
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

                  // Section 3: Payment Breakdown
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

          // Section 4: Pay Now Button
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
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        bool isProcessing = false;

                        return StatefulBuilder(
                          builder: (context, setModalState) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              title: Text(
                                isProcessing
                                    ? 'Processing Payment'
                                    : 'Confirm Payment',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF070E2A),
                                ),
                              ),
                              content: isProcessing
                                  ? const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(
                                          color: Color(0xFFAC72A1),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Validating balance and booking...',
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      'Are you sure you want to proceed with the payment of ฿$finalTotal?',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                      ),
                                    ),
                              actions: isProcessing
                                  ? []
                                  : [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(dialogContext).pop(),
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
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        onPressed: () async {
                                          setModalState(
                                            () => isProcessing = true,
                                          );

                                          try {
                                            User? user = FirebaseAuth
                                                .instance
                                                .currentUser;
                                            if (user != null) {
                                              // 💡 1. ตรวจสอบยอดเงินคงเหลือของผู้ใช้ (Wallet Balance)
                                              DocumentSnapshot userDoc =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(user.uid)
                                                      .get();
                                              double currentBalance =
                                                  (userDoc['wallet_balance'] ??
                                                          0)
                                                      .toDouble();

                                              // 💡 2. ดักจับ Error ถ้าเงินไม่พอ
                                              if (currentBalance < finalTotal) {
                                                setModalState(
                                                  () => isProcessing = false,
                                                );
                                                if (dialogContext.mounted) {
                                                  ScaffoldMessenger.of(
                                                    dialogContext,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        'Insufficient balance. Please top up your wallet.',
                                                        style: TextStyle(
                                                          fontFamily: 'Poppins',
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                    ),
                                                  );
                                                }
                                                return; // หยุดทำงานทันที
                                              }

                                              // หักเงินออกจากระบบ
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(user.uid)
                                                  .update({
                                                    'wallet_balance':
                                                        FieldValue.increment(
                                                          -finalTotal,
                                                        ),
                                                  });

                                              String vehicleId =
                                                  vehicleData['id'] ?? '';
                                              String ownerId =
                                                  vehicleData['owner_id'] ?? '';

                                              if (ownerId.isEmpty &&
                                                  vehicleId.isNotEmpty) {
                                                DocumentSnapshot vDoc =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('vehicles')
                                                        .doc(vehicleId)
                                                        .get();
                                                if (vDoc.exists)
                                                  ownerId =
                                                      vDoc['owner_id'] ?? '';
                                              }

                                              // 💡 3. เขียนข้อมูลลงใน collection "bookings" ตามฟิลด์ที่คุณออกแบบเป๊ะๆ
                                              await FirebaseFirestore.instance
                                                  .collection('bookings')
                                                  .add({
                                                    'after_images': [
                                                      "",
                                                      "",
                                                      "",
                                                      "",
                                                    ],
                                                    'before_images': [
                                                      "",
                                                      "",
                                                      "",
                                                      "",
                                                    ],
                                                    'deposit_deducted': 0.0,
                                                    'deposit_paid': deposit,
                                                    'end_time':
                                                        Timestamp.fromDate(
                                                          endDateTime,
                                                        ),
                                                    'handin_defect': "",
                                                    'owner_id': ownerId,
                                                    'reject_reason': "",
                                                    'renter_id': user.uid,
                                                    'start_time':
                                                        Timestamp.fromDate(
                                                          startDateTime,
                                                        ),
                                                    'status': "pending",
                                                    'total_hours': totalHours
                                                        .toDouble(),
                                                    'total_price':
                                                        totalRentalPrice,
                                                    'vehicle_id': vehicleId,
                                                    'created_at':
                                                        FieldValue.serverTimestamp(),
                                                  });

                                              // สร้างประวัติการจ่ายเงินลง transactions
                                              await FirebaseFirestore.instance
                                                  .collection('transactions')
                                                  .add({
                                                    'user_id': user.uid,
                                                    'type': 'payment',
                                                    'amount': -finalTotal,
                                                    'timestamp':
                                                        FieldValue.serverTimestamp(),
                                                    'status': 'success',
                                                    'description':
                                                        'Booking ${vehicleData['V Name'] ?? 'Vehicle'}',
                                                  });

                                              // แจ้งเตือนไปยัง Owner
                                              if (ownerId.isNotEmpty) {
                                                await FirebaseFirestore.instance
                                                    .collection('notifications')
                                                    .add({
                                                      'user_id': ownerId,
                                                      'target_role': 'Owner',
                                                      'type': 'rent request',
                                                      'title':
                                                          'New Booking Request',
                                                      'message':
                                                          'A renter wants to book ${vehicleData['V Name'] ?? 'your vehicle'}.',
                                                      'is_read': false,
                                                      'created_at':
                                                          FieldValue.serverTimestamp(),
                                                    });
                                              }

                                              if (dialogContext.mounted) {
                                                Navigator.of(
                                                  dialogContext,
                                                ).pop();

                                               // 💡 เปลี่ยนจาก initialIndex: 4 มาเป็นการแยก 2 ตัวแบบนี้ครับ
Navigator.pushNamedAndRemoveUntil(
  context, 
  '/renter', 
  arguments: {
    'mainIndex': 1, // 1 คือเพื่อเปิดเมนูด้านล่าง "Your Rent"
    'tabIndex': 4,  // 4 คือเพื่อเปิดแท็บด้านบน "Pending"
  }, 
  (route) => false
);
                                              }
                                            }
                                          } catch (e) {
                                            setModalState(
                                              () => isProcessing = false,
                                            );
                                            if (dialogContext.mounted) {
                                              ScaffoldMessenger.of(
                                                dialogContext,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text('Error: $e'),
                                                ),
                                              );
                                            }
                                          }
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

  Widget _buildFallbackImage() => Container(
    width: 90,
    height: 70,
    color: Colors.grey.shade200,
    child: const Icon(Icons.directions_car),
  );

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
