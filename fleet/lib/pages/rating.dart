import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RatingPage extends StatefulWidget {
  final bool
  isRatingRenter; // True = Owner rate Renter | False = Renter rate Vehicle
  final String targetId;
  final String bookingId;
  final String targetName;
  final String? targetImage;

  const RatingPage({
    super.key,
    required this.isRatingRenter,
    required this.targetId,
    required this.bookingId,
    required this.targetName,
    this.targetImage,
  });

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double _rating = 5.0;
  bool _isSubmitting = false;
  final TextEditingController _commentController = TextEditingController();

  String _firstName = "";
  String _profileImage = "";
  bool _isLoadingUser = true;
  bool _alreadyRated = false;
  @override
  void initState() {
    super.initState();
    _fetchTargetUserInfo();
  }

  Future<void> _fetchTargetUserInfo() async {
    try {
      var bDoc = await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .get();
      if (bDoc.exists) {
        bool isRenterRated = bDoc['is_renter_rated'] ?? false;
        bool isVehicleRated = bDoc['is_vehicle_rated'] ?? false;

        if ((widget.isRatingRenter && isRenterRated) ||
            (!widget.isRatingRenter && isVehicleRated)) {
          if (mounted) {
            setState(() {
              _alreadyRated = true;
              _isLoadingUser = false;
            });
          }
          return;
        }
      }

      if (widget.isRatingRenter) {
        var userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.targetId)
            .get();
        if (userDoc.exists && mounted) {
          setState(() {
            _firstName = userDoc['first_name'] ?? widget.targetName;
            _profileImage = userDoc['profile_image'] ?? '';
            _isLoadingUser = false;
          });
        } else {
          if (mounted) setState(() => _isLoadingUser = false);
        }
      } else {
        var vDoc = await FirebaseFirestore.instance
            .collection('vehicles')
            .doc(widget.targetId)
            .get();
        if (vDoc.exists && mounted) {
          setState(() {
            List<dynamic> images = vDoc['images'] ?? [];
            if (images.isNotEmpty) {
              _profileImage = images[0].toString();
            } else if (vDoc['imagePath'] != null) {
              _profileImage = vDoc['imagePath'].toString();
            }
            _isLoadingUser = false;
          });
        } else {
          if (mounted) setState(() => _isLoadingUser = false);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingUser = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);
    try {
      String collectionName = widget.isRatingRenter ? 'users' : 'vehicles';
      DocumentReference targetRef = FirebaseFirestore.instance
          .collection(collectionName)
          .doc(widget.targetId);
      DocumentReference reviewRef = targetRef.collection('reviews').doc();

      await reviewRef.set({
        'booking_id': widget.bookingId,
        'rating': _rating,
        'comment': _commentController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
      });

      QuerySnapshot reviewsSnapshot = await targetRef
          .collection('reviews')
          .get();
      double totalScore = 0.0;
      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalScore += (data['rating'] ?? 0).toDouble();
      }

      double newAverage = reviewsSnapshot.docs.isEmpty
          ? 0.0
          : (totalScore / reviewsSnapshot.docs.length);
      newAverage = double.parse(newAverage.toStringAsFixed(1));

      WriteBatch batch = FirebaseFirestore.instance.batch();

      batch.update(targetRef, {
        'rating': newAverage,
        'review_count': reviewsSnapshot.docs.length,
      });

      DocumentReference bookingRef = FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId);
      if (widget.isRatingRenter) {
        batch.update(bookingRef, {'is_renter_rated': true});
      } else {
        batch.update(bookingRef, {'is_vehicle_rated': true});
      }

      await batch.commit();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildTargetImage(ImageProvider imageProvider) {
    if (widget.isRatingRenter) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: imageProvider,
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image(
            image: imageProvider,
            width: 160,
            height: 110,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_alreadyRated) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 80,
                color: Color(0xFF75DB73),
              ),
              const SizedBox(height: 20),
              const Text(
                'Review Already Submitted',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(7, 14, 42, 1.0),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'You have already rated this booking.',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(7, 14, 42, 1.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    ImageProvider imageProvider;
    if (_profileImage.isNotEmpty && _profileImage.startsWith('http')) {
      imageProvider = NetworkImage(_profileImage);
    } else if (widget.targetImage != null &&
        widget.targetImage!.startsWith('http')) {
      imageProvider = NetworkImage(widget.targetImage!);
    } else {
      imageProvider = AssetImage(
        widget.isRatingRenter
            ? 'assets/icons/avatar.jpg'
            : 'assets/images/car.jpg',
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoadingUser
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(172, 114, 161, 1.0),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  _buildTargetImage(imageProvider),
                  const SizedBox(height: 25),

                  Text(
                    widget.isRatingRenter
                        ? 'Rate $_firstName'
                        : 'Rate the Vehicle',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.isRatingRenter
                        ? 'How was your experience renting to $_firstName?'
                        : 'How was your experience with ${widget.targetName}?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 45,
                        ),
                        onPressed: () =>
                            setState(() => _rating = (index + 1).toDouble()),
                      );
                    }),
                  ),
                  Text(
                    '${_rating.toStringAsFixed(1)} / 5.0',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 30),

                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                    decoration: InputDecoration(
                      hintText: widget.isRatingRenter
                          ? 'Write a review about this renter...'
                          : 'Write a review about this vehicle...',
                      hintStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(172, 114, 161, 1.0),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),

                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(7, 14, 42, 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _submitReview,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Submit Review',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
