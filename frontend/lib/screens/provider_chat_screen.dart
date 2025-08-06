import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProviderChatScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const ProviderChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  _ProviderChatScreenState createState() => _ProviderChatScreenState();
}

class Message {
  final String text;
  final String senderRole;
  Message(this.text, this.senderRole);
}

class _ProviderChatScreenState extends State<ProviderChatScreen> {
  final _controller = TextEditingController();
  List<Message> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/messages/${widget.user['id']}'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() => _messages = data.map((d) => Message(d['text'], d['sender_role'])).toList());
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text;
    if (text.isEmpty) return;
    _controller.clear();
    
    // Optimistically add to UI
    setState(() => _messages.add(Message(text, 'patient')));

    try {
      await http.post(
        Uri.parse('http://10.0.2.2:5000/api/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'patient_id': widget.user['id'], 'sender_role': 'patient', 'text': text}),
      );
    } catch (e) {
      // Handle error, maybe remove the optimistic message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with your Provider'), backgroundColor: Colors.blueAccent),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: EdgeInsets.all(10),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages.reversed.toList()[index];
                      final isUser = message.senderRole == 'patient';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(message.text, style: TextStyle(color: isUser ? Colors.white : Colors.black)),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(children: [
              Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: 'Type a message...'))),
              IconButton(icon: Icon(Icons.send, color: Colors.blueAccent), onPressed: _sendMessage)
            ]),
          )
        ],
      ),
    );
  }
}