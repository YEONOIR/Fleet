import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 💡 เพิ่ม Import Firestore

class HistoryCard extends StatelessWidget {
  final Map<String, dynamic> car;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const HistoryCard({
    super.key,
    required this.car,
    required this.gradientColors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 💡 เช็ค Path ว่าเป็น URL หรือ Assets
    String imgPath = car['image']?.toString() ?? 'assets/images/car.jpg';
    
    // 💡 ดึงข้อมูล booking ออกมาเพื่อใช้วันที่
    Map<String, dynamic>? booking = car['booking']; 
    String vehicleId = car['vehicle_id'] ?? car['id'] ?? ''; // 💡 ดึง ID รถ

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: gradientColors[0].withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: gradientColors[0],
                  width: 4,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title row + rating badge ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          car['name']?.toString() ?? 'Vehicle',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF070E2A),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.white),
                            const SizedBox(width: 3),
                            // 💡 ใช้ FutureBuilder ดึง Rating สดๆ จาก Database ป้องกัน Error Null
                            FutureBuilder<DocumentSnapshot>(
                              future: vehicleId.isNotEmpty ? FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).get() : null,
                              builder: (context, snapshot) {
                                double rating = double.tryParse(car['rating']?.toString() ?? '0') ?? 0.0;
                                if (snapshot.hasData && snapshot.data!.exists) {
                                  rating = (snapshot.data!['rating'] ?? 0).toDouble();
                                }
                                return Text(
                                  rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Content row: image + details ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Car image
                      Container(
                        width: 100,
                        height: 85,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6, offset: const Offset(0, 2))
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imgPath.startsWith('http')
                              ? Image.network(imgPath, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey)))
                              : Image.asset(imgPath, fit: BoxFit.cover, errorBuilder: (ctx, err, stack) => Container(color: Colors.grey.shade200, child: const Icon(Icons.directions_car, color: Colors.grey))),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _detailRow(Icons.credit_card, 'License plate: ${car['plate'] ?? '-'}'),
                            const SizedBox(height: 3),
                            _detailRow(Icons.directions_car_outlined, 'Model: ${car['model'] ?? '-'}'),
                            const SizedBox(height: 3),
                            _detailRow(Icons.category_outlined, 'Type: ${car['type'] ?? '-'}'),
                            const SizedBox(height: 3),
                            _detailRow(Icons.location_on_outlined, car['address']?.toString() ?? '-'),
                            const SizedBox(height: 6),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined, 
                                  size: 14, 
                                  color: const Color(0xFF070E2A).withOpacity(0.6)
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  '${booking?['startDate'] ?? '-'} - ${booking?['endDate'] ?? '-'}',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins', 
                                    fontSize: 12, 
                                    fontWeight: FontWeight.bold, 
                                    color: Color.fromRGBO(7, 14, 42, 0.8)
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Status indicator bar at bottom ──
                Container(
                  width: double.infinity,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────── Detail Row ───────────
  Widget _detailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF070E2A).withOpacity(0.5)),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF070E2A).withOpacity(0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}