import 'package:flutter/material.dart';

class FleetEntityReviewPage extends StatelessWidget {
  final bool isCar; // 💡 ตัวแปรบอกว่าเป็นรีวิวรถ (true) หรือรีวิวคน (false)
  final String entityName; // 💡 ชื่อบน AppBar เช่น "Sukrit's Honda Reviews"

  const FleetEntityReviewPage({
    super.key, 
    required this.isCar,
    required this.entityName, // บังคับให้ส่งชื่อมาโชว์บนหัวเลย
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      
      // ==========================================
      // 💡 1. AppBar (เอา TabBar ออกไปแล้ว เหลือแค่ชื่อ)
      // ==========================================
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          entityName, // โชว์ชื่อที่ส่งมา
          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white)
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      
      // ==========================================
      // 💡 2. แสดงรายการการ์ดรีวิวเพียวๆ เลย
      // ==========================================
      body: _buildReviewList(),
    );
  }

  Widget _buildReviewList() {
    // ข้อมูลจำลอง (Mock Data) สลับตาม isCar ที่ส่งมา
    final List<Map<String, dynamic>> reviews = isCar
        ? [
            {"reviewer": "Nida K.", "rating": 5, "comment": "The car is very clean and the AC is super cold. Highly recommended!", "date": "10 Apr 2026"},
            {"reviewer": "Somchai T.", "rating": 4, "comment": "Good condition overall, but there are some minor scratches on the left door.", "date": "5 Apr 2026"},
            {"reviewer": "Alex M.", "rating": 5, "comment": "Smooth driving experience. Battery lasted longer than expected.", "date": "28 Mar 2026"},
          ]
        : [
            {"reviewer": "Pimthida (Owner)", "rating": 5, "comment": "Very polite user. Returned the car on time and in perfect condition.", "date": "12 Apr 2026"},
            {"reviewer": "Sukrit (Owner)", "rating": 5, "comment": "Easy to communicate with. Highly recommended renter.", "date": "2 Apr 2026"},
          ];

    return ListView.separated(
      padding: const EdgeInsets.all(20.0),
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const SizedBox(height: 15),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: isCar ? const Color.fromRGBO(172, 114, 161, 0.1) : const Color.fromRGBO(7, 14, 42, 0.1),
                child: Text(
                  review['reviewer'][0], 
                  style: TextStyle(
                    fontFamily: 'Poppins', 
                    fontWeight: FontWeight.bold,
                    color: isCar ? const Color.fromRGBO(172, 114, 161, 1.0) : const Color.fromRGBO(7, 14, 42, 1.0),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              
              // เนื้อหารีวิว
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            review['reviewer'], 
                            style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          review['date'], 
                          style: const TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (starIndex) => Icon(
                          starIndex < review['rating'] ? Icons.star : Icons.star_border,
                          color: const Color(0xFFFFD700),
                          size: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      review['comment'], 
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, height: 1.4, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}