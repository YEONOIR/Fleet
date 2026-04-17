import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../components/notification_card.dart';

class StaffNotificationsPage extends StatefulWidget {
  const StaffNotificationsPage({super.key});

  @override
  State<StaffNotificationsPage> createState() => _StaffNotificationsPageState();
}

class _StaffNotificationsPageState extends State<StaffNotificationsPage> {
  String _formatTime(Timestamp? timestamp) {
    if (timestamp == null) return 'Just now';
    final DateTime date = timestamp.toDate();
    final Duration diff = DateTime.now().difference(date);

    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} mins ago';
    return 'Just now';
  }

  Future<void> _markAsRead(String docId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(docId)
        .update({'is_read': true});
  }

  Future<void> _markAllAsRead(List<QueryDocumentSnapshot> docs) async {
    final batch = FirebaseFirestore.instance.batch();
    for (var doc in docs) {
      if (doc['is_read'] == false) {
        batch.update(doc.reference, {'is_read': true});
      }
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(248, 248, 250, 1.0),
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
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

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('user_id', isEqualTo: 'staff')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(172, 114, 161, 1.0),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'No pending requests',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          var docs = snapshot.data!.docs;
          docs.sort((a, b) {
            Timestamp? timeA = a['created_at'] as Timestamp?;
            Timestamp? timeB = b['created_at'] as Timestamp?;
            if (timeA == null) return 1;
            if (timeB == null) return -1;
            return timeB.compareTo(timeA);
          });

          return Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _markAllAsRead(docs),
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: Color.fromRGBO(172, 114, 161, 1.0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var data = docs[index].data() as Map<String, dynamic>;

                    Map<String, dynamic> notifData = {
                      'title': data['title'],
                      'message': data['message'],
                      'type': data['type'],
                      'is_read': data['is_read'],
                      'time': _formatTime(data['created_at'] as Timestamp?),
                    };

                    return NotificationCard(
                      notification: notifData,
                      onTap: () {
                        if (data['is_read'] == false) {
                          _markAsRead(docs[index].id);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
