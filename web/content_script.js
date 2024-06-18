chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
  if (request.action === "getPageContent") {
    console.log("Received getPageContent message");
    sendResponse({ content: document.body.innerText });
  }
});
