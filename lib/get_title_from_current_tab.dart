import 'package:chrome_extension/scripting.dart';
import 'package:chrome_extension/tabs.dart';

Future<String> getTitleFromCurrentTab() async {
  try {
    // Get the current tab
    var tabs = await chrome.tabs.query(QueryInfo(
      active: true,
      currentWindow: true,
    ));

    if (tabs.isNotEmpty) {
      var currentTab = tabs.first;
      if (currentTab.id != null) {
        // Define the script to execute
        const script = '''
          console.log(document.title);
          document.title;
        ''';

        // Execute the script to get the title of the page
        var result = await chrome.scripting.executeScript(
          ScriptInjection(
            target: InjectionTarget(tabId: currentTab.id!),
            files: ['content_script.js'],
            // function: script,
          ),
        );

        if (result.isNotEmpty && result.first.result != null) {
          return result.first.result.toString();
        }
      }
    }
    return 'No title found';
  } catch (e) {
    print('Error: $e');
    return 'Error fetching title';
  }
}

void main() async {
  // Make sure to call this function in an async environment
  String title = await getTitleFromCurrentTab();
  print('Page Title: $title');
}
