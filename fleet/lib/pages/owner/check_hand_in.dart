import 'dart:io';
import 'package:flutter/material.dart';
import 'rate_renter.dart';

class CheckHandInPage extends StatefulWidget {
  final String vehicleName;
  final List<File> afterImages; // 💡 รับรูป 4 รูปมาจากหน้า TakePhotoPage

  const CheckHandInPage({
    super.key, 
    required this.vehicleName, 
    required this.afterImages,
  });

  @override
  State<CheckHandInPage> createState() => _CheckHandInPageState();
}

class _CheckHandInPageState extends State<CheckHandInPage> {
  bool hasDefect = false; 
  TextEditingController defectController = TextEditingController();

  List<String> beforeImages = [
    'assets/images/car.jpg', 
    'assets/images/car.jpg',
    'assets/images/car.jpg',
    'assets/images/car.jpg',
  ];

  // แถบรูปภาพ Before Rent
  Widget _buildBeforeRentImages() {
    return Container(
      width: double.infinity,
      color: Colors.grey[200], 
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, 
        child: Row(
          children: beforeImages.map((imgPath) {
            return Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Image.asset(imgPath, width: 100, height: 100, fit: BoxFit.cover),
            );
          }).toList(),
        ),
      ),
    );
  }

  // 💡 แถบรูปภาพ After Rent (แค่ดึงมาแสดงผล ไม่ต้องมีปุ่มกล้องแล้ว)
  Widget _buildAfterRentImages() {
    return Container(
      width: double.infinity,
      color: Colors.grey[200], 
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: widget.afterImages.map((imageFile) {
            return Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Image.file(imageFile, width: 100, height: 100, fit: BoxFit.cover), // แสดงรูปจาก File
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
            ),
          ),
        ),
        title: const Text('Check hand in', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
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
                  const Padding(padding: EdgeInsets.all(20.0), child: Text('Before rent', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold))),
                  _buildBeforeRentImages(),

                  const Padding(padding: EdgeInsets.all(20.0), child: Text('After rent', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold))),
                  _buildAfterRentImages(),

                  // Inspection Section
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Inspection', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),

                        CheckboxListTile(
                          title: const Text('Report Defect / Damage', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.redAccent)),
                          subtitle: const Text('Check this if the vehicle has new damages.', style: TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                          value: hasDefect,
                          activeColor: Colors.redAccent,
                          onChanged: (bool? value) {
                            setState(() { hasDefect = value ?? false; });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                        ),

                        if (hasDefect) ...[
                          const SizedBox(height: 10),
                          TextField(
                            controller: defectController,
                            maxLines: 4,
                            style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Describe the defect (e.g., Scratch on front bumper)...',
                              hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.grey),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.redAccent), borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF75DB73),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _handleConfirm,
                child: const Text('Confirm', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleConfirm() {
    if (hasDefect && defectController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide details of the defects.', style: TextStyle(fontFamily: 'Poppins')), backgroundColor: Colors.redAccent));
      return;
    }

    if (hasDefect) {
      _showDeductModal(); 
    } else {
      _finishHandIn(); 
    }
  }

  void _showDeductModal() {
    TextEditingController deductController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Deduct Deposit', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.redAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the amount to deduct from the renter\'s deposit.', style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
            const SizedBox(height: 15),
            TextField(controller: deductController, keyboardType: TextInputType.number, style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold), decoration: InputDecoration(suffixText: '฿', hintText: '0.00', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () { Navigator.pop(context); _finishHandIn(); },
            child: const Text('Confirm', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _finishHandIn() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vehicle returned successfully!'), backgroundColor: Colors.green));
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RateRenterPage()));
    });
  }
}