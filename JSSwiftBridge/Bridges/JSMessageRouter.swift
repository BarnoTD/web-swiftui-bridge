//
//  JSMessageRouter.swift
//  JSSwiftBridge
//
//  Created by Firas Amara on 18/4/2026.
//

import Combine
import Foundation
import WebUI

@MainActor
protocol JSBridgeMessageHandling: AnyObject {
    var bridgeContext: JSMessageRouter.Context { get }
    func handleBridgeMessage(_ message: JSBridgeMessage, proxy: WebViewProxy, router: JSMessageRouter) async throws -> String?
}

@MainActor
final class JSMessageRouter: ObservableObject {
    enum Context {
        case pageA
        case pageB

        //WebKit Bridge Name
        static let scriptMessageHandlerName: String = "nativeBridge"

        //Response (some pages need them, others don't)
        var responseCallbackName: String? {
            switch self {
            case .pageA:
                return "onNativeResponse"
            case .pageB:
                return nil
            }
        }
    }

    // Publishers for reactive updates
    let appointmentUpdate = PassthroughSubject<Void, Never>()

    // Track processed requests to prevent duplicates
    private var processedRequests = Set<String>()

    // Type erasure wrapper for Encodable
    private struct AnyEncodable: Encodable {
        private let _encode: (Encoder) throws -> Void
        init(_ base: Encodable) {
            self._encode = base.encode
        }
        func encode(to encoder: Encoder) throws { try _encode(encoder) }
    }

    func route(_ message: JSBridgeMessage, handler: JSBridgeMessageHandling, proxy: WebViewProxy) {
        if processedRequests.contains(message.requestId) {
            return
        }
        processedRequests.insert(message.requestId)

        Task { @MainActor in
            // Ensure the request ID is removed when processing completes (success or failure)
            defer {
                self.processedRequests.remove(message.requestId)
            }
            do {
                let result = try await handler.handleBridgeMessage(message, proxy: proxy, router: self)

                if let callbackName = handler.bridgeContext.responseCallbackName {
                    await sendResponse(message.requestId, callbackName: callbackName, success: true, result: result, proxy: proxy)
                }
            } catch {
                if let callbackName = handler.bridgeContext.responseCallbackName {
                    await sendResponse(message.requestId, callbackName: callbackName, success: false, error: error.localizedDescription, proxy: proxy)
                } else {
                    print("❌ JS bridge error (\(message.type)): \(error.localizedDescription)")
                }
            }
        }
    }

    private func sendResponse(
        _ requestId: String,
        callbackName: String,
        success: Bool,
        result: String? = nil,
        error: String? = nil,
        proxy: WebViewProxy
    ) async {
        let response = SwiftBridgeResponse(requestId: requestId, success: success, result: result, error: error)
        
        let script = "window.\(callbackName)('\(JsonCleaner.clean(from: response, emptyFallback: ""))')"
        
        _ = try? await proxy.evaluateJavaScript(script)
    }
}

