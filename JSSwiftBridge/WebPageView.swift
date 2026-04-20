//
//  WebPageView.swift
//  JSSwiftBridge
//
//  Created by Firas Amara on 20/4/2026.
//

import SwiftUI
import WebUI
import Combine

struct WebPageView: View {
    @State private var isDark: Bool = false
    @StateObject private var handler = PageAHandler()
    @StateObject private var factory = WebViewFactory(context: .pageA)
    
    @StateObject private var router = JSMessageRouter()

    var body: some View {
        WebViewReader { proxy in
            VStack(alignment: .leading, spacing: 12) {
                Toggle(isOn: Binding(
                    get: { isDark },
                    set: { newValue in
                        isDark = newValue
                        handler.isDark = newValue
                        // Push theme to the web page when toggled
                        let theme = newValue ? "dark" : "light"
                        Task { try? await proxy.evaluateJavaScript("window.nativeBridge.setTheme(\"\(theme)\")") }
                    }
                )) {
                    Text("Dark Mode")
                }
                .padding(.horizontal)

                WebView(configuration: factory.configuration)
                    .uiDelegate(WebUIDelegate())
                    .onAppear {
                        // Load local page
                        if let url = Bundle.main.url(forResource: "webpageA", withExtension: "html") {
                            proxy.load(request: URLRequest(url: url))
                        }
                        // Sync initial theme to handler and web page
                        handler.isDark = isDark
                        let theme = isDark ? "dark" : "light"
                        Task { try? await proxy.evaluateJavaScript("window.nativeBridge.setTheme(\"\(theme)\")") }
                    }
                    .onJSMessage(factory.bridge, vm: handler) { _, message in
                        router.route(message, handler: handler, proxy: proxy)
                    }
            }
            .preferredColorScheme(isDark ? .dark : .light)
        }
    }
}

extension WebPageView {
    @MainActor
    final class PageAHandler: JSBridgeMessageHandling, ObservableObject {
        @Published var isDark: Bool = false
        
        private weak var webProxy: WebViewProxy?

        var bridgeContext: JSMessageRouter.Context = .pageA

        private struct LogPayload: Decodable { let message: String }
        private struct PickItemPayload: Decodable { let optionsJson: String }
        private struct ComputeSumPayload: Decodable { let a: Double; let b: Double }

        private func decodePayload<T: Decodable>(_ type: T.Type, from message: JSBridgeMessage) throws -> T {
            try JSONDecoder().decode(T.self, from: Data(message.payload.utf8))
        }

        @discardableResult
        private func eval(_ js: String, with proxy: WebUI.WebViewProxy) async throws -> Any? {
            try await proxy.evaluateJavaScript(js)
        }

        func handleBridgeMessage(_ message: JSBridgeMessage, proxy: WebUI.WebViewProxy, router: JSMessageRouter) async throws -> String? {
            switch message.type {
            case "log":
                let payload = try decodePayload(LogPayload.self, from: message)
                print("[JS LOG] \(payload.message)")
                return nil

            case "getTheme":
                let theme = isDark ? "dark" : "light"
                try await eval("window.nativeBridge.setTheme(\"\(theme)\")", with: proxy)
                return nil

            case "pickItem":
                let payload = try decodePayload(PickItemPayload.self, from: message)
                if let data = payload.optionsJson.data(using: .utf8),
                   let options = try? JSONSerialization.jsonObject(with: data) as? [String],
                   let picked = options.first {
                    let js = "(function(){ const msg='Picked from Swift: ' + \"\(picked)\"; if (window.log) { log(msg); } else { console.log(msg); } })()"
                    try await eval(js, with: proxy)
                }
                return nil

            case "computeSum":
                let payload = try decodePayload(ComputeSumPayload.self, from: message)
                let sum = payload.a + payload.b
                let js = "(function(){ const msg='Swift computed sum: ' + \(sum); if (window.log) { log(msg); } else { console.log(msg); } })()"
                try await eval(js, with: proxy)
                return String(sum.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(sum)) : String(sum))

            default:
                throw NSError(domain: "JSBridge", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown message type: \(message.type)"])
            }
        }
    }
}

#Preview {
    WebPageView()
}
