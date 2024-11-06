import 'package:cameye/AddUser.dart';
import 'package:cameye/Home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListUsers extends StatefulWidget {
  const ListUsers({super.key});

  @override
  State<ListUsers> createState() => _ListUsersState();
}

class _ListUsersState extends State<ListUsers> {
  final User? users = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("List Users"),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "List of Authorized Users",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection("users")
                  .doc(users?.uid)
                  .collection('Authorized Users')
                  .get(), // Fetching the data
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                // Handle loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Handle error state
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                // Handle empty data
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No authorized users found.",
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                // Data is available, show the list
                return ListView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var userData = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    var docId = snapshot
                        .data!.docs[index].id; // Document ID for deletion

                    return ListTile(
                      contentPadding: const EdgeInsets.all(0),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          userData['Image'] ?? "https://picsum.photos/200/300",
                        ),
                      ),
                      title: Text(userData['Name'] ?? "Unknown Name"),
                      subtitle:
                          Text(userData['Relation'] ?? "No Relation Specified"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteUser(docId);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddUsers(),
                          ));
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                      backgroundColor: const WidgetStatePropertyAll(
                        Color.fromARGB(255, 0, 0, 0),
                      ),
                      minimumSize: const WidgetStatePropertyAll(
                        Size(150, 50),
                      ),
                    ),
                    child: const Text(
                      "Add Another User",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Home(),
                          ));
                    },
                    style: ButtonStyle(
                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15))),
                        backgroundColor: const WidgetStatePropertyAll(
                          Color.fromARGB(255, 0, 0, 0),
                        ),
                        minimumSize:
                            const WidgetStatePropertyAll(Size(150, 50))),
                    child: const Text(
                      "Next",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to delete a user
  void _deleteUser(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(users?.uid)
          .collection('Authorized Users')
          .doc(docId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );

      setState(() {
        // Refresh the list after deletion
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user: $e')),
      );
    }
  }
}
