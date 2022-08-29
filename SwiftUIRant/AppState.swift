//
//  AppState.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 29.08.22.
//

import Foundation
import SwiftRant

final class AppState: ObservableObject {
    static let shared = AppState()
    
    var isLoggedIn: Bool {
        SwiftRant.shared.tokenFromKeychain != nil
    }
}
