import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EntriesScreen extends StatefulWidget {
  @override
  _EntriesScreenState createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _entriesStream;

  @override
  void initState() {
    super.initState();
    // Create a stream to listen for updates from Firestore
    _entriesStream = _firestore
        .collection('entries')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entries'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _entriesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final entries = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index].data() as Map<String, dynamic>;
              final user = entry['user'] ?? 'Unknown';
              final timestamp = (entry['timestamp'] as Timestamp).toDate();
              final imagePath = entry['image_path'] ?? '';

              return ListTile(
                leading: imagePath.isNotEmpty
                    ? Image.network(imagePath,
                        width: 50, height: 50, fit: BoxFit.cover)
                    : null,
                title: Text(user),
                subtitle: Text('Date: ${timestamp.toLocal()}'),
              );
            },
          );
        },
      ),
    );
  }
}
