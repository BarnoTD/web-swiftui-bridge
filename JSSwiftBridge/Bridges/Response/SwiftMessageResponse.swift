//
//  SwiftMessageResponse.swift
//  JSSwiftBridge
//
//  Created by Firas Amara on 18/4/2026.
//

struct SwiftBridgeResponse: Codable {
    let requestId: String
    let success: Bool
    let result: String?  // JSON-encoded result string
    let error: String?
}


