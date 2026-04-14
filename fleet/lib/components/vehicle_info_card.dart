import 'package:flutter/material.dart';
// 💡 1. นำเข้า vehicle_utils.dart เพื่อใช้งานฟังก์ชัน getFuelIcon (ปรับ Path ให้ตรงกับโปรเจกต์ของคุณ)
import '../../utils/vehicle_utils.dart'; 

class VehicleInfoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback? onTap;

  const VehicleInfoCard({
    super.key, 
    required this.data, 
    this.onTap, 
  });

  @override
  Widget build(BuildContext context) {
    // 💡 2. เปลี่ยนมาใช้ Key ที่ถูกต้อง (มี V นำหน้า หรือ imagePath) 
    // โดยยังคงเผื่อ Fallback ไว้กันเหนียวเผื่อบางหน้าส่ง data มาแบบเก่า
    String imgPath = data['imagePath'] ?? data['image'] ?? 'assets/images/car.jpg';
    String vName = data['V Name'] ?? data['name'] ?? 'Unknown Vehicle';
    String vRate = (data['V_Rate'] ?? data['rating'] ?? 0.0).toString();
    String vPlate = data['V Plate'] ?? data['plate'] ?? '-';
    String vModel = data['V Model'] ?? data['model'] ?? '-';
    String vType = data['V Type'] ?? data['vType'] ?? '-';
    String vAddress = data['V Address'] ?? data['address'] ?? 'No address provided';
    String vPrice = (data['V Price'] ?? data['price'] ?? 0).toString();
    String vFuel = data['V Fuel'] ?? data['fuel'] ?? ''; // ดึงข้อมูลเชื้อเพลิงมาเผื่อแปลงเป็นไอคอน

    return GestureDetector(
      onTap: onTap, 
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color.fromRGBO(172, 114, 161, 0.6), 
            width: 1.5,
          ), 
        ),
        child: Column(
          children: [
            // 1. ส่วนหัว (สีม่วงเข้ม)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(42, 35, 66, 1.0),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    vName, // 💡 ใช้ตัวแปร vName ที่ดึงมาอย่างถูกต้องแล้ว
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFD700), size: 18),
                      const SizedBox(width: 5),
                      Text(
                        vRate, 
                        style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 2. ส่วนเนื้อหา
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imgPath.startsWith('http') 
                      ? Image.network(
                          imgPath,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 100, 
                            height: 100, 
                            color: Colors.grey.shade200, 
                            child: const Icon(Icons.directions_car, color: Colors.grey)
                          ),
                        )
                      : Image.asset(
                          imgPath,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 100, 
                            height: 100, 
                            color: Colors.grey.shade200, 
                            child: const Icon(Icons.directions_car, color: Colors.grey)
                          ),
                        ),
                  ),
                  const SizedBox(width: 15),

                  // ข้อมูลรถด้านขวา
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('License plate: $vPlate', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.black87)),
                            // 💡 3. นำฟังก์ชัน getFuelIcon มาครอบตัวแปร vFuel เพื่อให้แสดงผลลัพธ์เป็นไอคอนที่ถูกต้อง
                            Icon(getFuelIcon(vFuel), size: 20, color: Colors.black87), 
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Model: $vModel', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.black87)),
                        const SizedBox(height: 2),
                        Text('Type: $vType', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text(
                          vAddress, // 💡 ใช้ตัวแปร vAddress ที่ดึงมาอย่างถูกต้องแล้ว
                          style: const TextStyle(fontFamily: 'Poppins', fontSize: 10, color: Colors.black54),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // ราคา
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text('Price  ', style: TextStyle(fontFamily: 'Poppins', fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                            Text('$vPrice ฿ / Hr.', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}