//
//  WebUIDelegate.swift
//  JSSwiftBridge
//
//  Created by Firas Amara on 18/4/2026.
//
import SwiftUI
import WebKit

#if os(macOS)
import AppKit
import UniformTypeIdentifiers

/// A platform-specific `WKUIDelegate` that bridges JavaScript UI dialogs
/// (alert, confirm, prompt) from web content to native AppKit dialogs on macOS.
final class WebUIDelegate: NSObject, WKUIDelegate {
    /// Handles JavaScript `alert(message)` by showing an `NSAlert` with an OK button.
    /// Calls `completionHandler` immediately after presenting.
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        present(alert, for: webView)
        completionHandler()
    }

    /// Handles JavaScript `confirm(message)` using an `NSAlert` with OK and Cancel.
    /// Invokes `completionHandler(true)` when OK is chosen, otherwise `false`.
    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        let response = present(alert, for: webView)
        completionHandler(response == .alertFirstButtonReturn)
    }

    /// Handles JavaScript `prompt(message, defaultText)` by presenting an `NSAlert`
    /// with an `NSTextField` accessory view. Returns the entered string or `nil`.
    func webView(_ webView: WKWebView,
                 runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        let alert = NSAlert()
        alert.messageText = prompt
        let textField = NSTextField(string: defaultText ?? "")
        textField.frame = NSRect(x: 0, y: 0, width: 300, height: 24)
        alert.accessoryView = textField
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        let response = present(alert, for: webView)
        if response == .alertFirstButtonReturn {
            completionHandler(textField.stringValue)
        } else {
            completionHandler(nil)
        }
    }
    
    /// Handles  `<input type="file" html>` by presenting `fileExplorer`
    ///  on macOS and iOS
    func webView(_ webView: WKWebView,
                 runOpenPanelWith parameters: WKOpenPanelParameters,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping ([URL]?) -> Void)
    {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = parameters.allowsMultipleSelection
        panel.canCreateDirectories = false

        // Optional: filter to images only if your HTML uses accept="image/*"
        panel.allowedContentTypes = [.image]

        let response = panel.runModal()
        completionHandler(response == .OK ? panel.urls : nil)
    }

    /// Presents the provided `NSAlert` and returns the modal response.
    /// If the web view is attached to a window, the alert runs modally.
    /// Sets an empty icon to prevent showing the app icon.
    @discardableResult
    private func present(_ alert: NSAlert, for webView: WKWebView) -> NSApplication.ModalResponse {
        // set alert icon to a system image
        alert.icon = NSImage(systemSymbolName: "info.circle.fill", accessibilityDescription: nil)
        return alert.runModal()
    }
}
#endif
