//
//  WebScriptHandler.swift
//  JSSwiftBridge
//
//  Created by Firas Amara on 18/4/2026.
//

import WebKit
import Combine

final class WebScriptHandler<T: Decodable>: NSObject, WKScriptMessageHandler, ObservableObject {
    let messageSubject = PassthroughSubject<T,Never>()
    
    ///Checks whether the message is decodable to desired type T
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard
            let body = message.body as? [String: Any],
            let data = try? JSONSerialization.data(withJSONObject: body),
            let decoded = try? JSONDecoder().decode(T.self, from: data)
        else {
            print("❌ Failed to decode message body: \(message.body)") 
            return
        }
        messageSubject.send(decoded)
    }
}

/// Wraps a WKScriptMessageHandler with a weak reference to break retain cycles.
/// Add this *instead* of the handler itself to WKUserContentController.
final class WeakScriptMessageHandler: NSObject, WKScriptMessageHandler {
    private weak var handler: WKScriptMessageHandler?

    init(handler: WKScriptMessageHandler) {
        self.handler = handler
    }

    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        handler?.userContentController(userContentController, didReceive: message)
    }
}
