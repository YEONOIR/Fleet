import 'dart:io';
import 'package:flutter/material.dart';
// 💡 เปลี่ยน Path นี้ให้ตรงกับที่เก็บไฟล์ reject_modal.dart ของคุณนะ
import '../../components/reject_modal.dart'; 

class CheckVehiclePage extends StatelessWidget {
  final String vehicleName;
  final List<String> ownerImages; // รูปภาพจาก Owner (เช่นจาก Asset หรือ Network)
  final List<File> staffImages;   // รูปภาพที่ Staff เพิ่งถ่ายมา (จากไฟล์ take_photo)

  const CheckVehiclePage({
    super.key,
    required this.vehicleName,
    required this.ownerImages,
    required this.staffImages,
  });

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Check Vehicle', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. สไลด์รูปของ Owner
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Photos from Owner', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: ownerImages.isEmpty ? 1 : ownerImages.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            ownerImages.isNotEmpty ? ownerImages[index] : 'assets/images/car.jpg',
                            fit: BoxFit.cover,
                            width: 250,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),

                  // 2. สไลด์รูปของ Staff (ถ่ายล่าสุด)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Latest Condition (Staff)', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: staffImages.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            staffImages[index],
                            fit: BoxFit.cover,
                            width: 250,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. แถบปุ่มด้านล่าง
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.red.shade400, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        // 💡 เรียกใช้ Modal ที่เราหั่นออกมา
                        RejectModal.show(
                          context, 
                          onConfirm: () {
                            // pop จนกว่าจะถึงหน้าแรกสุด (หน้า Staff Home)
                            Navigator.popUntil(context, (route) => route.isFirst);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Request has been rejected.', style: TextStyle(fontFamily: 'Poppins')),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        );
                      },
                      child: Text('Reject', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.red.shade400, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CA0E6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // pop จนกว่าจะถึงหน้าแรกสุด
                        Navigator.popUntil(context, (route) => route.isFirst);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Vehicle added successfully!', style: TextStyle(fontFamily: 'Poppins')),
                            backgroundColor: Color(0xFF4CA0E6),
                          ),
                        );
                      },
                      child: const Text('Confirm Add', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}