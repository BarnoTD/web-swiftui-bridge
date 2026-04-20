//
//  JsonCleaner.swift
//  JSSwiftBridge
//
//  Created by Firas Amara on 18/4/2026.
//
import Foundation

final class JsonCleaner {
    static func clean<T:Encodable>(from value: T, emptyFallback: String) -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        guard let data = try? encoder.encode(value),
              let json = String(data: data, encoding: .utf8) else {
            return emptyFallback
        }
        return json
    }
}
