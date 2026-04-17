import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/review_card.dart';

class FleetEntityReviewPage extends StatefulWidget {
  final bool isCar;
  final String entityName;
  final String targetId;

  const FleetEntityReviewPage({
    super.key,
    required this.isCar,
    required this.entityName,
    required this.targetId,
  });

  @override
  State<FleetEntityReviewPage> createState() => _FleetEntityReviewPageState();
}

class _FleetEntityReviewPageState extends State<FleetEntityReviewPage> {
  Future<List<Map<String, dynamic>>> _fetchReviews() async {
    String collectionName = widget.isCar ? 'vehicles' : 'users';

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(widget.targetId)
        .collection('reviews')
        .orderBy('created_at', descending: true)
        .get();

    List<Map<String, dynamic>> enrichedReviews = [];

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String reviewerName = "Anonymous";
      String reviewerImage = "";

      if (data['booking_id'] != null) {
        try {
          var bookingSnap = await FirebaseFirestore.instance
              .collection('bookings')
              .doc(data['booking_id'])
              .get();
          if (bookingSnap.exists) {
            var bData = bookingSnap.data() as Map<String, dynamic>;

            String reviewerId = widget.isCar
                ? (bData['renter_id'] ?? '')
                : (bData['owner_id'] ?? '');

            if (reviewerId.isNotEmpty) {
              var userSnap = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(reviewerId)
                  .get();
              if (userSnap.exists) {
                reviewerName = userSnap['first_name'] ?? 'Anonymous';
                reviewerImage = userSnap['profile_image'] ?? '';
              }
            }
          }
        } catch (e) {
          debugPrint("Error fetching booking/user for review: $e");
        }
      }

      data['reviewer_name'] = reviewerName;
      data['reviewer_image'] = reviewerImage;
      enrichedReviews.add(data);
    }

    return enrichedReviews;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.entityName,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(172, 114, 161, 1.0),
                Color.fromRGBO(7, 14, 42, 1.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(172, 114, 161, 1.0),
              ),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No reviews yet.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            );
          }

          final reviews = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(20.0),
            itemCount: reviews.length,
            separatorBuilder: (context, index) => const SizedBox(height: 15),
            itemBuilder: (context, index) {
              return ReviewCard(review: reviews[index], isCar: widget.isCar);
            },
          );
        },
      ),
    );
  }
}
