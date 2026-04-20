//
//  JSBridgeMessage.swift
//  JSSwiftBridge
//
//  Created by Firas Amara on 18/4/2026.
//


import Foundation


struct JSBridgeMessage: Codable {
    let type: String  // "doSomething"
    let payload: String  // JSON-encoded payload as string
    let requestId: String // Shared async bridge contract
}
