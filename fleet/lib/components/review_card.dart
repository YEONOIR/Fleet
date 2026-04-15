import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final bool isCar;

  const ReviewCard({
    super.key, 
    required this.review, 
    required this.isCar
  });

  // 💡 ฟังก์ชันแปลง Timestamp จาก Firestore ให้เป็นข้อความวันที่สวยๆ
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '-';
    DateTime dt = timestamp.toDate();
    List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    String reviewerName = review['reviewer_name'] ?? 'Anonymous';
    String reviewerImage = review['reviewer_image'] ?? ''; // 💡 ดึง URL รูปภาพออกมา
    String comment = review['comment'] ?? 'No comment provided.';
    double rating = (review['rating'] ?? 0).toDouble();
    String dateStr = _formatDate(review['created_at']);
    String initial = reviewerName.isNotEmpty ? reviewerName[0].toUpperCase() : '?';

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
          // 💡 Avatar ของคนรีวิว (แสดงรูปถ้ามี ถ้าไม่มีแสดงตัวอักษรย่อ)
          CircleAvatar(
            radius: 20,
            backgroundColor: isCar ? const Color.fromRGBO(172, 114, 161, 0.1) : const Color.fromRGBO(7, 14, 42, 0.1),
            backgroundImage: reviewerImage.isNotEmpty ? NetworkImage(reviewerImage) : null,
            child: reviewerImage.isEmpty 
                ? Text(
                    initial, 
                    style: TextStyle(
                      fontFamily: 'Poppins', 
                      fontWeight: FontWeight.bold,
                      color: isCar ? const Color.fromRGBO(172, 114, 161, 1.0) : const Color.fromRGBO(7, 14, 42, 1.0),
                    ),
                  )
                : null, // ถ้ารูปมี ไม่ต้องโชว์ตัวอักษร
          ),
          const SizedBox(width: 15),
          
          // 💡 เนื้อหารีวิว
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        reviewerName, 
                        style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      dateStr, 
                      style: const TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 💡 ดาว Rating
                Row(
                  children: List.generate(
                    5,
                    (starIndex) => Icon(
                      starIndex < rating.floor() ? Icons.star : Icons.star_border,
                      color: const Color(0xFFFFD700),
                      size: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  comment, 
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 13, height: 1.4, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}