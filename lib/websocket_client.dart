import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketClient extends StatefulWidget {
  final String socketUrl =
      'ws://10.0.2.2:6789'; // Replace with your WebSocket URL

  @override
  _WebSocketClientState createState() => _WebSocketClientState();
}

class _WebSocketClientState extends State<WebSocketClient> {
  late WebSocketChannel _channel;
  late TextEditingController _controller;
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _channel = WebSocketChannel.connect(Uri.parse(widget.socketUrl));
    _controller = TextEditingController();

    _channel.stream.listen((message) {
      setState(() {
        _messages.add(message);
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close(status.goingAway);
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _channel.sink.add(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Client'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Send a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
