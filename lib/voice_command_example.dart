import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';

class VoiceCommandExample extends StatefulWidget {
  const VoiceCommandExample({super.key});

  @override
  VoiceCommandExampleState createState() => VoiceCommandExampleState();
}

class VoiceCommandExampleState extends State<VoiceCommandExample> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _canListen = true; // New variable to control listening permission
  bool _captureText = false;
  String _capturedText = "";
  Timer? _pauseTimer;
  String _lastRecognizedWords = "";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    if (status.isGranted) {
      _toggleListening();
    } else {
      setState(() {
        _canListen = false;
      });
    }
  }

  void _toggleListening() {
    setState(() {
      _canListen = !_canListen;
      if (_canListen) {
        _startListening();
      } else {
        _stopListening();
      }
    });
  }

  Future<void> _startListening() async {
    if (_isListening || !_canListen)
      return; // Prevent starting another session if already listening or _canListen is false

    bool available = await _speech.initialize(
      onStatus: _onStatus,
      onError: _onError,
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: _onSpeechResult,
        listenMode: stt.ListenMode.dictation,
        partialResults: true, // Get partial results
      );
    }
  }

  void _onStatus(String status) {
    print('onStatus: $status');
    if (!_isListening && status == 'done' && _canListen) {
      // Reinitialize listening if it's done but should be listening
      _startListening();
    }
  }

  void _onError(error) {
    print('onError: ${error.errorMsg}');
    setState(() => _isListening = false);
    // Reinitialize listening on error if it should be listening
    if (_canListen) {
      _startListening();
    }
  }

  void _onSpeechResult(result) {
    String recognizedWords = result.recognizedWords.toLowerCase();
    if (_captureText) {
      if (recognizedWords != _lastRecognizedWords) {
        setState(() {
          _capturedText = result.recognizedWords.split("proteus").last.trim();
          _resetPauseTimer();
        });
        _lastRecognizedWords = recognizedWords;
      }
    } else if (recognizedWords.contains("proteus")) {
      setState(() {
        _captureText = true;
        _capturedText = recognizedWords.split("proteus").last.trim();
        _lastRecognizedWords = recognizedWords;
        _resetPauseTimer();
      });
    }
  }

  void _resetPauseTimer() {
    _pauseTimer?.cancel();
    _pauseTimer = Timer(const Duration(seconds: 5), () {
      _captureText = false;
      _showCapturedTextDialog();
    });
  }

  void _showCapturedTextDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Captured Text"),
          content: SingleChildScrollView(
            child: Text(_capturedText.trim()),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _capturedText.trim()));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Text copied to clipboard")),
                );
              },
              child: const Text("Copy to Clipboard"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _capturedText = "";
                });
                _stopListening(); // Stop listening before starting a new session
                _startListening(); // Start a new session after dismissing the dialog
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
    _pauseTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_capturedText),
        IconButton(
          icon:
              _isListening ? const Icon(Icons.mic) : const Icon(Icons.mic_none),
          onPressed: _toggleListening,
        ),
      ],
    );
  }
}
