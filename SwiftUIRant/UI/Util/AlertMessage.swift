//
//  AlertMessage.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation
import SwiftUI

struct AlertMessage {
    var isPresented: Bool
    let title: String
    let message: String
    let buttonText: String
}

extension AlertMessage {
    static func none() -> Self {
        AlertMessage(isPresented: false, title: "", message: "", buttonText: "")
    }
    
    static func presentedError(message: String) -> Self {
        AlertMessage(isPresented: true, title: "Error", message: message, buttonText: "OK")
    }
    
    static func presentedError(_ error: Error) -> Self {
        let message: String
        switch error {
        case let swiftRantError as Networking.SwiftRantError:
            message = swiftRantError.message
        default:
            message = error.localizedDescription
        }
        dlog("Error: \(message)")
        return presentedError(message: message)
    }
}

extension View {
    func alert(_ alertMessage: Binding<AlertMessage>) -> some View {
        self.alert(
            alertMessage.wrappedValue.title,
            isPresented: alertMessage.isPresented,
            actions: {
                Button(alertMessage.wrappedValue.buttonText, role: .cancel) {
                    
                }
            },
            message: {
                Text(alertMessage.wrappedValue.message)
            }
        )
    }
}
