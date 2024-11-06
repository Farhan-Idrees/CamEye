import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot>? _notificationsStream;

  @override
  void initState() {
    super.initState();
    _setupNotificationsStream();
  }

  void _setupNotificationsStream() {
    // Get the user's ID
    String userId = _auth.currentUser!.uid;

    // Set up a stream to listen for notifications for the current user
    _notificationsStream = _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _notificationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No notifications available.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              var timestamp = data['timestamp'].toDate();
              var imagePath = data['image_path'];
              var alertMessage = data['alert_message'];

              return ListTile(
                contentPadding: EdgeInsets.all(8.0),
                leading: Image.network(imagePath,
                    width: 50, height: 50, fit: BoxFit.cover),
                title: Text('Alert: $alertMessage'),
                subtitle: Text('Detected at: ${timestamp.toLocal()}'),
                isThreeLine: true,
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
