import 'package:flutter/material.dart';

class RenterPaymentPage extends StatelessWidget {
  final Map<String, dynamic> car;
  final DateTime startDate;
  final DateTime endDate;

  const RenterPaymentPage({super.key, required this.car, required this.startDate, required this.endDate});

  // 💡 Pop-up คำถามยืนยัน
  void _showConfirmationDialog(BuildContext context) {
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
                padding: const EdgeInsets.all(15),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  gradient: LinearGradient(
                    colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
                  ),
                ),
                child: const Text(
                  "Are you sure you want to rent?",
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
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF75DB73), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: () {
                        Navigator.pop(dialogContext); // ปิด Pop-up คำถาม
                        _showSuccessDialog(context); // โชว์ Pop-up สำเร็จ
                      },
                      child: const Text("Yes", style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF07B75), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text("No", style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
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

  // 💡 Pop-up แจ้งว่าส่งคำขอสำเร็จ
  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context); // ปิด Pop-up success
          Navigator.pop(context, true); // ปิดหน้า Payment และส่งค่า true กลับไปหน้า Car Detail
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
                  "Send request for rent successfully",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // คำนวณเวลาและราคาสมมติ
    int diffHours = endDate.difference(startDate).inHours > 0 ? endDate.difference(startDate).inHours : 24; 
    int days = diffHours ~/ 24;
    int remHours = diffHours % 24;
    int deposit = 1000;
    int rentPrice = diffHours * (car['price'] as int);
    int totalPrice = deposit + rentPrice;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Payment", style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Rent", style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // 💡 Card สรุปข้อมูลรถ
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color.fromRGBO(172, 114, 161, 0.5), width: 1.5),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(7, 14, 42, 1.0),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(car['name'], style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.yellow, size: 16),
                            const SizedBox(width: 5),
                            Text(car['rating'].toString(), style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(car['image'] ?? 'assets/images/car.jpg', width: 80, height: 80, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("License plate: ${car['plate']}", style: const TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                                  const Icon(Icons.electric_car, size: 24, color: Color.fromRGBO(7, 14, 42, 1.0)),
                                ],
                              ),
                              Text("Model: ${car['model']}", style: const TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                              Text("Type: ${car['type']}", style: const TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                              Text(car['address'], style: const TextStyle(fontFamily: 'Poppins', fontSize: 9, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text("Price  ${car['price']} ฿ / Hr.", style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("From", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)), Text("${startDate.day}/${startDate.month}/${startDate.year}"), const Text("12:00")]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("To", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)), Text("${endDate.day}/${endDate.month}/${endDate.year}"), const Text("14:00")]),
            const SizedBox(height: 30),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text("Total hour", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)), Text("$days days and $remHours hours")]),
            Align(alignment: Alignment.centerRight, child: Text("= $diffHours hours", style: const TextStyle(fontFamily: 'Poppins'))),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
                const Text("Total price", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)), 
                Text("$totalPrice ฿", style: const TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.bold)), 
                Text("= $deposit + $rentPrice", style: const TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 12))
              ]
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(172, 114, 161, 1.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showConfirmationDialog(context),
                child: const Text("Pay", style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}