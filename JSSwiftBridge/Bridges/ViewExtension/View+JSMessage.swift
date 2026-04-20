//
//  View+JSMessage.swift
//  JSSwiftBridge
//
//  Created by Firas Amara on 20/4/2026.
//
import SwiftUI

extension View {
    func onJSMessage<T: Decodable, VM: ObservableObject>(
        _ handler: MessageHandler<T>,
        vm: VM,
        action: @escaping (VM, T) -> Void
    ) -> some View {
        self.onReceive(handler.publisher) { payload in
            action(vm, payload)
        }
    }
}
