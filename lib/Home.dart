// ignore_for_file: prefer_const_constructors

import 'package:cameye/AddCam.dart';
import 'package:cameye/AddUser.dart';
import 'package:cameye/EditProfile.dart';
import 'package:cameye/Firebase.dart';
import 'package:cameye/ListUsers.dart';
import 'package:cameye/Entries.dart';
import 'package:cameye/Live%20Monitoring.dart';
import 'package:cameye/Notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final User? users = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Home",
            style: TextStyle(
                // color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.help_outline,
              ),
              onPressed: () {
                // Help action
              },
            ),
          ],
          centerTitle: true,
        ),
        drawer: Drawer(
          child: Column(
            children: [
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(users?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // if (snapshot.data!.doc(users?)) {
                  final userDoc = snapshot.data!;
                  return DrawerHeader(
                    decoration: BoxDecoration(color: Colors.black),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(userDoc["profileImage"]),
                          radius: 30,
                        ),
                        // const SizedBox(
                        //   width: 20,
                        // ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              userDoc["firstName"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                            Text(
                              userDoc["email"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                title: Text('Profile'),
                leading: Icon(Icons.person),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfile(),
                      ));
                },
              ),
              ListTile(
                title: Text('Add Camera'),
                leading: Icon(Icons.camera_front_sharp),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCam(),
                      ));
                },
              ),
              ListTile(
                title: Text('Authorize Users List'),
                leading: Icon(Icons.people),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ListUsers(),
                      ));
                },
              ),
              ListTile(
                title: Text('Add Authorized User'),
                leading: Icon(Icons.person_add),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddUsers(),
                      ));
                },
              ),
              ListTile(
                title: Text("Logout"),
                leading: Icon(Icons.logout),
                onTap: () async {
                  FirebaseServices.signOut(context);
                },
              )
            ],
          ),
        ),
        body: Center(
          child: CircleAvatar(
            radius: 100,
            backgroundImage: AssetImage("assets/Logo.jpg"),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          selectedItemColor: Colors.blue,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EntriesScreen()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LiveMonitoringScreen()),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            } else if (index == 4) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfile()),
              );
            }
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Entires'),
            BottomNavigationBarItem(
                icon: Icon(Icons.live_tv), label: 'Live Monitoring'),
            BottomNavigationBarItem(
                icon: Icon(Icons.notifications), label: 'Notification'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ));
  }
}
