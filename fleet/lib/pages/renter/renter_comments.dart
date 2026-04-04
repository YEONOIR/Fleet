import 'package:flutter/material.dart';

class RenterCommentsPage extends StatelessWidget {
  final Map<String, dynamic> car;

  const RenterCommentsPage({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(car['name'], style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color.fromRGBO(172, 114, 161, 1.0), Color.fromRGBO(7, 14, 42, 1.0)],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Rating", style: TextStyle(fontFamily: 'Poppins', fontSize: 18, color: Colors.black87)),
                const SizedBox(width: 10),
                const Icon(Icons.star, color: Colors.amber, size: 24),
                Text(" ${car['rating']}", style: const TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildCommentCard("Sukrit Chatchawal", "Tel: 0848978975", "Very good", 5, 'assets/icons/avatar.jpg'),
                  const SizedBox(height: 15),
                  _buildCommentCard("Pimthida Butsra", "Tel: 0812345678", "I love it", 4, 'assets/icons/avatar.jpg'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCommentCard(String name, String tel, String comment, int rating, String avatarPath) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color.fromRGBO(172, 114, 161, 0.5), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color.fromRGBO(7, 14, 42, 1.0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                CircleAvatar(backgroundImage: AssetImage(avatarPath), radius: 20),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(tel, style: const TextStyle(fontFamily: 'Poppins', color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (index) => Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.yellow,
                    size: 16,
                  )),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(comment, style: const TextStyle(fontFamily: 'Poppins', fontSize: 13)),
          )
        ],
      ),
    );
  }
}