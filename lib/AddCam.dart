import 'package:cameye/AddUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cameye/Firebase.dart';
import 'package:cameye/Custom_widgets/CustomFormWidgets.dart';

class AddCam extends StatefulWidget {
  const AddCam({super.key});

  @override
  State<AddCam> createState() => _AddCamState();
}

class _AddCamState extends State<AddCam> {
  final _formKey = GlobalKey<FormState>();
  final _camNameController = TextEditingController();
  final _camIPController = TextEditingController();
  bool _loading = false;
  bool _isCameraAdded = false;
  List<Map<String, dynamic>> _devices = []; // List to hold devices

  @override
  void initState() {
    super.initState();
    _fetchDevices();
  }

  Future<void> _fetchDevices() async {
    try {
      final QuerySnapshot snapshot = await FirebaseServices.getDevices();
      final List<Map<String, dynamic>> devices = snapshot.docs
          .map((doc) => {
                'camName': doc['camName'],
                'camIP': doc['camIP'],
                'id': doc.id, // Store the document ID for deletion
              })
          .toList();

      setState(() {
        _devices = devices; // Update the state with the fetched devices
      });
    } catch (e) {
      print('Error fetching devices: $e');
    }
  }

  Future<void> _deleteDevice(String deviceId) async {
    await FirebaseServices.deleteDevice(deviceId);
    _fetchDevices(); // Refresh the device list after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Cam"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Text(
                "Add Camera Details",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              ),
              SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      CustomFormField(
                        hintText: "Cam0",
                        icon: Icons.camera_alt_sharp,
                        controller: _camNameController,
                        fieldName: "Camera Name",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Camera name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      CustomFormField(
                        hintText: "Enter Camera IP address",
                        icon: Icons.camera_front,
                        controller: _camIPController,
                        fieldName: "Cam IP Address",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your camera IP address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: _loading ? null : _handleSave,
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          backgroundColor: MaterialStateProperty.all(
                            Colors.black,
                          ),
                          minimumSize: MaterialStateProperty.all(
                            Size(250, 50),
                          ),
                        ),
                        child: _loading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Save",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                      ),
                      SizedBox(height: 20),
                      // Display the list of devices
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _devices.length,
                        itemBuilder: (context, index) {
                          final device = _devices[index];
                          return ListTile(
                            title: Text(device['camName']),
                            subtitle: Text(device['camIP']),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteDevice(device['id']);
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: SizedBox(
          child: ElevatedButton(
            onPressed: _isCameraAdded
                ? () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => AddUsers()),
                    );
                  }
                : null,
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              backgroundColor: MaterialStateProperty.all(
                _isCameraAdded ? Colors.black : Colors.grey,
              ),
              minimumSize: MaterialStateProperty.all(
                Size(150, 50),
              ),
            ),
            child: Text(
              "Next",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      await FirebaseServices.addCam(
        _camNameController.text.trim(),
        _camIPController.text.trim(),
        context,
      );

      setState(() {
        _loading = false;
        _isCameraAdded = true;
      });

      _fetchDevices(); // Refresh the device list after adding
    }
  }
}
