import 'package:flutter/material.dart';

class RejectModal {
  // 💡 แก้ไข onConfirm ให้รับค่า String (เหตุผล) กลับไป
  static void show(BuildContext context, {required Function(String) onConfirm}) {
    TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Reject Request', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.redAccent)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please provide a reason for rejection:', style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 15),
                TextField(
                  controller: reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter reason here...',
                    hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade300)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.redAccent)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reason cannot be empty', style: TextStyle(fontFamily: 'Poppins')), backgroundColor: Colors.black87),
                  );
                  return;
                }
                Navigator.pop(dialogContext); 
                _showConfirm(context, reasonController.text, onConfirm); 
              },
              child: const Text('Next', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // 💡 อัปเดต onConfirm ตรงนี้ด้วย
  static void _showConfirm(BuildContext context, String reason, Function(String) onConfirm) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 10),
              Text('Confirm Rejection', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.redAccent)),
            ],
          ),
          content: SingleChildScrollView(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.black87),
                children: [
                  const TextSpan(text: 'Are you sure you want to reject this request?\n\n'),
                  const TextSpan(text: 'Reason:\n', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: '"$reason"', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pop(dialogContext); 
                onConfirm(reason); // 💡 โยนเหตุผล (reason) กลับไปให้หน้าหลัก!
              },
              child: const Text('Confirm', style: TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}