import 'package:universal_html/html.dart' as html;
import 'package:chrome_extension/tabs.dart';

void initializePlatformListener(Function(String) onMessageReceived) async {
  html.window.onMessage.listen((event) {
    print("Received message in Flutter: ${event.data}");
    if (event.data['type'] == 'content') {
      onMessageReceived(event.data['content']);
    }
  });

  var tabs = await chrome.tabs.query(QueryInfo(
    active: true,
    currentWindow: true,
  ));
  print(tabs.first.title);
}
