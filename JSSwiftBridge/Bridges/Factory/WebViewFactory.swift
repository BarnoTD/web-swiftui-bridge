//
//  WebViewFactory.swift
//  JSSwiftBridge
//
//  Created by Firas Amara on 18/4/2026.
//


import WebKit
import SwiftUI
import Combine

struct MessageHandler<T:Decodable> {
    let name: String
    let handler: WebScriptHandler<T>
    
    var publisher: AnyPublisher<T, Never> {
        handler.messageSubject.eraseToAnyPublisher()
    }
    
    init(_ name: String) {
        self.name = name
        self.handler = WebScriptHandler<T>()
    }
    
}

/// Builds a pre-configured WKWebViewConfiguration for a specific bridge context.
@MainActor
final class WebViewFactory: ObservableObject {
    let configuration = WKWebViewConfiguration()

    let bridge: MessageHandler<JSBridgeMessage>
    let context: JSMessageRouter.Context
    let scriptHandlerName = JSMessageRouter.Context.scriptMessageHandlerName

    init(context: JSMessageRouter.Context) {
        self.context = context
        self.bridge = MessageHandler<JSBridgeMessage>(scriptHandlerName)
        let weakHandler = WeakScriptMessageHandler(handler: bridge.handler)
        configuration.userContentController.add(weakHandler, name: bridge.name)
    }
}
