import 'package:flutter/material.dart';
import '../../utils/vehicle_utils.dart';
import 'renter_comments.dart';
import 'renter_payment.dart';

class RenterCarDetailPage extends StatefulWidget {
  final Map<String, dynamic> car;

  const RenterCarDetailPage({super.key, required this.car});

  @override
  State<RenterCarDetailPage> createState() => _RenterCarDetailPageState();
}

class _RenterCarDetailPageState extends State<RenterCarDetailPage> {
  bool isPending = false;
  DateTime? startDate;
  DateTime? endDate;

  // 💡 1. Pop-up เลือกวันที่ (ของเดิม)
  void _showDateSelectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                      gradient: LinearGradient(
                        colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: const Text(
                      "Select Date and time",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Column(
                      children: [
                        _buildDateRow("Start date", startDate, () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) setStateDialog(() => startDate = picked);
                        }),
                        const SizedBox(height: 20),
                        _buildDateRow("End date", endDate, () async {
                          DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: startDate ?? DateTime.now(),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) setStateDialog(() => endDate = picked);
                        }),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF07B75), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel", style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF75DB73), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                              onPressed: () {
                                if (startDate != null && endDate != null) {
                                  Navigator.pop(context);
                                  _navigateToPayment();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both start and end dates.')));
                                }
                              },
                              child: const Text("Select", style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildDateRow(String label, DateTime? date, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 15)),
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Text(date != null ? "${date.day}/${date.month}/${date.year}" : "Select ", style: const TextStyle(fontFamily: 'Poppins', color: Colors.black54)),
              const SizedBox(width: 8),
              const Icon(Icons.calendar_today_outlined, size: 20),
            ],
          ),
        )
      ],
    );
  }

  void _navigateToPayment() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RenterPaymentPage(car: widget.car, startDate: startDate!, endDate: endDate!),
      ),
    );

    if (result == true) {
      setState(() {
        isPending = true;
      });
    }
  }

  // =======================================================
  // 💡 ฟังก์ชันใหม่สำหรับระบบ Cancel (เพิ่มตามรูปภาพ)
  // =======================================================

  // Pop-up 1: ถามว่าแน่ใจไหมที่จะยกเลิก
  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
                  ),
                ),
                child: const Text(
                  "Are you sure you want to cancel?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF75DB73), // สีเขียว
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext); // ปิด Pop-up ถาม
                        _showReasonDialog(); // เปิด Pop-up ให้ใส่เหตุผล
                      },
                      child: const Text("Yes", style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF07B75), // สีแดง
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text("No", style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // Pop-up 2: ให้ใส่เหตุผลที่ยกเลิก
  void _showReasonDialog() {
    TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
                  ),
                ),
                child: const Text(
                  "Can you give a reason why you cancel?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    TextField(
                      controller: reasonController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF07B75), // สีแดง
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text("cancel", style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF75DB73), // สีเขียว
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                          ),
                          onPressed: () {
                            // TODO: คุณสามารถเอา reasonController.text ไปส่งขึ้น Backend ได้ตรงนี้
                            Navigator.pop(dialogContext); // ปิด Pop-up เหตุผล
                            _showCancelSuccessDialog(); // เปิด Pop-up สำเร็จ
                          },
                          child: const Text("OK", style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // Pop-up 3: แจ้งว่ายกเลิกสำเร็จ
  void _showCancelSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(dialogContext); // ปิด Dialog อัตโนมัติใน 2 วินาที
          setState(() {
            isPending = false; // 💡 รีเซ็ตสถานะกลับมาเป็นปกติ (ปุ่ม Rent จะกลับมา)
          });
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
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
                  ),
                ),
                child: const Text(
                  "Notice",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(30.0),
                child: Text(
                  "Cancel Successfully",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 15),
                ),
              )
            ],
          ),
        );
      },
    );
  }
  // =======================================================

  @override
  Widget build(BuildContext context) {
    String mockImage = widget.car['image'] ?? 'assets/images/car.jpg';

    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.car['name'], style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              color: Colors.grey[300],
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(15),
                itemCount: 3,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(mockImage, fit: BoxFit.cover, width: 220),
                  ),
                ),
              ),
            ),
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
                            _buildInfoText('License Plate', widget.car['plate']),
                            const SizedBox(height: 15),
                            _buildInfoText('Brand', widget.car['name'].toString().split("'s ").last),
                            const SizedBox(height: 15),
                            _buildInfoText('Model', widget.car['model']),
                            const SizedBox(height: 15),
                            _buildInfoText('Vehicle type', widget.car['type']),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Icon(getFuelIcon(widget.car['type']), size: 50, color: const Color.fromRGBO(7, 14, 42, 1.0)),
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: isPending ? const Color(0xFFD39A3D) : const Color(0xFF75DB73),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircleAvatar(radius: 4, backgroundColor: Colors.white),
                                  const SizedBox(width: 5),
                                  Text(isPending ? "Pending" : "Available", style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Address", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 13)),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: Text(widget.car['address'], style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoText('Deposit (฿)', '1000'),
                      _buildInfoText('Price per hour (฿)', widget.car['price'].toString()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text("Rating ", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          Text(" ${widget.car['rating']}", style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => RenterCommentsPage(car: widget.car)));
                        },
                        child: const Text("Comment", style: TextStyle(fontFamily: 'Poppins', decoration: TextDecoration.underline, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      )
                    ],
                  ),
                  if (isPending) ...[
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                         Text("Price", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
                         Text("7000", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    )
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isPending
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Please wait for rental to accept your\nrequest...", 
                    textAlign: TextAlign.center, 
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87)
                  ),
                  const SizedBox(height: 10),
                  // 💡 เปลี่ยนมาเรียกฟังก์ชัน pop-up แทน และเติมเส้นใต้ให้ปุ่ม Cancel เหมือนในรูป
                  TextButton(
                    onPressed: _showCancelConfirmationDialog, 
                    child: const Text(
                      "Cancel", 
                      style: TextStyle(
                        fontFamily: 'Poppins', 
                        color: Colors.black, 
                        fontSize: 16, 
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline, // เพิ่มขีดเส้นใต้
                      )
                    ),
                  )
                ],
              )
            : SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B66CA), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _showDateSelectionDialog,
                  child: const Text("Rent", style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
      ),
    );
  }

  Widget _buildInfoText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
} 