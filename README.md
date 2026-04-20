# JSSwiftBridge

A custom web bridge implementation between JavaScript and Swift, built on top of [cybozu/WebUI](https://github.com/cybozu/WebUI) with additional extensions for streamlined communication.

## Overview

This project provides a type-safe, extensible bridge for sending messages between JavaScript running in WKWebView and Swift code. It leverages WebUI's core functionality while adding custom handlers, message routing, and SwiftUI integrations.

## Components

### Bridges
- **JSMessageRouter.swift**: Central router that dispatches incoming JavaScript messages to appropriate handlers based on message type.
- **WebScriptHandler.swift**: WKScriptMessageHandler implementation that receives messages from JavaScript and forwards them to the router.
- **Factory/WebViewFactory.swift**: Factory for creating configured WKWebView instances with the bridge setup.
- **Message/JSBridgeMessage.swift**: Data structure representing messages sent from JavaScript to Swift.
- **Response/SwiftMessageResponse.swift**: Structure for responses sent back from Swift to JavaScript.
- **ViewExtension/View+JSMessage.swift**: SwiftUI view extension for handling JS messages in views.

### Helpers
- **JSON/JsonCleaner.swift**: Utility for cleaning and encoding JSON data, with fallback handling.

### WebUIDelegate
- **WebUIDelegate+iOS.swift**: iOS-specific WKUIDelegate for handling web UI dialogs (alerts, confirms, file inputs).
- **WebUIDelegate+macOS.swift**: macOS-specific WKUIDelegate for native AppKit dialogs.

### Views
- **WebPageView.swift**: SwiftUI view wrapping WKWebView with bridge integration.
- **ContentView.swift**: Main app view demonstrating the bridge usage.

### Web Content
- **Webpages/PageA/webpageA.html**: Sample HTML page with JavaScript that demonstrates sending messages to Swift.

## Usage

1. Create a WebPageView with a URL or HTML content.
2. Use the View extension `onJSMessage` to handle incoming messages in your SwiftUI views.
3. Send responses back to JavaScript using the message handler's response methods.

The bridge enables bidirectional communication: JavaScript can call Swift functions and pass data, while Swift can execute JavaScript and return results.