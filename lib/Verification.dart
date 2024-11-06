import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cameye/AddCam.dart'; // Make sure this import is correct

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool _isVerified = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  Future<void> _checkEmailVerification() async {
    User? user = _auth.currentUser;
    await user
        ?.reload(); // Reloads the user to get the latest verification status
    setState(() {
      _isVerified = user?.emailVerified ?? false;
    });

    if (_isVerified) {
      // If email is verified, navigate to the AddCam screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AddCam()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify Your Email")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isVerified
                  ? "Email Verified! Redirecting..."
                  : "Please verify your email. Check your inbox for the link.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            if (!_isVerified) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkEmailVerification,
                child: Text("Check Verification"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
