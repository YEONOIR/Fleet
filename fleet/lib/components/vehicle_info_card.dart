import 'package:flutter/material.dart';

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
    // 💡 ดึง path ของรูปภาพออกมาเก็บในตัวแปร
    String imgPath = data['image'] ?? 'assets/images/car.jpg';

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
                    data['name'] ?? 'Unknown Vehicle',
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFFD700), size: 18),
                      const SizedBox(width: 5),
                      Text(
                        data['rating']?.toString() ?? '0.0', 
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
                  // 💡 แก้ไขส่วนแสดงรูปรถตรงนี้
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: imgPath.startsWith('http') 
                      // กรณีที่เป็น URL จากเน็ต
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
                      // กรณีที่เป็นรูปจากในเครื่อง (assets)
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
                            Text('License plate: ${data['plate']}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.black87)),
                            const Icon(Icons.local_gas_station_outlined, size: 20, color: Colors.black87), 
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('Model: ${data['model']}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.black87)),
                        const SizedBox(height: 2),
                        Text('Type: ${data['vType']}', style: const TextStyle(fontFamily: 'Poppins', fontSize: 12, color: Colors.black87)),
                        const SizedBox(height: 4),
                        Text(
                          data['address'] ?? '-',
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
                            Text('${data['price']} ฿ / Hr.', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
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