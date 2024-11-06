import 'package:flutter/material.dart';
import 'dart:io';

import 'package:cameye/Custom_widgets/CustomFormWidgets.dart';
import 'package:cameye/Firebase.dart';
import 'package:email_auth/email_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  // Controllers for SignUp form
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool loading = false;
  File? _image;

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        _image = null;
      }
    });
  }

  void _sendOTP() async {
    EmailAuth emailAuth = EmailAuth(sessionName: "CamEye");

    bool res = await emailAuth.sendOtp(
        recipientMail: _emailController.text, otpLength: 6);
    if (res) {
      print("OTP sent to your email");
    } else {
      print("Failed to send OTP");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Center(
                child: Text(
                  "CamEye",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    // color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 65,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(
                            Icons.person,
                            size: 75,
                            color: Colors.grey[700],
                          )
                        : null,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    "Upload your image",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      CustomFormField(
                        hintText: "Enter your first name",
                        icon: Icons.person,
                        controller: _firstNameController,
                        fieldName: "First Name",
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your First Name';
                          } else if (value.contains(RegExp(r'[0-9]'))) {
                            return 'Please enter a valid First Name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomFormField(
                        hintText: "Enter your last name",
                        icon: Icons.person,
                        controller: _lastNameController,
                        fieldName: "Last Name",
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Last Name';
                          } else if (value.contains(RegExp(r'[0-9]'))) {
                            return 'Please enter a valid Last Name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomFormField(
                        hintText: "xyz@gmail.com",
                        icon: Icons.mail,
                        controller: _emailController,
                        fieldName: "E-mail",
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          } else if (!value.contains('@')) {
                            return "Please enter a valid email address";
                          } else if (!value.endsWith('@gmail.com')) {
                            return "Please enter a Gmail address ending with '@gmail.com'";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomFormField(
                        hintText: "03XXXXXXXXX",
                        icon: Icons.phone,
                        controller: _phoneController,
                        fieldName: "Phone Number",
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          value = value
                              ?.trim(); // Trim any leading or trailing spaces
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          } else if (!RegExp(r'^03\d{9}$').hasMatch(value)) {
                            return "Please enter a valid Pakistani phone number";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      CustomFormField(
                        hintText: "Enter your strong password",
                        icon: Icons.lock,
                        controller: _passwordController,
                        fieldName: "Password",
                        keyboardType: TextInputType.visiblePassword,
                        // obscureText: true,
                        suffixIcon: null,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          } else if (!RegExp(
                                  r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
                              .hasMatch(value)) {
                            return 'Password must contain at least 8 characters,\nincluding an uppercase letter, a lowercase letter,\nand one special character.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.black),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(vertical: 15),
                              ),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  loading = true;
                                });

                                try {
                                  if (_image != null) {
                                    await FirebaseServices.signUpWithEmail(
                                      _firstNameController.text,
                                      _lastNameController.text,
                                      _emailController.text,
                                      _phoneController.text,
                                      _passwordController.text,
                                      _image!.path,
                                      context,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text("Please select an image"),
                                    ));
                                  }
                                } finally {
                                  setState(() {
                                    loading = false;
                                  });
                                }
                              }
                            },
                            child: loading
                                ? const SpinKitThreeBounce(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
