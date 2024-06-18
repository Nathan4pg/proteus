import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:proteus/secrets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final List<String> _messages = [];
  bool _isLoading = false;

  Future<void> addMessage(String message) async {
    if (message.isEmpty) {
      return;
    }

    setState(() {
      _messages.add('You: $message');
      _isLoading = true;
    });

    final response = await _callChatGPTAPI(message);

    setState(() {
      _messages.add('Bot: $response');
      _isLoading = false;
    });
  }

  Future<String> _callChatGPTAPI(String message) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    const apiKey = chatGPTApiKey; // Your API key
    const apiOrgId = organizationId; // Your organization ID

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'OpenAI-Organization': apiOrgId,
      },
      body: jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {'role': 'user', 'content': message}
        ],
      }),
    );

    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      print('Response body: ${response.body}');
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return content;
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load response');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _messages.isEmpty
            ? const Expanded(
                child: Center(
                  child: Text('Ask a question to start the conversation.',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      )),
                ),
              )
            : Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_messages[index]),
                    );
                  },
                ),
              ),
        _isLoading
            ? const LinearProgressIndicator(
                backgroundColor: Colors.white10,
              )
            : Container(
                height: 4,
                color: Colors.white10,
              ),
      ],
    );
  }
}
