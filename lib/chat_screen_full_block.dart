import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proteus/secrets.dart';

class ChatScreenFullBlock extends StatefulWidget {
  const ChatScreenFullBlock({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreenFullBlock> {
  final List<String> _messages = [];
  final StreamController<String> _streamController = StreamController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  final StringBuffer _currentMessageBuffer = StringBuffer();

  @override
  void dispose() {
    _streamController.close();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> addMessage(String message) async {
    if (message.isEmpty) {
      return;
    }

    setState(() {
      _messages.add('You: $message');
      _isLoading = true;
      _currentMessageBuffer.clear();
    });

    await _callChatGPTAPI(message);
  }

  Future<void> _callChatGPTAPI(String message) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    const apiKey = chatGPTApiKey; // Replace with your API key
    const apiOrgId = organizationId;

    final request = http.Request('POST', url)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'OpenAI-Organization': apiOrgId,
      })
      ..body = jsonEncode({
        'model': 'gpt-4',
        'messages': [
          {'role': 'user', 'content': message}
        ],
        'stream': true, // Enable streaming responses
      });

    final response = await request.send();

    print('Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((chunk) {
        print('Chunk: $chunk');

        if (chunk.isEmpty) {
          print('Empty chunk: $chunk');
          return;
        }

        if (chunk == 'data: [DONE]') {
          print("It's the done chunk!: $chunk");
          return;
        }
        if (chunk.startsWith('data: ')) {
          chunk = chunk.substring(6); // Remove the "data: " prefix
        }
        try {
          final Map<String, dynamic> data = jsonDecode(chunk);
          print('Data: $data');
          if (data['choices'] != null && data['choices'].isNotEmpty) {
            final delta = data['choices'][0]['delta'];
            if (delta != null && delta['content'] != null) {
              final content = delta['content'];
              setState(() {
                _currentMessageBuffer.write(content);
                _streamController.add(_currentMessageBuffer.toString());
              });
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          }
        } catch (e) {
          print('Error processing chunk: $e');
        }
      }, onDone: () {
        setState(() {
          _isLoading = false;
          _messages.add('Bot: ${_currentMessageBuffer.toString()}');
        });
      }, onError: (e) {
        print('Stream error: $e');
        setState(() {
          _isLoading = false;
        });
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Error response: ${response.statusCode} ${response.reasonPhrase}');
      throw Exception('Failed to load response');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: StreamBuilder<String>(
            stream: _streamController.stream,
            builder: (context, snapshot) {
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8.0),
                itemCount: _messages.length + (snapshot.hasData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _messages.length) {
                    return ListTile(
                      title: Text(_messages[index]),
                    );
                  } else {
                    return ListTile(
                      title: Text('Bot: ${snapshot.data}'),
                    );
                  }
                },
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
