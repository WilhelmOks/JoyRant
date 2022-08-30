//
//  SwiftRantAsync.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 24.08.22.
//

import Foundation
import SwiftRant
import SwiftKeychainWrapper

struct Networking {
    static let shared = Self()
    
    struct SwiftRantError: Swift.Error {
        let message: String
    }
    
    private init() {}
    
    func logIn(username: String, password: String) async throws {
        let response = await SwiftRant.shared.logIn(username: username, password: password)
        
        if let errorMessage = response.0 {
            throw SwiftRantError(message: errorMessage)
        } else {
            DispatchQueue.main.async {
                AppState.shared.objectWillChange.send()
            }
        }
    }
    
    func logOut() {
        SwiftRant.shared.logOut()
        
        DataStore.shared.clear()
        
        DispatchQueue.main.async {
            AppState.shared.objectWillChange.send()
        }
    }
    
    func rants() async throws -> RantFeed {
        guard let token = SwiftRant.shared.tokenFromKeychain else {
            throw SwiftRantError(message: "No token in keychain.")
        }
        
        let response = await SwiftRant.shared.getRantFeed(token: token, skip: 0, prevSet: nil) // "Algo"
        
        if let errorMessage = response.0 {
            throw SwiftRantError(message: errorMessage)
        } else {
            guard let rantFeed = response.1 else {
                throw SwiftRantError(message: "No rant feed received.")
            }
            
            return rantFeed
        }
    }
}
