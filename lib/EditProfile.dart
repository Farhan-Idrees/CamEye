// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final _formKey = GlobalKey<FormState>();
  final _firstController = TextEditingController();
  final _lastController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String imageUrl = ''; // URL of the current profile image
  File? _image; // Selected image file for update
  bool _loading = false; // Flag to show loading indicator

  @override
  void initState() {
    super.initState();
    _getUserData(); // Retrieve user data on initialization
  }

  // Fetch user data from Firestore
  Future<void> _getUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _firstController.text = doc['firstName'] ?? '';
        _lastController.text = doc['lastName'] ?? '';
        _emailController.text = doc['email'] ?? '';
        _phoneController.text = doc['phoneNumber'] ?? '';
        imageUrl = doc['profileImage'] ?? '';
      });
    }
  }

  // Select a new profile image
  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // Update user profile in Firestore and Firebase Auth
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      try {
        final user = _auth.currentUser;
        if (user != null) {
          String? imageDownloadUrl;

          // Upload new image if selected
          if (_image != null) {
            final ref = _storage.ref().child('images/${user.uid}');
            await ref.putFile(_image!);
            imageDownloadUrl = await ref.getDownloadURL();
          }

          // Update user data in Firestore
          await _firestore.collection('users').doc(user.uid).update({
            'firstName': _firstController.text,
            'lastName': _lastController.text,
            'email': _emailController.text,
            'phoneNumber': _phoneController.text,
            if (imageDownloadUrl != null) 'profileImage': imageDownloadUrl,
          });

          // Update password if provided
          if (_passwordController.text.isNotEmpty) {
            await user.updatePassword(_passwordController.text);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile picture selection
                    GestureDetector(
                      onTap: _selectImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl) as ImageProvider
                                : AssetImage('assets/default_avatar.png'),
                        child: _image == null && imageUrl.isEmpty
                            ? Icon(Icons.camera_alt, size: 50)
                            : null,
                      ),
                    ),
                    SizedBox(height: 20),

                    // First Name input
                    TextFormField(
                      controller: _firstController,
                      decoration: InputDecoration(labelText: 'First Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Last Name input
                    TextFormField(
                      controller: _lastController,
                      decoration: InputDecoration(labelText: 'Last Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Email input
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Phone Number input
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: 'Phone Number'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Password input
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(labelText: 'New Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 6) {
                          return 'Password must be at least 6 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),

                    // Update button
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: Text('Update Profile'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
