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
        let keychainWrapper = KeychainWrapper(
            serviceName: "SwiftRant",
            accessGroup: "SwiftRantAccessGroup"
        )
        
        let query: [String:Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true,
        ]
        
        keychainWrapper.removeAllKeys()
        let _ = SecItemDelete(query as CFDictionary)
        
        //dlog("osstatus: \(osstatus)")
        
        DispatchQueue.main.async {
            AppState.shared.objectWillChange.send()
        }
    }
    
    func rants() async throws {
        guard let token = SwiftRant.shared.tokenFromKeychain else {
            throw SwiftRantError(message: "No token in keychain.")
        }
        
        let response = await SwiftRant.shared.getRantFeed(token: token, skip: 0, prevSet: nil) // "Algo"
        
        if let errorMessage = response.0 {
            throw SwiftRantError(message: errorMessage)
        } else {
            let rantText = response.1?.rants.map { $0.text }.joined(separator: "\n###\n")
            dlog("RANTS: \n\n\(rantText ?? "-")")
            return
        }
    }
}
