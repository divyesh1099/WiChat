import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WiFi Messenger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MessagePage(),
    );
  }
}

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _portController = TextEditingController();
  final TextEditingController _ipController = TextEditingController();
  List<String> messages = [];
  List<String> targetAddresses = [];

  void _addIPAddress() {
    setState(() {
      targetAddresses.add(_ipController.text);
      _ipController.clear();
    });
  }

  void _sendMessage() async {
    String message = _messageController.text;
    int port = int.parse(_portController.text);

    for (String address in targetAddresses) {
      try {
        Socket socket = await Socket.connect(address, port);
        socket.add(utf8.encode(message));
        await socket.flush();
        socket.close();
      } catch (e) {
        print("Error sending message to $address: $e");
      }
    }

    setState(() {
      messages.add(message);
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WiFi Messenger'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'Enter IP Address',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addIPAddress,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _portController,
              decoration: InputDecoration(
                labelText: 'Enter Port',
              ),
              keyboardType: TextInputType.number,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(messages[index]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter a message',
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
