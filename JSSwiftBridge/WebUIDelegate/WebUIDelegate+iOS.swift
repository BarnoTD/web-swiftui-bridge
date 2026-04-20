//
//  WebUIDelegate 2.swift
//  JSSwiftBridge
//
//  Created by Firas Amara on 18/4/2026.
//
import SwiftUI
import WebKit

#if os(iOS)
import UIKit

/// A platform-specific `WKUIDelegate` that bridges JavaScript UI dialogs
/// (alert, confirm, prompt) from web content to native system dialogs.
///
/// On iOS, this delegate presents `UIAlertController` modals for:
/// - `alert(message)`: informational message with an OK button
/// - `confirm(message)`: confirmation with OK/Cancel returning a Bool
/// - `prompt(message, defaultText)`: text input returning a String
///
/// It also includes helpers to locate an appropriate presenting view controller
/// from a given `WKWebView` instance.
final class WebUIDelegate: NSObject, WKUIDelegate {
    /// Handles JavaScript `alert(message)` calls from the page.
    ///
    /// Presents a native alert with a single OK action and calls the
    /// `completionHandler` after dismissal so WebKit can resume script execution.
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        presentAlert(on: webView, title: nil, message: message, actions: [
            UIAlertAction(title: "OK", style: .default) { _ in completionHandler() }
        ])
    }

    /// Handles JavaScript `confirm(message)` calls from the page.
    ///
    /// Shows a native alert with Cancel and OK. Invokes `completionHandler` with
    /// `true` when the user taps OK, and `false` when they cancel.
    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        presentAlert(on: webView, title: nil, message: message, actions: [
            UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(false) },
            UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) }
        ])
    }

    /// Handles JavaScript `prompt(message, defaultText)` calls from the page.
    ///
    /// Presents a native text field alert initialized with `defaultText` (if any).
    /// Passes the entered text to `completionHandler`, or `nil` if cancelled.
    func webView(_ webView: WKWebView,
                 runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField { $0.text = defaultText }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(nil) })
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })
        present(alert, on: webView)
    }

    /// Convenience to build and present a `UIAlertController` with the given actions
    /// from the nearest presenting view controller associated with `webView`.
    private func presentAlert(on webView: WKWebView, title: String?, message: String?, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach(alert.addAction)
        present(alert, on: webView)
    }

    /// Presents the provided `UIAlertController` from a view controller resolved
    /// relative to the supplied `WKWebView`.
    private func present(_ alert: UIAlertController, on webView: WKWebView) {
        guard let vc = findPresentingViewController(from: webView) else { return }
        vc.present(alert, animated: true)
    }

    /// Attempts to find a suitable presenter by walking the responder chain
    /// starting at the given view. Falls back to the key window's root controller.
    private func findPresentingViewController(from view: UIView) -> UIViewController? {
        var responder: UIResponder? = view
        while let r = responder {
            if let vc = r as? UIViewController { return vc }
            responder = r.next
        }
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }
}
#endif
