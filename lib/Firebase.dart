import 'dart:typed_data';
import 'dart:io';

import 'package:cameye/Login.dart';
import 'package:cameye/Verification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';

class FirebaseServices {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Authentication methods
  static Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

// Firebase Signup Function
  static Future<User?> signUpWithEmail(
      String firstName,
      String lastName,
      String email,
      String phoneNumber,
      String password,
      String imagePath,
      BuildContext context) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;
      if (user != null) {
        // Send email verification
        await user.sendEmailVerification();

        // Upload profile image
        String? imageUrl = await uploadFile(
            'profile_images/${user.uid}', File(imagePath).readAsBytesSync());

        // Signup info to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phoneNumber': phoneNumber,
          'profileImage': imageUrl,
        });

        // Redirect to VerificationPage after sending the verification email
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationPage(),
          ),
        );
      }
      return user;
    } catch (e) {
      print('Error signing up: $e');
      _showSnackBar(context, 'Failed to Signup: $e');
      return null;
    }
  }

// Signout
  static Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Reset password method
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent');
    } catch (e) {
      print('Error sending password reset email: $e');
    }
  }

  // Firestore methods
  static Future<void> addUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).set(data);
    } catch (e) {
      print('Error adding user: $e');
    }
  }

  static Future<DocumentSnapshot> getUser(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }

  // Storage methods
  static Future<String?> uploadFile(String path, Uint8List fileData) async {
    try {
      Reference ref = _storage.ref().child(path);
      UploadTask uploadTask = ref.putData(fileData);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // Firebase Messaging methods
  static Future<void> initializeMessaging() async {
    await FirebaseMessaging.instance.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.messageId}');
      // Handle foreground messages
    });
  }

  static Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  static Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

// Add camera method
  static Future<void> addCam(
      String camName, String camIP, BuildContext context) async {
    try {
      // Check if the camera name already exists
      final existingCam = await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("Devices")
          .doc(camName)
          .get();

      if (existingCam.exists) {
        _showSnackBar(context, 'This name is already exist.');
        return; // Exit the method early if the camera name is not unique
      }

      // If the camera name is unique, add it to Firestore
      await _firestore
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("Devices")
          .doc(camName)
          .set({'camName': camName, 'camIP': camIP});

      _showSnackBar(context, 'Camera added successfully');
    } catch (e) {
      print('Error adding camera: $e');
      _showSnackBar(context, 'Failed to add camera: $e');
    }
  }

// Get Devices list
  static Future<QuerySnapshot> getDevices() async {
    return await _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("Devices")
        .get();
  }

// Delete devices
  static Future<void> deleteDevice(String deviceId) async {
    await _firestore
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("Devices")
        .doc(deviceId)
        .delete();
  }

  // Method to show a Snackbar using context
  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
