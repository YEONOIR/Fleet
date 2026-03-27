import 'package:flutter/material.dart';
import '../utils/vehicle_utils.dart'; // 👈 อย่าลืม import ไฟล์ utility ที่เราสร้างไว้นะครับ

class VehicleMiniCard extends StatelessWidget {
  final String vName;
  final double vRate;
  final String imagePath;
  final String vPlate;
  final String vBrand;
  final String vModel;
  final String vType;
  final String vFuel; // เราจะใช้ตัวนี้ไปหา Icon
  final String vAddress;
  final double vPrice;

  const VehicleMiniCard({
    super.key,
    required this.vName,
    required this.vRate,
    required this.imagePath,
    required this.vPlate,
    required this.vBrand,
    required this.vModel,
    required this.vType,
    required this.vFuel,
    required this.vAddress,
    required this.vPrice,
    // 💡 เอา typeIcon ออกจาก constructor เพราะเราจะให้มันหาเองข้างใน
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color.fromRGBO(172, 114, 161, 0.5)),
      ),
      child: Column(
        children: [
          // ส่วน Header ของการ์ด (ชื่อรถ + Rating)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(42, 35, 66, 1.0),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(13), topRight: Radius.circular(13)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(vName, style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 16),
                    const SizedBox(width: 4),
                    Text(vRate.toStringAsFixed(1), style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset(imagePath, width: 80, height: 80, fit: BoxFit.cover)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Plate: $vPlate', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                          // 💡 ตรงนี้แหละครับ! เรียกใช้ฟังก์ชันจาก Utility แทนการรับค่ามา
                          Icon(getFuelIcon(vFuel), size: 18, color: Colors.black87),
                        ],
                      ),
                      Text('$vBrand $vModel', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                      Text('Type: $vType', style: const TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                      Text(vAddress, style: const TextStyle(fontFamily: 'Poppins', fontSize: 9, color: Colors.black54), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Price', style: TextStyle(fontFamily: 'Poppins', fontSize: 11)),
                            const SizedBox(width: 5),
                            Text('${vPrice.toStringAsFixed(0)} ฿ / Hr.', style: const TextStyle(fontFamily: 'Poppins', fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}