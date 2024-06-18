"use strict";

// Import the Flutter service worker
importScripts("flutter_service_worker.js");

console.log("Custom Service Worker Loaded");

// Log installation
self.addEventListener("install", (event) => {
  console.log("Service Worker: Install");
  self.skipWaiting();
});

// Log activation
self.addEventListener("activate", (event) => {
  console.log("Service Worker: Activate");
  event.waitUntil(clients.claim());
});

// Handle action button click
chrome.action.onClicked.addListener((tab) => {
  console.log("Action button clicked");
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
          console.log("Response from content script:", response);
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

// Handle messages from content script and pass them to the Flutter web app
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message.type === "content") {
    console.log("Content received:", message.content);
    clients.matchAll().then((clients) => {
      clients.forEach((client) => {
        client.postMessage({ type: "content", content: message.content });
      });
    });
  }
});
