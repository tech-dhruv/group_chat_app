import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketDemo extends StatefulWidget {
  const WebSocketDemo({super.key});

  @override
  State<WebSocketDemo> createState() => _WebSocketDemoState();
}

class _WebSocketDemoState extends State<WebSocketDemo> {
  late WebSocketChannel channel;
  final TextEditingController controller = TextEditingController();
  List<String> messages = [];

  @override
  void initState() {
    super.initState();
    connectWebSocket();
  }

  void connectWebSocket() {
    channel = IOWebSocketChannel.connect('wss://echo.websocket.events/');
    channel.stream.listen(
          (data) {
        setState(() {
          messages.add("Received: $data");
        });
      },
      onError: (error) {
        print("WebSocket Error: $error");
        reconnectWebSocket();
      },
      onDone: () {
        print("WebSocket Closed");
        reconnectWebSocket();
      },
    );
  }

  void reconnectWebSocket() {
    Future.delayed(Duration(seconds: 5), () {
      if (!mounted) return;
      connectWebSocket();
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  void sendMessage() {
    if (controller.text.isNotEmpty) {
      channel.sink.add(controller.text);
      setState(() {
        messages.add("Sent: ${controller.text}");
      });
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WebSocket Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: controller,
              decoration: InputDecoration(labelText: 'Send a message'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: sendMessage,
              child: Text('Send'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(messages[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

