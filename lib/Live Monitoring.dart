import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class LiveMonitoringScreen extends StatefulWidget {
  @override
  _LiveMonitoringScreenState createState() => _LiveMonitoringScreenState();
}

class _LiveMonitoringScreenState extends State<LiveMonitoringScreen> {
  final WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('ws://10.0.2.2:6789'), // Replace with your WebSocket server URL
  );

  CameraController? _cameraController;
  Uint8List? _imageBytes;
  String _overlayText = '';
  List<Map<String, dynamic>> _boundingBoxes = [];

  @override
  void initState() {
    super.initState();
    initializeCamera();
    _channel.stream.listen((data) {
      final receivedData = String.fromCharCodes(data);
      _processReceivedData(receivedData);
    });
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first, // Select the first available camera
      ResolutionPreset.medium,
    );
    await _cameraController!.initialize();
    setState(() {});
  }

  void _processReceivedData(String data) {
    try {
      final jsonData = jsonDecode(data);
      setState(() {
        _imageBytes = base64Decode(jsonData['image']);
        _overlayText = jsonData['timestamp'];
        _boundingBoxes =
            List<Map<String, dynamic>>.from(jsonData['bounding_boxes']);
      });
    } catch (e) {
      print('Error processing received data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Monitoring'),
      ),
      body: Center(
        child:
            _cameraController == null || !_cameraController!.value.isInitialized
                ? CircularProgressIndicator()
                : Stack(
                    children: [
                      CameraPreview(_cameraController!),
                      if (_imageBytes != null)
                        Image.memory(_imageBytes!, fit: BoxFit.cover),
                      ..._boundingBoxes.map((box) {
                        final x = box['x'] as double;
                        final y = box['y'] as double;
                        final width = box['width'] as double;
                        final height = box['height'] as double;
                        final color =
                            box['is_authorized'] ? Colors.green : Colors.red;
                        final label = box['label'] as String;

                        return Positioned(
                          left: x,
                          top: y,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: color, width: 2),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                label,
                                style: TextStyle(
                                    color: color,
                                    backgroundColor: Colors.black),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    _cameraController?.dispose();
    super.dispose();
  }
}
