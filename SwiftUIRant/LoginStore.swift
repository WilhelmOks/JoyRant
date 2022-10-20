//
//  LoginStore.swift
//  SwiftUIRant
//
//  Created by Wilhelm Oks on 20.10.22.
//

import Foundation
import SwiftKeychainWrapper
import SwiftRant

final class LoginStore {
    static let shared = LoginStore()
    private init() {}
    
    private let keychainWrapper = KeychainWrapper(serviceName: "SwiftUIRant")
    private let tokenKeychainKeyName: KeychainWrapper.Key = "devRantToken"
    
    var isLoggedIn: Bool { token != nil }
    
    var token: UserCredentials? {
        get {
            return keychainWrapper.decode(forKey: tokenKeychainKeyName.rawValue)
        }
        set {
            if let newValue {
                let success = keychainWrapper.encodeAndSet(
                    newValue,
                    forKey: tokenKeychainKeyName.rawValue,
                    withAccessibility: .whenUnlockedThisDeviceOnly
                )
                if !success {
                    dlog("Error: failed to store token in keychain")
                }
            } else {
                keychainWrapper.remove(forKey: tokenKeychainKeyName)
            }
        }
    }
}
