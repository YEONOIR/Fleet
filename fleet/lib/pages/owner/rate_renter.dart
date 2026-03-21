import 'package:flutter/material.dart';

class RateRenterPage extends StatefulWidget {
  const RateRenterPage({super.key});

  @override
  State<RateRenterPage> createState() => _RateRenterPageState();
}

class _RateRenterPageState extends State<RateRenterPage> {
  int _rating = 5; // เริ่มต้นให้ 5 ดาว

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // เอาปุ่ม Back ออก เพราะคืนรถเสร็จแล้ว
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/icons/avatar.jpg'), // 💡 รูป Mockup ตามเดิม
            ),
            const SizedBox(height: 20),
            const Text(
              'Rate the Renter', 
              style: TextStyle(fontFamily: 'Poppins', fontSize: 22, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            const Text(
              'How was your experience renting to Sukrit Chatchawal?', 
              textAlign: TextAlign.center, 
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.grey)
            ),
            const SizedBox(height: 40), // เพิ่มระยะห่างให้ดูโปร่งขึ้น

            // ==========================================
            // 💡 จำลองปุ่มให้ดาว (กดเปลี่ยนสีได้)
            // ==========================================
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 45, // ปรับขนาดดาวให้ใหญ่ขึ้นนิดนึงชดเชยพื้นที่ช่องคอมเมนต์ที่หายไป
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            
            const SizedBox(height: 60), // ดันปุ่มลงไปด้านล่างนิดนึงให้ Layout สวยงาม

            // ==========================================
            // 💡 ปุ่ม Submit และ Skip
            // ==========================================
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(7, 14, 42, 1.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  // TODO: ส่งค่า _rating เข้า Database ตรงนี้
                  
                  // กลับไปหน้า Home แบบเคลียร์ History (ไม่ให้กดย้อนกลับมาหน้านี้ได้อีก)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Submit Review', style: TextStyle(fontFamily: 'Poppins', fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                 // ถ้ากด Skip ก็กลับหน้า Home เลยเหมือนกัน
                 Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Skip', style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.w600)),
            )
          ],
        ),
      ),
    );
  }
}