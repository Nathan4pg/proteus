import 'package:flutter/material.dart';
import 'package:proteus/constants.dart';
import 'package:universal_html/html.dart';

class InputBay extends StatelessWidget {
  final Function(String) onSendMessage;

  const InputBay({
    super.key,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Row(
      children: <Widget>[
        Expanded(
          child: SizedBox(
            height: 38,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black.withOpacity(0.1),
                hintText: 'Type your message...',
                hintStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                suffixIcon: IconButton(
                  iconSize: 20,
                  icon: const Icon(Icons.mic, color: Colors.white),
                  onPressed: () {},
                ),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 12.0),
            ),
          ),
        ),
        const SizedBox(width: 16.0),
        SizedBox(
          height: 30,
          width: 30,
          child: IconButton(
            iconSize: 16,
            style: ButtonStyle(
              backgroundColor: WidgetStateColor.resolveWith(
                (states) => Colors.white,
              ),
            ),
            icon: const Icon(Icons.send, color: CustomColors.deepPurple),
            onPressed: () {
              onSendMessage(controller.text);
              controller.clear();
            },
          ),
        ),
      ],
    );
  }
}
