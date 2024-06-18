// background.js

// Import the Flutter service worker
// importScripts("flutter_service_worker.js");

// Handle action button click
chrome.action.onClicked.addListener((tab) => {
  chrome.scripting.executeScript(
    {
      target: { tabId: tab.id },
      files: ["content_script.js"],
    },
    () => {
      chrome.tabs.sendMessage(
        tab.id,
        { action: "getPageContent" },
        (response) => {
          if (response && response.content) {
            chrome.runtime.sendMessage({
              type: "content",
              content: response.content,
            });
          }
        }
      );
    }
  );
});
